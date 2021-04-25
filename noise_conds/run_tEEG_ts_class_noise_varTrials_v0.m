%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Author: Sean Kelly
%Filename: run_tEEG_ts_class_noise_varTrials_v0.m
%Date: 3/20/21
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
eeg_types = [1,2];
parietal = 1; %Include parietal electrode channels
repetitions = 10; %More accurate representation of clssifier abilities

% sample attributes
nsamp = 9; %all subjects but first, since they have no noise conditions
nfeat = 494; % number of features (timepoints)
time_values = (1:nfeat); % first dim (channels got nuked)

targets = ones(nsamp,1);
chunks = (1:nsamp)';

ntarget_combinations = length(eeg_types);
chance = 1 / ntarget_combinations;

ntrials = 100; %all trials
valid_trials = (3:ntrials); % 3 <= valid_trials <= 100
ntrial_steps = 5; %number of steps between trial size taken in by the classifier
trial_sel = valid_trials(2:ntrial_steps:end); %selected ntrial lengths to examine
len_trial_sel = length(trial_sel);

%Preallocate memory of matrix to store all classification scores generated
total_class_mat = zeros(nsamp,nfeat,len_trial_sel,length(eeg_types)); %9subjects x 494ms x ntrial_sizes x n_eegs

for eeg=1:length(eeg_types)
    for trial_count=1:len_trial_sel
    
        %Runs timeseries classification for each subject
        for subject=1:nsamp
            
            sample_sum = zeros(1,nfeat);
            for rep=1:repetitions
                
                %runs ts classification
                sample_map = tEEG_ts_class_backend_noise_v2(subject+1, noise_pos, eeg, trial_sel(trial_count), parietal); %1class-score x 494timepoints
                sample_sum = sample_sum + sample_map;
            end
            
            %store classification results
            total_class_mat(subject,:,trial_count,eeg) = sample_sum/repetitions; %9subjects x 494cl-performance x ntrials_selected x 2eegs
        end  
    end
end


%calculate average of each subject's classification vector
auc_indiv = zeros(nsamp,length(eeg_types),len_trial_sel); %9subjects * n_eeg_types * ntrials_selected
for eeg=1:length(eeg_types)
    for subject=1:nsamp
        for trial_count=1:len_trial_sel
            auc_indiv(subject,eeg,trial_count) = mean(total_class_mat(subject,:,trial_count,eeg));
        end
    end
end


%Find 95% confidence interval for mean of all subjects AUC x ntrials
%using each participants independent AUC's, for both tEEG and eEEG
confidence_interval_eeg(2,len_trial_sel) = zeros();
for eeg=1:size(eeg_types,2)
    temp_conf_int = ci(auc_indiv(:,eeg,:),95,1);
    confidence_interval_eeg(eeg,:) = squeeze(temp_conf_int)';
end


%Average classification accuracy across all subjects for each timepoint
class_avg = mean(total_class_mat,1); %1 x 494cl-performance x 98trials x 2eegs
class_avg = squeeze(class_avg); %494cl-performance x 98trials x 2eegs

%Preallocate memory to store roc for both tEEG and eEEG
auc = zeros(length(eeg_types),len_trial_sel);  %2eeg_types * 98trials

%calculate integral of each average classification vector
for eeg=1:length(eeg_types) %tEEG and eEEG
    for trial_count=1:len_trial_sel
        %store area under curve for each classification plot for each 
        auc(eeg,trial_count) = mean(class_avg(:,trial_count,eeg)); %2eeg x 98trials
    end
end

%Plot average area under curve for tEEG and eEEG
chance = 0;
color = 'b';
for eeg=1:size(eeg_types,2)
    if eeg == 2
        color = 'r';
    elseif eeg == 3
        color = 'g';
    end
    continuous_error_bars(auc(eeg,:), trial_sel, confidence_interval_eeg(eeg,:), 0, color, 0)
    hold on
end
color = 'b';
for eeg=1:size(eeg_types,2)
    if eeg == 2
        color = 'r';
    elseif eeg == 3
        color = 'g';
    end
    plot(trial_sel, auc(eeg,:), color, 'LineWidth', 3)
end


