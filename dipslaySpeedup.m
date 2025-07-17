nValues = [5, 10, 15, 20, 30, 40, 50, 75];
% Load precomputed data
load('speedup_data_grid.mat');

% Parameter definitions
threadings = 1:maxNumberOfThread;

% Fixed parameter indices
fixed_n = 5;          % n = 30
fixed_size = 6;       % simSize = 200
fixed_ks = 3;         % ks = 25
threadIdx = 10;       % thread = 10

%% --- Slice plots at thread 10 ---

f1 = figure('Name', 'Speedup slices at fixed thread', 'Position', [100 100 800 250]);
t = tiledlayout(1,3, 'TileSpacing', 'compact', 'Padding', 'compact');
sgtitle(t, sprintf('Speedup ratio slices at thread = %d', threadIdx));

% 1. simSize vs ks at fixed n
nexttile;
slice1 = squeeze(speedupData(:,:,fixed_n,threadIdx));
imagesc(slice1');
xlabel('simSize'); ylabel('ks');
title(sprintf('n = %d', nValues(fixed_n)));
set(gca, 'XTick', 1:length(simSizes), 'XTickLabel', simSizes);
set(gca, 'YTick', 1:length(ksValues), 'YTickLabel', ksValues);
axis xy;
cb = colorbar;
cb.Label.String = 'Speedup (%)';
cb.Ticks = linspace(min(slice1(:)), max(slice1(:)), 6);
cb.TickLabels = arrayfun(@(x) sprintf('%.0f%%', (x-1)*100), cb.Ticks, 'UniformOutput', false);

% 2. ks vs n at fixed simSize
nexttile;
slice2 = squeeze(speedupData(fixed_size,:,: ,threadIdx));
imagesc(slice2);
xlabel('n'); ylabel('ks');
title(sprintf('simSize = %d', simSizes(fixed_size)));
set(gca, 'XTick', 1:length(nValues), 'XTickLabel', nValues);
set(gca, 'YTick', 1:length(ksValues), 'YTickLabel', ksValues);
axis xy;
cb = colorbar;
cb.Label.String = 'Speedup (%)';
cb.Ticks = linspace(min(slice2(:)), max(slice2(:)), 6);
cb.TickLabels = arrayfun(@(x) sprintf('%.0f%%', (x-1)*100), cb.Ticks, 'UniformOutput', false);

% 3. simSize vs n at fixed ks
nexttile;
slice3 = squeeze(speedupData(:,fixed_ks,:,threadIdx));
imagesc(slice3);
xlabel('n'); ylabel('simSize');
title(sprintf('ks = %d', ksValues(fixed_ks)));
set(gca, 'XTick', 1:length(nValues), 'XTickLabel', nValues);
set(gca, 'YTick', 1:length(simSizes), 'YTickLabel', simSizes);
axis xy;
cb = colorbar;
cb.Label.String = 'Speedup (%)';
cb.Ticks = linspace(min(slice3(:)), max(slice3(:)), 6);
cb.TickLabels = arrayfun(@(x) sprintf('%.0f%%', (x-1)*100), cb.Ticks, 'UniformOutput', false);

% Export figure
export_fig(f1, 'speedup_slices_fixed_thread.png', '-png', '-transparent','-m4', '-r300');

% Caption (for LaTeX/paper)
% Figure: Speedup ratios (in %) at fixed thread count = 10.
% Left: variation with simSize and ks for n = 30.
% Middle: variation with ks and n for simSize = 200.
% Right: variation with simSize and n for ks = 25.

%% --- Max speedup and optimal thread count

f2 = figure('Name', 'Max speedup and optimal threads', 'Position', [100 100 600 800]);
t2 = tiledlayout(3,2, 'TileSpacing', 'compact', 'Padding', 'compact');
sgtitle(t2, 'Max speedup and corresponding optimal thread count');

% 1. simSize vs ks at fixed n
slice_all1 = squeeze(speedupData(:,:,fixed_n,:));
[maxSpeedup1, maxIdx1] = max(slice_all1, [], 3);

nexttile;
imagesc(maxSpeedup1');
xlabel('simSize'); ylabel('ks');
title(sprintf('Max speedup at n = %d', nValues(fixed_n)));
set(gca, 'XTick', 1:length(simSizes), 'XTickLabel', simSizes);
set(gca, 'YTick', 1:length(ksValues), 'YTickLabel', ksValues);
axis xy;
cb = colorbar;
cb.Label.String = 'Speedup (%)';
cb.TickLabels = arrayfun(@(x) sprintf('%.0f%%', (x-1)*100), cb.Ticks, 'UniformOutput', false);

nexttile;
imagesc(threadings(maxIdx1)');
xlabel('simSize'); ylabel('ks');
title(sprintf('Optimal threads (n = %d)', nValues(fixed_n)));
set(gca, 'XTick', 1:length(simSizes), 'XTickLabel', simSizes);
set(gca, 'YTick', 1:length(ksValues), 'YTickLabel', ksValues);
axis xy;
cb = colorbar; cb.Label.String = 'Threads';

% 2. simSize vs n at fixed ks
slice_all2 = squeeze(speedupData(:,fixed_ks,:,:));
[maxSpeedup2, maxIdx2] = max(slice_all2, [], 3);

nexttile;
imagesc(maxSpeedup2);
xlabel('n'); ylabel('simSize');
title(sprintf('Max speedup at ks = %d', ksValues(fixed_ks)));
set(gca, 'XTick', 1:length(nValues), 'XTickLabel', nValues);
set(gca, 'YTick', 1:length(simSizes), 'YTickLabel', simSizes);
axis xy;
cb = colorbar;
cb.Label.String = 'Speedup (%)';
cb.TickLabels = arrayfun(@(x) sprintf('%.0f%%', (x-1)*100), cb.Ticks, 'UniformOutput', false);

nexttile;
imagesc(threadings(maxIdx2));
set(gca, 'ColorScale', 'log')
xlabel('n'); ylabel('simSize');
title(sprintf('Optimal threads (ks = %d)', ksValues(fixed_ks)));
set(gca, 'XTick', 1:length(nValues), 'XTickLabel', nValues);
set(gca, 'YTick', 1:length(simSizes), 'YTickLabel', simSizes);
axis xy;
cb = colorbar; cb.Label.String = 'Threads';

% 3. ks vs n at fixed simSize
slice_all3 = squeeze(speedupData(fixed_size,:,:,:));
[maxSpeedup3, maxIdx3] = max(slice_all3, [], 3);

nexttile;
imagesc(maxSpeedup3);
xlabel('n'); ylabel('ks');
title(sprintf('Max speedup at simSize = %d', simSizes(fixed_size)));
set(gca, 'XTick', 1:length(nValues), 'XTickLabel', nValues);
set(gca, 'YTick', 1:length(ksValues), 'YTickLabel', ksValues);
axis xy;
cb = colorbar;
cb.Label.String = 'Speedup (%)';
cb.TickLabels = arrayfun(@(x) sprintf('%.0f%%', (x-1)*100), cb.Ticks, 'UniformOutput', false);

nexttile;
imagesc(threadings(maxIdx3));
xlabel('n'); ylabel('ks');
title(sprintf('Optimal threads (simSize = %d)', simSizes(fixed_size)));
set(gca, 'XTick', 1:length(nValues), 'XTickLabel', nValues);
set(gca, 'YTick', 1:length(ksValues), 'YTickLabel', ksValues);
axis xy;
cb = colorbar; cb.Label.String = 'Threads';

% Export figure
export_fig(f2, 'max_speedup_optimal_threads.png', '-png', '-transparent','-m4', '-r300');

% Caption (for LaTeX/paper)
% Figure: Maximum speedup (in %) and optimal number of threads across dimensions.
% Top row: simSize vs ks (n = 30).
% Bottom row left: simSize vs n (ks = 25).
% Bottom row right: ks vs n (simSize = 200).
