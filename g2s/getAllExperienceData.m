addpath '/Users/mathieugravey/githubProject/G2S/build/matlab-build'

% --- Parameters ---
simSize = [200 200];
kernel = ones([51,51]);
n = 50;
base_seed = 100;
ti = imread('https://raw.githubusercontent.com/GAIA-UNIL/TrainingImagesTIFF/master/stone.tiff');
path = reshape(randperm(prod(simSize)), simSize);

server = '138.232.184.13';
j_values = [1 2 3 4 6 8 12 16 24 32 48 64 96 128];
use_wPO = [false true];
n_iter = 100;	% number of repetitions

%% --- Phase 1: Submit all jobs ---


for iter = 80:n_iter
	fprintf('\n=== Iteration %d / %d ===\n', iter, n_iter);
	curr_seed = base_seed + iter;

	for w = 1:numel(use_wPO)
		for jv = 1:numel(j_values)
			args = {'-sa',server,'-a','qs', ...
					'-ti',ti,'-di',nan(simSize),'-dt',[0], ...
					'-k',1.2,'-n',n,'-ki',kernel, ...
					'-j',j_values(jv),'-sp',path,'-s',curr_seed, ...
					'-submitOnly','-silent'};
			if use_wPO(w)
				args{end+1} = '-wPO';
			end

			jobid = g2s(args{:});
			all_job_table = [all_job_table; {jobid, j_values(jv), use_wPO(w), iter}];
			fprintf('Submitted job %s (j=%d, wPO=%d, iter=%d)\n', jobid, j_values(jv), use_wPO(w), iter);
		end
	end
end

save('submitted_jobs_all2.mat', 'all_job_table');
disp('All jobs submitted and job IDs saved.');

%% --- Phase 2: Download results per iteration ---
load('submitted_jobs_all2.mat');
results_all = {};

for iter = (80:100)
	fprintf('\n=== Downloading results for iteration %d / %d ===\n', iter, n_iter);
	iter_mask =  cell2mat(all_job_table(:,4)) == iter;
	iter_jobs = all_job_table(iter_mask,:);
	results = {}; % {jobid, j, wPO, time, iter}

	for i = 1:size(iter_jobs,1)
		jobid = iter_jobs{i,1};
		jv = iter_jobs{i,2};
		wpo = iter_jobs{i,3};
		fprintf('Downloading result for job %s (j=%d, wPO=%d, iter=%d)\n', jobid, jv, wpo, iter);
		try
			[data, t] = g2s('-sa',server,'-waitAndDownload',jobid);
			results = [results; {jobid, jv, wpo, t, iter}];
		catch ME
			warning('Failed to download job %s: %s', jobid, ME.message);
		end
	end

	save(sprintf('results_iter%d.mat', iter), 'results');
	fprintf('Iteration %d results saved.\n', iter);

	results_all = [results_all; results];
end

save('results_all.mat','results_all');
disp('All results downloaded and saved.');
