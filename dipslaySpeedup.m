nValues = [5, 10, 15, 20, 30, 40, 50, 75];
load('speedup_data_grid.mat');	% loads speedupData, simSizes, ksValues, nValues, maxNumberOfThread, nIter

% Select metric when a 6th dimension is present:
%   1 = baseline (original)
%   2 = groupedPath
useGroupedPath = false;
relative=true;
metricIdx = 1;
metricLabel = 'baseline';
if useGroupedPath
	metricIdx = 2;
	metricLabel = 'groupedPath';
end

if relative
    speedupData = speedupData(:,:,:,:,1:min(end,1000),2)./speedupData(:,:,:,:,1:min(end,1000),1);
else
    speedupData = speedupData(:,:,:,:,1:min(end,1000),metricIdx);
end

sum(isnan(speedupData(:)))/numel(speedupData)

%%
% --- NEW: aggregate over iterations (dimension 5) ---
meanSpeedup = nanmean(speedupData, 5);
stdSpeedup  = nanstd(speedupData, 0, 5);	% same units as ratio; we'll display as %

threadings = 1:maxNumberOfThread;

% Fixed parameter indices (same as before)
fixed_n = 5;			% n = 30
fixed_size = 6;			% simSize = 200
fixed_ks = 3;			% ks = 25
threadIdx = 10;			% thread = 10

%% --- Slices @ fixed thread: row 1 = mean, row 2 = std ---
f1 = figure('Name', 'Speedup slices (mean & std) at fixed thread', 'Position', [100 100 600 700]);
t = tiledlayout(3,2, 'TileSpacing', 'compact', 'Padding', 'compact');
sgtitle(t, sprintf('Speedup (ratio) at thread = %d — mean (left) & std (right) [%s]', threadIdx, metricLabel));

% 1. simSize vs ks @ fixed n
slice1_mu = squeeze(meanSpeedup(:,:,fixed_n,threadIdx));
slice1_sd = squeeze(stdSpeedup(:,:,fixed_n,threadIdx));

