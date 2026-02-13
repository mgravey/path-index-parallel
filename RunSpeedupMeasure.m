function RunSpeedupMeasure(localIter, machineID, useParallel, numWorkers)
	% ==============================
	% Speedup computation (per machine)
	% ==============================
	% Usage:
	%   RunSpeedupMeasure(localIter, machineID)                    % serial (default)
	%   RunSpeedupMeasure(localIter, machineID, true)              % parallel, default workers
	%   RunSpeedupMeasure(localIter, machineID, true, numWorkers)  % parallel, fixed workers

	if nargin < 2
		error('Usage: RunSpeedupMeasure(localIter, machineID, useParallel, numWorkers)');
	end
	if nargin < 3 || isempty(useParallel)
		useParallel = false;
	end
	if nargin < 4
		numWorkers = [];
	end

	if ischar(useParallel) || isstring(useParallel)
		useParallel = any(strcmpi(string(useParallel), ["true", "1", "yes", "parallel", "on"]));
	else
		useParallel = logical(useParallel);
	end

	if ~isempty(numWorkers)
		validateattributes(numWorkers, {'numeric'}, {'scalar', 'integer', 'positive'});
	end

	simSizes          = [10, 25, 50, 100, 150, 200, 250, 350, 500];
	ksValues          = [11, 15, 25, 51, 75];
	nValues           = [5, 10, 15, 20, 30, 40, 50, 75];
	maxNumberOfThread = 5000;

	outFile = sprintf('speedup_data_grid_part_%d.mat', machineID);

	% Prepare storage, with resume/extend support
	sz = [length(simSizes), length(ksValues), length(nValues), maxNumberOfThread, localIter, 2];

	if isfile(outFile)
		loaded = load(outFile, 'speedupData', 'simSizes', 'ksValues', 'nValues', 'maxNumberOfThread', 'localIter');

		% Check dimension compatibility
		if isequal(loaded.simSizes, simSizes) && ...
		   isequal(loaded.ksValues, ksValues) && ...
		   isequal(loaded.nValues, nValues) && ...
		   loaded.maxNumberOfThread == maxNumberOfThread

			speedupData = loaded.speedupData;

			% Extend localIter if needed
			if localIter > loaded.localIter
				oldSz = size(speedupData);
				newSz = sz;
				tmp = nan(newSz);
				tmp(:, :, :, :, 1:oldSz(5), :) = speedupData;
				speedupData = tmp;
				fprintf('[%s] Extended localIter from %d to %d\n', ...
					datestr(now, 'yyyy-mm-dd HH:MM:SS'), loaded.localIter, localIter);
			else
				localIter = loaded.localIter; % keep existing
			end

			fprintf('[%s] Resuming computation from %s\n', ...
				datestr(now, 'yyyy-mm-dd HH:MM:SS'), outFile);
		else
			warning('Parameter mismatch, starting fresh.');
			speedupData = nan(sz);
		end
	else
		speedupData = nan(sz);
	end

	% Configure pool only if requested
	if useParallel
		if ~license('test', 'Distrib_Computing_Toolbox')
			warning('Parallel toolbox not available. Falling back to serial mode.');
			useParallel = false;
		else
			pool = gcp('nocreate');
			if isempty(numWorkers)
				if isempty(pool)
					parpool('local');
				end
			else
				if ~isempty(pool) && pool.NumWorkers ~= numWorkers
					delete(pool);
					pool = [];
				end
				if isempty(pool)
					parpool('local', numWorkers);
				end
			end
			pool = gcp('nocreate');
			fprintf('Parallel mode enabled with %d workers.\n', pool.NumWorkers);
		end
	end

	% Progress tracking
	totalIter = prod(sz([1, 2, 3, 5]));
	processed = 0;
	t0 = tic;

	useGUI = usejava('desktop'); % true if MATLAB GUI available
	if useGUI
		h = waitbar(0, 'Computing speedup data...');
	else
		h = [];
		modeLabel = 'serial';
		if useParallel
			modeLabel = 'parallel';
		end
		fprintf('Starting speedup computation (%d iterations) on machine %d [%s mode]...\n', ...
			totalIter, machineID, modeLabel);
	end

	numSim = length(simSizes);
	numKs = length(ksValues);
	numN = length(nValues);
	callsPerMachine = numSim * numKs * numN * localIter;
	configsPerR = numSim * numKs * numN;

	% ==============================
	% Compute
	% ==============================
	for r = 1:localIter
		if useParallel
			maskTodo = squeeze(isnan(speedupData(:, :, :, 1, r, 1)));
			todo = find(maskTodo(:));

			if ~isempty(todo)
				nTodo = numel(todo);
				tmp0 = nan(nTodo, maxNumberOfThread);
				tmp1 = nan(nTodo, maxNumberOfThread);
				idxMat = zeros(nTodo, 3);

				parfor q = 1:nTodo
					[i, j, k] = ind2sub([numSim, numKs, numN], todo(q));
					localID = (((r - 1) * numKs + (j - 1)) * numN + (k - 1)) * numSim + (i - 1);

					% Continuous global seed across all machines
					seed = (machineID - 1) * callsPerMachine + localID;
					rng(seed, 'twister');
					[v0, v1] = speedup(simSizes(i), ksValues(j), nValues(k), maxNumberOfThread);

					tmp0(q, :) = v0;
					tmp1(q, :) = v1;
					idxMat(q, :) = [i, j, k];
				end

				for q = 1:nTodo
					i = idxMat(q, 1);
					j = idxMat(q, 2);
					k = idxMat(q, 3);
					speedupData(i, j, k, :, r, 1) = tmp0(q, :);
					speedupData(i, j, k, :, r, 2) = tmp1(q, :);
				end
			end

			processed = min(processed + configsPerR, totalIter);
			updateProgress(true);
		else
			for j = length(ksValues):-1:1
				for k = length(nValues):-1:1
					for i = length(simSizes):-1:1
						% Compute only once
						if isnan(speedupData(i, j, k, 1, r, 1))
							localID = (((r - 1) * numKs + (j - 1)) * numN + (k - 1)) * numSim + (i - 1);

							% Continuous global seed across all machines
							seed = (machineID - 1) * callsPerMachine + localID;
							rng(seed, 'twister');
							[v0, v1] = speedup(simSizes(i), ksValues(j), nValues(k), maxNumberOfThread);
							speedupData(i, j, k, :, r, 1) = v0;
							speedupData(i, j, k, :, r, 2) = v1;
						end

						processed = processed + 1;
						updateProgress(false);
					end
				end
			end
		end

		% Save after each iteration
		save(outFile, 'speedupData', 'simSizes', 'ksValues', 'nValues', 'maxNumberOfThread', 'localIter', '-v7.3');
		fprintf('[%s] Saved %s after r=%d/%d\n', datestr(now, 'yyyy-mm-dd HH:MM:SS'), outFile, r, localIter);
	end

	% Close waitbar if GUI
	if useGUI && ~isempty(h)
		close(h);
	end

	fprintf('Finished machine %d -> results in %s\n', machineID, outFile);

	function updateProgress(forcePrint)
		if processed == 0
			return;
		end
		p = processed / totalIter;
		elapsed = toc(t0);
		etaSec = elapsed * (totalIter - processed) / processed;
		hrs = floor(etaSec / 3600);
		mins = floor(mod(etaSec, 3600) / 60);
		secs = floor(mod(etaSec, 60));
		msg = sprintf('Computing speedup data... %d/%d | ETA %02d:%02d:%02d', ...
			processed, totalIter, hrs, mins, secs);

		if useGUI
			waitbar(p, h, msg);
		else
			if forcePrint || mod(processed, 100) == 0 || processed == totalIter
				fprintf('%s\n', msg);
			end
		end
	end
end
