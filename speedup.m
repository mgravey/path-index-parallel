function speedupRatio = speedup(simSize, ks, n, maxNumberOfThread)

	% Ensure square simulation size
	simSize = [simSize simSize];

	% Create random path and dependency
	val = nan(prod(simSize), 1);
	path = randperm(prod(simSize));
	val(path) = 1:prod(simSize);
	im = reshape(val, simSize);

	kernel = ones(ks, ks);

	% Compute dependency
	dep = getDependancy(im, kernel, n);

	% Optimal path by sorted dependency
	[~, idx] = sort(dep(path));
	optimalPath = path(idx);

	% Threading simulation
	threadings = 1:maxNumberOfThread;

	waitingDep = (1:length(path)) - dep(path);
	waitingDepIO = (1:length(path)) - dep(optimalPath);

	extraWaiting = -sum(min(waitingDep - threadings', 0), 2);
	extraWaitingOP = -sum(min(waitingDepIO - threadings', 0), 2);

	% Time estimation
	timePara = (length(path) + extraWaiting ./ threadings') ./ threadings';
	timeParaOP = (length(path) + extraWaitingOP ./ threadings') ./ threadings';

	% Return speedup ratio
	speedupRatio = timePara ./ timeParaOP;
end


