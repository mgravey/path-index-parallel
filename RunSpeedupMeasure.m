% Define parameter ranges
simSizes = [10, 25, 50, 100, 150, 200, 250, 350, 500];
ksValues = [11, 15, 25, 51, 75];
nValues = [5, 10, 15, 20, 30, 40, 50, 75];
maxNumberOfThread = 5000;

% Preallocate result array
speedupData = nan(length(simSizes), length(ksValues), length(nValues), maxNumberOfThread);

% Initialize progress bar
totalIterations = length(simSizes) * length(ksValues) * length(nValues);
currentIteration = 0;
h = waitbar(0, 'Computing speedup data...');

% Compute values with progress update
for j = length(ksValues):-1:1
	for k = length(nValues):-1:1
        for i = length(simSizes):-1:1
			speedupData(i,j,k,:) = speedup(simSizes(i), ksValues(j), nValues(k), maxNumberOfThread);
			currentIteration = currentIteration + 1;
			waitbar(currentIteration / totalIterations, h);
		end
	end
end

% Close progress bar
close(h);

% Save results to disk
save('speedup_data_grid.mat', 'speedupData','simSizes','ksValues','nValues','maxNumberOfThread', '-v7.3');