nexttile; imagesc(slice1_mu'); axis xy
overlayValues(gca, slice1_mu',-1);

xlabel('simSize'); ylabel('ks'); title(sprintf('mean, n = %d', nValues(fixed_n)));
set(gca,'XTick',1:length(simSizes),'XTickLabel',simSizes,'YTick',1:length(ksValues),'YTickLabel',ksValues);
cb = colorbar; cb.Label.String = 'Speedup (%)';
cb.Ticks = linspace(min(slice1_mu(:)), max(slice1_mu(:)), 6);
cb.TickLabels = arrayfun(@(x) sprintf('%.0f%%',(x-1)*100), cb.Ticks, 'UniformOutput', false);

nexttile; imagesc(slice1_sd'); axis xy
overlayValues(gca, slice1_sd')
xlabel('simSize'); ylabel('ks'); title('std across iterations');
set(gca,'XTick',1:length(simSizes),'XTickLabel',simSizes,'YTick',1:length(ksValues),'YTickLabel',ksValues);
cb = colorbar; cb.Label.String = 'Std of speedup (%)';
cb.Ticks = linspace(min(slice1_sd(:)), max(slice1_sd(:)), 6);
cb.TickLabels = arrayfun(@(x) sprintf('%.0f%%', x*100), cb.Ticks, 'UniformOutput', false);

% 2. ks vs n @ fixed simSize
slice2_mu = squeeze(meanSpeedup(fixed_size,:,:,threadIdx));
slice2_sd = squeeze(stdSpeedup(fixed_size,:,:,threadIdx));

nexttile; imagesc(slice2_mu); axis xy
overlayValues(gca, slice2_mu,-1)
xlabel('n'); ylabel('ks'); title(sprintf('mean, simSize = %d', simSizes(fixed_size)));
set(gca,'XTick',1:length(nValues),'XTickLabel',nValues,'YTick',1:length(ksValues),'YTickLabel',ksValues);
cb = colorbar; cb.Label.String = 'Speedup (%)';
cb.Ticks = linspace(min(slice2_mu(:)), max(slice2_mu(:)), 6);
cb.TickLabels = arrayfun(@(x) sprintf('%.0f%%',(x-1)*100), cb.Ticks, 'UniformOutput', false);

nexttile; imagesc(slice2_sd); axis xy
overlayValues(gca, slice2_sd)
xlabel('n'); ylabel('ks'); title('std across iterations');
set(gca,'XTick',1:length(nValues),'XTickLabel',nValues,'YTick',1:length(ksValues),'YTickLabel',ksValues);
cb = colorbar; cb.Label.String = 'Std of speedup (%)';
cb.Ticks = linspace(min(slice2_sd(:)), max(slice2_sd(:)), 6);
cb.TickLabels = arrayfun(@(x) sprintf('%.0f%%', x*100), cb.Ticks, 'UniformOutput', false);

% 3. simSize vs n @ fixed ks
slice3_mu = squeeze(meanSpeedup(:,fixed_ks,:,threadIdx));
slice3_sd = squeeze(stdSpeedup(:,fixed_ks,:,threadIdx));

nexttile; imagesc(slice3_mu); axis xy
overlayValues(gca, slice3_mu,-1)
xlabel('n'); ylabel('simSize'); title(sprintf('mean, ks = %d', ksValues(fixed_ks)));
set(gca,'XTick',1:length(nValues),'XTickLabel',nValues,'YTick',1:length(simSizes),'YTickLabel',simSizes);
cb = colorbar; cb.Label.String = 'Speedup (%)';
cb.Ticks = linspace(min(slice3_mu(:)), max(slice3_mu(:)), 6);
cb.TickLabels = arrayfun(@(x) sprintf('%.0f%%',(x-1)*100), cb.Ticks, 'UniformOutput', false);

nexttile; imagesc(slice3_sd); axis xy
overlayValues(gca, slice3_sd)
xlabel('n'); ylabel('simSize'); title('std across iterations');
set(gca,'XTick',1:length(nValues),'XTickLabel',nValues,'YTick',1:length(simSizes),'YTickLabel',simSizes);
cb = colorbar; cb.Label.String = 'Std of speedup (%)';
cb.Ticks = linspace(min(slice3_sd(:)), max(slice3_sd(:)), 6);
cb.TickLabels = arrayfun(@(x) sprintf('%.0f%%', x*100), cb.Ticks, 'UniformOutput', false);
%export_fig(f1, 'speedup_slices_fixed_thread_mean_std.png', '-png', '-transparent','-m4', '-r300');

%% --- Max mean speedup & optimal threads (+ std at the optimum) ---
% Use mean across iterations to pick the optimal thread count;
% report both the max(mean) and the std at that argmax.

f2 = figure('Name', 'Max mean speedup, optimal threads, and std @ optimum', 'Position', [100 100 1100 900]);
t2 = tiledlayout(3,3, 'TileSpacing', 'compact', 'Padding', 'compact');
sgtitle(t2, sprintf('Max mean speedup (left), optimal threads (mid), std at optimum (right) [%s]', metricLabel));




% 1) simSize vs ks @ fixed n
slice_all1_mu = squeeze(meanSpeedup(:,:,fixed_n,:));	% [simSize, ks, thread]
slice_all1_sd = squeeze(stdSpeedup(:,:,fixed_n,:));
[maxMu1, maxIdx1] = max(slice_all1_mu, [], 3);

% std at chosen thread index (per cell)
idx1 = sub2ind(size(slice_all1_sd), ...
	repmat((1:size(slice_all1_sd,1))',1,size(slice_all1_sd,2)), ...
	repmat(1:size(slice_all1_sd,2),size(slice_all1_sd,1),1), ...
	maxIdx1);
stdAtOpt1 = slice_all1_sd(idx1);

nexttile; imagesc(maxMu1'); axis xy
overlayValues(gca,maxMu1',-1)
xlabel('simSize'); ylabel('ks'); title(sprintf('Max mean speedup (n = %d)', nValues(fixed_n)));
set(gca,'XTick',1:length(simSizes),'XTickLabel',simSizes,'YTick',1:length(ksValues),'YTickLabel',ksValues);
cb = colorbar; cb.Label.String = 'Speedup (%)';
cb.TickLabels = arrayfun(@(x) sprintf('%.0f%%',(x-1)*100), cb.Ticks, 'UniformOutput', false);

nexttile; imagesc(threadings(maxIdx1)'); axis xy
%overlayValues(gca,threadings(maxIdx1)')
xlabel('simSize'); ylabel('ks'); title(sprintf('Optimal threads (n = %d)', nValues(fixed_n)));
set(gca,'XTick',1:length(simSizes),'XTickLabel',simSizes,'YTick',1:length(ksValues),'YTickLabel',ksValues);
cb = colorbar; cb.Label.String = 'Threads';

nexttile; imagesc(stdAtOpt1'); axis xy
overlayValues(gca,stdAtOpt1')
xlabel('simSize'); ylabel('ks'); title('Std at optimum');
set(gca,'XTick',1:length(simSizes),'XTickLabel',simSizes,'YTick',1:length(ksValues),'YTickLabel',ksValues);
cb = colorbar; cb.Label.String = 'Std of speedup (%)';
cb.TickLabels = arrayfun(@(x) sprintf('%.0f%%', x*100), cb.Ticks, 'UniformOutput', false);

% 2) simSize vs n @ fixed ks
slice_all2_mu = squeeze(meanSpeedup(:,fixed_ks,:,:));	% [simSize, n, thread]
slice_all2_sd = squeeze(stdSpeedup(:,fixed_ks,:,:));
[maxMu2, maxIdx2] = max(slice_all2_mu, [], 3);

idx2 = sub2ind(size(slice_all2_sd), ...
	repmat((1:size(slice_all2_sd,1))',1,size(slice_all2_sd,2)), ...
	repmat(1:size(slice_all2_sd,2),size(slice_all2_sd,1),1), ...
	maxIdx2);
stdAtOpt2 = slice_all2_sd(idx2);

nexttile; imagesc(maxMu2); axis xy
overlayValues(gca,maxMu2,-1)
xlabel('n'); ylabel('simSize'); title(sprintf('Max mean speedup (ks = %d)', ksValues(fixed_ks)));
set(gca,'XTick',1:length(nValues),'XTickLabel',nValues,'YTick',1:length(simSizes),'YTickLabel',simSizes);
cb = colorbar; cb.Label.String = 'Speedup (%)';
cb.TickLabels = arrayfun(@(x) sprintf('%.0f%%',(x-1)*100), cb.Ticks, 'UniformOutput', false);

nexttile; imagesc(threadings(maxIdx2)); set(gca,'ColorScale','log'); axis xy
%overlayValues(gca,threadings(maxIdx2))
xlabel('n'); ylabel('simSize'); title(sprintf('Optimal threads (ks = %d)', ksValues(fixed_ks)));
set(gca,'XTick',1:length(nValues),'XTickLabel',nValues,'YTick',1:length(simSizes),'YTickLabel',simSizes);
cb = colorbar; cb.Label.String = 'Threads';

nexttile; imagesc(stdAtOpt2); axis xy
overlayValues(gca,stdAtOpt2)
xlabel('n'); ylabel('simSize'); title('Std at optimum');
set(gca,'XTick',1:length(nValues),'XTickLabel',nValues,'YTick',1:length(simSizes),'YTickLabel',simSizes);
cb = colorbar; cb.Label.String = 'Std of speedup (%)';
cb.TickLabels = arrayfun(@(x) sprintf('%.0f%%', x*100), cb.Ticks, 'UniformOutput', false);

% 3) ks vs n @ fixed simSize
slice_all3_mu = squeeze(meanSpeedup(fixed_size,:,:,:));	% [ks, n, thread]
slice_all3_sd = squeeze(stdSpeedup(fixed_size,:,:,:));
[maxMu3, maxIdx3] = max(slice_all3_mu, [], 3);

idx3 = sub2ind(size(slice_all3_sd), ...
	repmat((1:size(slice_all3_sd,1))',1,size(slice_all3_sd,2)), ...
	repmat(1:size(slice_all3_sd,2),size(slice_all3_sd,1),1), ...
	maxIdx3);
stdAtOpt3 = slice_all3_sd(idx3);

nexttile; imagesc(maxMu3); axis xy
overlayValues(gca,maxMu3,-1)
xlabel('n'); ylabel('ks'); title(sprintf('Max mean speedup (simSize = %d)', simSizes(fixed_size)));
set(gca,'XTick',1:length(nValues),'XTickLabel',nValues,'YTick',1:length(ksValues),'YTickLabel',ksValues);
cb = colorbar; cb.Label.String = 'Speedup (%)';
cb.TickLabels = arrayfun(@(x) sprintf('%.0f%%',(x-1)*100), cb.Ticks, 'UniformOutput', false);

nexttile; imagesc(threadings(maxIdx3)); axis xy
%overlayValues(gca,threadings(maxIdx3))
xlabel('n'); ylabel('ks'); title(sprintf('Optimal threads (simSize = %d)', simSizes(fixed_size)));
set(gca,'XTick',1:length(nValues),'XTickLabel',nValues,'YTick',1:length(ksValues),'YTickLabel',ksValues);
cb = colorbar; cb.Label.String = 'Threads';

nexttile; imagesc(stdAtOpt3); axis xy
overlayValues(gca,stdAtOpt3)
xlabel('n'); ylabel('ks'); title('Std at optimum');
set(gca,'XTick',1:length(nValues),'XTickLabel',nValues,'YTick',1:length(ksValues),'YTickLabel',ksValues);
cb = colorbar; cb.Label.String = 'Std of speedup (%)';
cb.TickLabels = arrayfun(@(x) sprintf('%.0f%%', x*100), cb.Ticks, 'UniformOutput', false);

%export_fig(f2, 'max_mean_speedup_opt_threads_std.png', '-png', '-transparent','-m4', '-r300');

%%

function overlayValues(ax, data, offset)
    if nargin < 3
        offset=0;
    end
    data=data';
	caxis(ax,'auto');
	lims = caxis(ax);
	midc = mean(lims);

	for i = 1:size(data,1)
		for j = 1:size(data,2)
			v = data(i,j);
			if isnan(v), continue; end
			txtCol = 'w';
			if v > midc, txtCol = 'k'; end
			val = (v+offset)*100;	% your new computation
			if abs(val) < 10
				str = sprintf('%.1f', val);   % one decimal if <10
			else
				str = sprintf('%.0f', val);   % integer if ≥10
			end
			text(ax, i, j, str, ...
				'HorizontalAlignment','center', ...
				'VerticalAlignment','middle', ...
				'Color', txtCol, ...
				'FontSize', 6);
		end
	end
end
