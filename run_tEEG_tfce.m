%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%{

Author: Sean Kelly & Pr. Mruczek
Filename: run_tEEG_tfce.m
Date: 11/4/20

Purpose:
 Script runs threshold-free cluster estimation (TFCE) to idenitify
 statistical significance in tEEG vs. eEEG classification ability.

TODO:
    1. allow inputs of either tEEG and or eEEG

    2. update chance line to not include tEEG and eEEG as targets

%}
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%{
%Classifier conditions
fix_pos = 1;
%eeg_type = [2,3]; %Compare EEG type performance
eeg_type = [3,3]; %Compare Parietal omission performance
stim_size = [1,2];
ntrials = 100;
parietal = [0,1]; %Compare Parietal omission performance
%}

%Classifier conditions
fix_pos = 1;
eeg_type = 1; %eeg_type = [1,2];
stim_size = [1,2];
ntrials = 100;
parietal = 1; %Compare Parietal omission performance

conds = tEEG_conditions(); %load names of experimental conditions

ntarget_combinations = length(fix_pos) * length(stim_size); % *length(eeg_type);
chance = 1 / ntarget_combinations;

nsamp = 10; % number of samples (participants)
nfeat = 494; % number of features (timepoints)

%Preallocate memory to store classification of each subject
class_raw_mat(length(eeg_type),nsamp,nfeat) = zeros(); %2eeg_types x 10subjects x 494classification_accuracies

%Runs ts classification for each eeg type
for eeg=1:length(eeg_type)
    
    %Runs timeseries classification for each subject
    for subject=1:nsamp

        %runs ts classification
        sample_map = tEEG_ts_class_backend(subject, fix_pos, eeg_type(eeg), stim_size, ntrials, parietal); %494classification_accuracies              

        class_raw_mat(eeg,subject,:) = sample_map; %2eeg_types x 10subjects x 494classification_accuracies
    end  
end

clear d nh zd
if length(eeg_type) == 1
    d.samples = squeeze(class_raw_mat);
else
    d.samples = [squeeze(class_raw_mat(1,:,:));squeeze(class_raw_mat(2,:,:))]; %20subjects x 494classification_accuracies
end

% feature attributes
d.fa.time = 1:nfeat;
d.a.fdim.labels = {'time'};
d.a.fdim.values = {1:nfeat};

% sample attributes
targets = ones(nsamp,1); % assume one condition (e.g., is decoding above chance for one condition, one type of electrode timecourse)
chunks = (1:nsamp)'; % each participant contributes one sample row of data
if length(eeg_type) == 1
    d.sa.targets = targets;
    d.sa.chunks = chunks;
else
    d.sa.targets = [targets;2*targets];
    d.sa.chunks = [chunks;chunks];
end

% create neighborhood structure, but keep time points independent
nh = cosmo_cluster_neighborhood(d,'time',false); % we don't really want to cluster over anything (which treats multiple time points as a single time point).  we want to treat each time point independently, i think.

% run TFCE (might play around with some options here)
opt = struct(); % reset options structure
opt.cluster_stat = 'tfce';  % Threshold-Free Cluster Enhancement
opt.niter = 10000; % should be near 10k for publication, but can test at lower values
if length(eeg_type) == 1
    opt.h0_mean = chance; % not allowed in 2-tailed tests
end
opt.seed = 1; % should usually not be used, unless exact replication of results is required (keeping for this test script)
opt.progress = true; % let's show for now

zd = cosmo_montecarlo_cluster_stat(d,nh,opt); % returns TFCE-corrected z-score for each column, the results of a one-sample t-test against 0.5

% plot results
f(1) = figure;
hold on

t = 1:nfeat;
if length(eeg_type) == 1
    %plot(t,mean(d.samples),'k'); % mean decoding over time
    confidence_interval = ci(d.samples,95,1);
    continuous_error_bars(mean(d.samples), t, confidence_interval, 0, 'b',1)
else
    plot(t,mean(d.samples(1:10,:)),'b'); % mean decoding over time for tEEG
    plot(t,mean(d.samples(11:20,:)),'r'); % mean decoding over time for eEEG
end
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
if length(eeg_type) == 1 %mean not informative in 2-tailed test
    alpha = 0.05;
    [h,p] = ttest(d.samples,chance); % one-sample t-test (each column separately) against chance (0.5 for 2 targets)
    t_sig = p < alpha; % uncorrected p-value less than alpha = .05
    plot(t(t_sig),alpha*t_sig(t_sig),'.b','MarkerSize',10);
    labels = {'95% conf',conds.EEG_type{eeg_type},'tfce sig','t-test sig'};
else
    labels = {conds.EEG_type{eeg_type(1)},conds.EEG_type{eeg_type(2)},'tfce sig'};
end
legend(labels);

%Label plot with relevent information
fig_title = tEEG_figure_info(0, fix_pos, eeg_type, stim_size, ntrials);
MarkPlot(fig_title);

%{

%Save figure
mat_fig_fpath = strcat('ts_class_outputs/tEEG_tfce/autosave/mat_figs/',fig_title,'.fig');
pdf_fig_fpath = strcat('ts_class_outputs/tEEG_tfce/autosave/pdf_figs/',fig_title,'.pdf');
savefig(f,mat_fig_fpath) %save as matlab figure
orient landscape
print('-dpdf',pdf_fig_fpath) %save as pdf

%}

%{

%%%%% Used to create summary figures %%%%%
t = 1:nfeat;
f = figure();
hold on

plot(t,mean(d.samples(1:9,:)),'b'); % mean decoding over time for tEEG
plot(t,mean(d.samples(10:18,:)),'r'); % mean decoding over time for eEEG

ylim([0 1]);
xlabel('time (ms)');
ylabel('classification accuracy');
title('Classification Accuracy - All Participants');
hline(chance,':k','chance');

% mark location where performance is "significant" by tfce
zd_sig = abs(zd.samples) > 1.96; % two-tailed (this is really an estimate, assuming a large sample size - we need to look up threshold for n=10 for out study)
hold on;
plot(t(zd_sig),.95*zd_sig(zd_sig),'.r','MarkerSize',10);

alpha = 0.05;
[h,p] = ttest(d.samples(1:9,:), d.samples(10:18,:)); % one-sample t-test (each column separately) against chance (0.5 for 2 targets)
t_sig = p < alpha; % uncorrected p-value less than alpha = .05
plot(t(t_sig),alpha*t_sig(t_sig),'.b','MarkerSize',10);
labels = {'eEEG','t-eEEG','tfce sig','t-test sig'};

legend(labels);

orient landscape
print('-dpdf','new_fig') %save as pdf
%}