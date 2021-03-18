%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Author: Sean Kelly
%Filename: run_tEEG_ts_class_noise_tfce_v0.m
%Date: 12/29/20
%
%Purpose: This classifier performs MVPA analyses on tEEG and eEEG data.
% 1 plot is produced containing a superposition of all 10 subjects, and
% another plot containing the average classification performance for each
% time point.
%
% * targets: subjects OR fix_pos OR eeg_type OR stim_size
% * chunks: program assumes that every trial is independent
% * trials: each trial is the summation of a given index from each
%   of the 494 epochs
%
%Dependencies: FieldTrip, CosmoMVPA
%
%Example: run_tEEG_ts_class_noise_tfce_v0

%TODO: mark plot with accurate labels including each target combination
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%Classifier conditions
noises = {'Center','Clench','Chew'};
noise_pos = 3; %[Center,Clench,Chew]
eeg_type = [1,2];
ntrials = 100;
parietal = 1; %Include parietal electrode channels

% sample attributes
nsamp = 9; %all subjects but first, since they have no noise conditions
nfeat = 494; % number of features (timepoints)
time_values = (1:nfeat); % first dim (channels got nuked)

targets = ones(nsamp,1);
chunks = (1:nsamp)';

ntarget_combinations = length(eeg_type);
chance = 1 / ntarget_combinations;

repetitions = 10; %number of times to repeat classification

%Preallocate memory to store classification of each subject
class_raw_mat(length(eeg_type),nsamp,nfeat) = zeros();

for eeg=1:length(eeg_type)
    
    %Runs timeseries classification for each subject
    for subject=1:nsamp
        
        sample_map_sum = zeros(1,nfeat);
        for rep=1:repetitions
            %runs ts classification
            sample_map = tEEG_ts_class_backend_noise_v2(subject+1, noise_pos, eeg_type(eeg), ntrials, parietal); %1class-score x 494timepoints
            sample_map_sum = sample_map_sum + sample_map; %9class-score x 494timepoints
        end
        class_raw_mat(eeg,subject,:) = sample_map_sum/repetitions;
        
    end  
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%tfce
clear d nh zd
d.samples = [squeeze(class_raw_mat(1,:,:));squeeze(class_raw_mat(2,:,:))]; %18subjects x 494classification_accuracies

% feature attributes
d.fa.time = 1:nfeat;
d.a.fdim.labels = {'time'};
d.a.fdim.values = {1:nfeat};

d.sa.targets = [targets;2*targets];
d.sa.chunks = [chunks;chunks];

nh = cosmo_cluster_neighborhood(d,'time',true); % create neighborhood structure, but keep time points independent

opt = struct(); % reset options structure
opt.cluster_stat = 'tfce';  % Threshold-Free Cluster Enhancement
opt.niter = 10000;

opt.progress = true;
zd = cosmo_montecarlo_cluster_stat(d,nh,opt); % returns TFCE-corrected z-score for each column

% plot results
f(1) = figure;
hold on
t = 1:nfeat;

%Matches eeg type to corresponding plot color
colors = {'b','r','g'}; %tEEG, eEEG, teEEG 
plot(t,mean(d.samples(1:9,:)),colors{eeg_type(1)}); % mean decoding over time for EEG type 1
plot(t,mean(d.samples(10:18,:)),colors{eeg_type(2)}); % mean decoding over time for EEG type 2

ylim([0 1]);
xlabel('time (ms)');
ylabel('classification accuracy');
title('Classification Accuracy - All Participants');
hline(chance,':k','chance');

% mark location where performance is "significant" by tfce
zd_sig = abs(zd.samples) > 1.96; % two-tailed (this is really an estimate, assuming a large sample size - we need to look up threshold for n=10 for out study)
hold on;
plot(t(zd_sig),.95*zd_sig(zd_sig),'.r','MarkerSize',10);

EEG_types = {'tEEG','eEEG','t+eEEG'};
labels = {EEG_types{eeg_type(1)},EEG_types{eeg_type(2)},'tfce'}; 
legend(labels);
fig_title = strcat('tEEG_vs_eEEG_',noises{noise_pos},'_trials:',string(ntrials));
MarkPlot(fig_title);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%{
%Save figure
mat_fig_fpath = strcat('ts_class_outputs/tEEG_ts_class_v3/autosave/mat_figs/',fig_title,'.fig');
pdf_fig_fpath = strcat('ts_class_outputs/tEEG_ts_class_v3/autosave/pdf_figs/',fig_title,'.pdf');
savefig(f,mat_fig_fpath) %save as matlab figure
orient landscape
print('-dpdf',pdf_fig_fpath) %save as pdf
%}