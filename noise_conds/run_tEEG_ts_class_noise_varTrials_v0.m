%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Author: Sean Kelly
%Filename: run_tEEG_ts_class_noise_varTrials_v0.m
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
%Example: run_tEEG_ts_class_noise_varTrials_v0.m

%TODO: mark plot with accurate labels including each target combination
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%Classifier conditions
noises = {'Center','Clench','Chew'};
noise_pos = 2; %[Center,Clench,Chew]
eeg_type = [1,2];
parietal = 1; %Include parietal electrode channels

% sample attributes
nsamp = 9; %all subjects but first, since they have no noise conditions
nfeat = 494; % number of features (timepoints)
time_values = (1:nfeat); % first dim (channels got nuked)

targets = ones(nsamp,1);
chunks = (1:nsamp)';

ntarget_combinations = length(eeg_type);
chance = 1 / ntarget_combinations;

ntrials = 100; %all trials
valid_trials = (3:ntrials); % 3 <= valid_trials <= 100
ntrial_steps = 5; %number of steps between trial size taken in by the classifier
trial_sel = valid_trials(2:ntrial_steps:end); %selected ntrial lengths to examine
len_trial_sel = length(trial_sel);

%Preallocate memory of matrix to store all classification scores generated
ts_class_mat(1:nsamp,nfeat,len_trial_sel,length(eeg_type)) = zeros(); %9subjects x 494ms x ntrial_sizes x n_eegs

%Preallocate memory to store classification of each subject
class_raw_mat(length(eeg_type),nsamp,nfeat) = zeros();

for eeg=1:length(eeg_type)
    for trial_count=1:len_trial_sel
    
        %Runs timeseries classification for each subject
        for subject=1:nsamp

            %runs ts classification
            %sample_map = tEEG_ts_class_backend_noise_v1(subject+1, noise_pos, eeg, ntrials, parietal); %1class-score x 494timepoints
            sample_map = tEEG_ts_class_backend_noise_v2(subject+1, noise_pos, eeg, ntrials, parietal); %1class-score x 494timepoints

            ts_class_mat(subject,:,trial_count,eeg) = sample_map; %9subjects x 494cl-performance x ntrials_selected x 2eegs
        end  
    end
end


%calculate integral of each subject's classification vector
roc_indiv_zeros(1:nsamp,length(eeg_type),len_trial_sel) = zeros(); %9subjects * n_eeg_types * ntrials_selected
roc_indiv = roc_indiv_zeros;
for eeg=1:length(eeg_type)
    for subject=1:nsamp
        for trial_count=1:len_trial_sel
            roc_indiv(subject,eeg,trial_count) = integral_sl_map(time_values,ts_class_mat(subject,:,trial_count,eeg));
        end
    end
end


%Average classification accuracy across all subjects for each timepoint
class_avg = mean(ts_class_mat,1); %1 x 494cl-performance x 98trials x 2eegs
class_avg = squeeze(class_avg); %494cl-performance x 98trials x 2eegs

%Preallocate memory to store roc for both tEEG and eEEG
roc_zeros(1:2,len_trial_sel) = zeros(); %2eeg_types * 98trials
roc = roc_zeros; %resets size in case of larger roc matrix loaded

%calculate integral of each average classification vector
for eeg=1:length(eeg_type) %tEEG and eEEG
    for trial_count=1:len_trial_sel
        %store area under curve for each classification plot for each 
        roc(eeg,trial_count) = integral_sl_map(time_values,class_avg(:,trial_count,eeg)); %2eeg x 98trials
    end
end
