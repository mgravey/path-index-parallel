%% --- Merge and plot partial or full results ---
clear; clc;

files = dir('results_iter*.mat');
if isempty(files)
	error('No results_iter*.mat files found in this folder.');
end

all_results = {};
for f = 1:numel(files)
	try
		load(files(f).name, 'results');
		if exist('results','var') && ~isempty(results)
			all_results = [all_results; results];
			fprintf('Loaded %s (%d entries)\n', files(f).name, size(results,1));
		else
			warning('File %s is empty or invalid.', files(f).name);
		end
	catch ME
		warning('Failed to load %s: %s', files(f).name, ME.message);
	end
end

if isempty(all_results)
	error('No valid results found to plot.');
end

% Save combined results
save('results_combined.mat','all_results');

%% --- Plot mean ± std ---
js_all = cell2mat(all_results(:,2));
wpo_all = cell2mat(all_results(:,3));
times_all = cell2mat(all_results(:,4));

figure('Name','G2S performance','NumberTitle','off'); hold on;
for w = [0 1]
	js_unique = unique(js_all);
	mean_t = zeros(size(js_unique));
	std_t = zeros(size(js_unique));
	for i = 1:numel(js_unique)
		mask = (js_all == js_unique(i)) & (wpo_all == w);
		if any(mask)
			mean_t(i) = mean(times_all(mask));
			std_t(i) = std(times_all(mask));
		else
			mean_t(i) = NaN;
			std_t(i) = NaN;
		end
	end
	errorbar(js_unique, mean_t, std_t, '-o', 'DisplayName', sprintf('wPO=%d', w));
end

set(gca, 'XScale', 'log', 'YScale', 'log');
xlabel('Parallelization level (-j) [log scale]');
ylabel('Computation time (s) [log scale]');
legend show
title('G2S performance (mean ± std) — log-log view');
grid on;


%% --- Compute aggregated stats and visualize results ---
js_all = cell2mat(all_results(:,2));
wpo_all = cell2mat(all_results(:,3));
times_all = cell2mat(all_results(:,4));

js_unique = unique(js_all);
mean_t = nan(numel(js_unique),2); % column 1 = no wPO, 2 = wPO
std_t  = nan(numel(js_unique),2);

for i = 1:numel(js_unique)
	for w = [0 1]
		mask = (js_all == js_unique(i)) & (wpo_all == w);
		if any(mask)
			mean_t(i,w+1) = mean(times_all(mask));
			std_t(i,w+1)  = std(times_all(mask));
		end
	end
end

% Compute gain in %
gain_percent = 100 * (mean_t(:,1) - mean_t(:,2)) ./ mean_t(:,1);

%% --- Create combined figure ---
figure('Name','G2S Performance and Gain','NumberTitle','off', ...
	'Units','normalized','Position',[0.1 0.1 0.7 0.75]);

set(groot, 'DefaultAxesFontSize', 24, ...
	'DefaultLineLineWidth', 2, ...
	'DefaultErrorBarLineWidth', 2, ...
	'DefaultLineMarkerSize', 10, ...
	'DefaultLegendFontSize', 20, ...
	'DefaultTextFontSize', 24);

% Compute 5th and 95th percentile per j and wPO
p5_t  = nan(numel(js_unique),2);
p95_t = nan(numel(js_unique),2);

for i = 1:numel(js_unique)
	for w = [0 1]
		mask = (js_all == js_unique(i)) & (wpo_all == w);
		if any(mask)
			tvals = times_all(mask);
			p5_t(i,w+1)  = prctile(tvals,5);
			p95_t(i,w+1) = prctile(tvals,95);
		end
	end
end


%% --- Subplot 1: Performance curves with min–max shaded range ---
subplot(2,1,1);
hold on;

colors = lines(2); % MATLAB's default color palette for consistent line colors

