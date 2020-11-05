%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%{

Author: Sean Kelly & Pr. Mruczek
Filename: run_tEEG_tfce.m
Date: 11/4/20

Purpose:
 Script runs threshold-free cluster estimation (TFCE) to idenitify
 statistical significance in tEEG vs. eEEG classification ability.

TODO:
    1. Produce dataset of 10 subjects x 494 classification accuracies, and
    run tfce to determine statistic significance of tEEG and eEEG above
    chance classification separately.
    
    2. Produce t/eEEG datasets in same script and use one dataset as the
    mean? This doesn't take the variablilty of the "mean" dataset into
    account, only the variability of the query dataset's mean...

%}
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%{
% make a fake dataset using randomized data
clear d nh zd
nsamp = 10; % number of samples (participants)
nfeat = 100; % number of features (timepoints)
d.samples = rand([nsamp nfeat]); % random data, centered around 0.5 (e.g., chance decoding)

% add an offset to artificially force more significant time points
offset = .25;
d.samples = d.samples + offset;
%}

%Classifier conditions
fix_pos = 1;
eeg_type = 1;
stim_size = (1:2);
ntrials = 100;

ntarget_combinations = length(fix_pos) * length(eeg_type) * length(stim_size);
chance = 1 / ntarget_combinations;

nsamp = 10; % number of samples (participants)
nfeat = 494; % number of features (timepoints)

%Preallocate memory to store classification of each subject
class_raw_mat(nsamp,nfeat) = zeros();

%Runs timeseries classification for each subject
for subject=1:nsamp

    %runs ts classification
    sample_map = tEEG_ts_class_backend(subject, fix_pos, eeg_type, stim_size, ntrials); %1class-score x 494timepoints
    
    class_raw_mat(subject,:) = sample_map; %10class-score x 494timepoints
end  

clear d nh zd
d.samples = class_raw_mat;

% feature attributes
d.fa.time = 1:nfeat;
d.a.fdim.labels = {'time'};
d.a.fdim.values = {1:nfeat};

% sample attributes
d.sa.targets = ones(nsamp,1); % assume one condition (e.g., is decoding above chance for one condition, one type of electrode timecourse)
d.sa.chunks = (1:nsamp)'; % each participant contributes one sample row of data

% create neighborhood structure, but keep time points independent
nh = cosmo_cluster_neighborhood(d,'time',false); % we don't really want to cluster over anything (which treats multiple time points as a single time point).  we want to treat each time point independently, i think.

% run TFCE (might play around with some options here)
opt = struct(); % reset options structure
opt.cluster_stat = 'tfce';  % Threshold-Free Cluster Enhancement
opt.niter = 1000; % should be near 10k for publication, but can test at lower values
opt.h0_mean = chance;
opt.seed = 1; % should usually not be used, unless exact replication of results is required (keeping for this test script)
opt.progress = true; % let's show for now

zd = cosmo_montecarlo_cluster_stat(d,nh,opt); % returns TFCE-corrected z-score for each column, the results of a one-sample t-test against 0.5

% plot results
f(1) = figure;

% random order (so expect no clusters)
t = 1:nfeat;
plot(t,mean(d.samples)); % mean decoding over time
ylim([0 1]);
xlabel('time (ms)');
ylabel('classification accuracy');
title('Classification Accuracy - All Participants');
hline(chance,':k','chance');

% mark location where performance is "significant" by tfce
zd_sig = abs(zd.samples) > 1.96; % two-tailed (this is really an estimate, assuming a large sample size - we need to look up threshold for n=10 for out study)
hold on;
plot(t(zd_sig),.95*zd_sig(zd_sig),'.r','MarkerSize',10);

% mark locations where performance is "significant" by uncorrected t-tests
alpha = 0.05;
[h,p] = ttest(d.samples,chance); % one-sample t-test (each column separately) against chance (0.5 for 2 targets)
t_sig = p < alpha; % uncorrected p-value less than alpha = .05
plot(t(t_sig),alpha*t_sig(t_sig),'.b','MarkerSize',10);

%Label plot with relevent information
fig_title = tEEG_figure_info(0, fix_pos, eeg_type, stim_size, ntrials);
MarkPlot(fig_title);

%Save figure
file_name = strcat('ts_class_outputs/tEEG_tfce/autosave/',fig_title,'.fig');
savefig(f,file_name)