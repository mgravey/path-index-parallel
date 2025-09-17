% List all part files
files = dir('speedup_data_grid_part_*.mat');
nMachines = numel(files);

% Load first file to get sizes
load(files(1).name, 'simSizes','ksValues','nValues','maxNumberOfThread','localIter');
nIter = localIter * nMachines;

sz = [length(simSizes), length(ksValues), length(nValues), maxNumberOfThread, nIter];
speedupDataAll = nan(sz);

% Concatenate along 5th dim
idx = 1;
for m = 1:nMachines
	load(files(m).name, 'speedupData','localIter');
	speedupDataAll(:,:,:,:,idx:idx+localIter-1) = speedupData;
	idx = idx + localIter;
end

% Save final merged result

speedupData=speedupDataAll;
save('speedup_data_grid.mat', 'speedupData','simSizes','ksValues','nValues','maxNumberOfThread','nIter','-v7.3');
fprintf('Merged %d machines (%d total iterations)\n', nMachines, nIter);