for w = [0 1]
	% Compute polygon for shaded range
	x_fill = [js_unique; flipud(js_unique)];
	y_fill = [p95_t(:,w+1); flipud(p5_t(:,w+1))];
	
	% Draw shaded area behind the line
	h = fill(x_fill, y_fill, colors(w+1,:), ...
		'FaceAlpha', 0.25, 'EdgeColor', 'none');
	uistack(h, 'bottom'); % send fill below line
	
	% Plot mean curve on top
	plot(js_unique, mean_t(:,w+1), '-o', ...
		'LineWidth', 1.5, ...
		'Color', colors(w+1,:), ...
		'DisplayName', sprintf('wPO = %d', w));
end

set(gca, 'XScale','log', 'YScale','log');
set(gca, 'XTick', js_unique, 'XTickLabel', string(js_unique));
ylabel('Computation time (s)');
title('G2S performance (mean ± range)');
legend('Location','best');
grid on;

% Auto-fit axes tightly to actual data range
valid_t = [p5_t(:); p95_t(:)];
valid_t = valid_t(~isnan(valid_t));
if ~isempty(valid_t)
	xlim([min(js_unique) max(js_unique)]);
	ylim([min(valid_t)*0.9, max(valid_t)*1.1]);
end



%% --- Subplot 2: Gain percentage with min–max shaded range ---
subplot(2,1,2);
hold on;

% Compute gain for each iteration and each j
iters_all = cell2mat(all_results(:,5)); % iteration index from results_{iter}.mat
js_unique = unique(js_all);
n_iter = max(iters_all);

gain_all = nan(numel(js_unique), n_iter); % gain per j and iteration

for i = 1:numel(js_unique)
	for iter = 1:n_iter
		mask_no  = (js_all == js_unique(i)) & (wpo_all == 0) & (iters_all == iter);
		mask_wpo = (js_all == js_unique(i)) & (wpo_all == 1) & (iters_all == iter);

		if any(mask_no) && any(mask_wpo)
			t_no  = mean(times_all(mask_no));
			t_wpo = mean(times_all(mask_wpo));
			gain_all(i,iter) = 100 * (t_no - t_wpo) / t_no;
		end
	end
end

% Compute mean, min, max across iterations
mean_gain = nanmean(gain_all,2);
min_gain  = prctile(gain_all',5)';
max_gain  = prctile(gain_all',95)';

% Shaded range (min–max)
x_fill = [js_unique; flipud(js_unique)];
y_fill = [max_gain; flipud(min_gain)];
fill(x_fill, y_fill, [0.3 0.7 1], 'FaceAlpha',0.25, 'EdgeColor','none');
uistack(findobj(gca,'Type','patch'),'bottom');

% Mean gain line
semilogx(js_unique, mean_gain, '-s', ...
	'LineWidth', 1.5, ...
	'MarkerFaceColor','auto', ...
	'Color',[0 0.447 0.741]); % consistent MATLAB blue

xlabel('Parallelization level (-j)');
ylabel('Gain from wPO (%)');
title('Relative computation time gain using -wPO');
grid on;

% Fit axes tightly to data
valid_gain = [min_gain; max_gain];
valid_gain = valid_gain(~isnan(valid_gain));
if ~isempty(valid_gain)
	xlim([min(js_unique) max(js_unique)]);
	ylim([min(valid_gain)*0.9, max(valid_gain)*1.1]);
end

% Mean gain line
h_line = semilogx(js_unique, mean_gain, '-s', ...
	'LineWidth', 1.5, ...
	'MarkerFaceColor','auto', ...
	'Color',[0 0.447 0.741]); % consistent MATLAB blue

% Add legend for blue line and light blue shaded range
h_patch = findobj(gca,'Type','patch');
legend([h_line h_patch(1)], {'Mean gain', '5–95% range'}, 'Location', 'best');
set(gca, 'XScale','log');
set(gca, 'XTick', js_unique, 'XTickLabel', string(js_unique));

% --- Export figure as high-quality image ---
outname = 'G2S_Performance_and_Gain.png';
export_fig(outname, '-r300', '-transparent'); % 300 dpi, transparent background
fprintf('Figure exported to %s\n', outname);