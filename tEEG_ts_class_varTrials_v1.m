%Author: Sean Kelly
%Filename: tEEG_ts_class_varTrials_v1.m
%Date: 10/11/20
%
%Purpose: This classifier performs MVPA analyses on tEEG and eEEG data,
% and plots area under curve of tEEG and eEEG classification as ntrials
% decreases from 100->3. The area under the curve represents the 
% integral of classification of above chance large vs small stimuli.
%
%Update from V1: pulls out structure of each subject's classification
% scores for every trial type, and completes ROC analysis afterward.
%
%Runtime: 2eeg_types * 10subjects * (100trials * 12seconds)/2 = ~3.3hrs
%
% * targets: large vs. small checker stimuli
% * chunks: program assumes that every trial is independent
% * trials: each trial is the summation of a given index from each
%   of the 494 epochs
%
%Dependencies: FieldTrip, CosmoMVPA
%
%Example: tEEG_ts_class_varTrials

%Classifier conditions
fix_pos = 1;
ntrials = 100;

% reset citation list
cosmo_check_external('-tic');

time_values = (1:494); % first dim (channels got nuked)
%nsubjects = 10; %all subjects
nsubjects = 1; %debug with only 1 subject to reduce time complexity by 10x

%Preallocate memory to store roc for both tEEG and eEEG
roc(1:2,ntrials-2) = zeros(2,1); %2eeg_types * 98trials

%Preallocate memory of null matrix to reinitialize class_raw_mat
class_raw_mat_zeros(:,size(time_values,2)) = zeros(nsubjects,1); %10subjects x 494ms

%Preallocate memory of matrix to store all classification scores generated
%ts_class_mat(1:nsubjects,size(time_values,2),ntrials-2,2) = zeros(1,1); %10subjects x 494ms x 98trials x 2eegs

%Extract classifier scored for 
for eeg_type=1:2 %tEEG and eEEG

    for trial_count=1:ntrials-2

        %Preallocate memory to store classification of each subject
        class_raw_mat = class_raw_mat_zeros; %10subjects x 494cl_p

        %Runs timeseries classification for each subject
        for subject=1:nsubjects

            %runs ts classification
            sample_map = tEEG_ts_class_backend(subject, fix_pos, eeg_type, trial_count+2); %10subjects x 494(classifier performance)
            %trial_count+2 since 1,2 trials aren't accepted by classifier
            
            class_raw_mat(subject,:) = sample_map; %10subjects x 494(classifier performance)
            %ts_class_mat(subject,:,trial_count,eeg_type) = sample_map; %10subjects x 494cl-performance x 98trials x 2eegs
            
        end
        
        %Average classification accuracy across all subjects for each timepoint
        %class_avg = mean(class_raw_mat,1); %1 x 494cl-performance
        %roc(eeg_type,trial_count) = integral_sl_map(time_values,class_avg)
        
    end
end

%{

%Average classification accuracy across all subjects for each timepoint
class_avg = mean(ts_class_mat(:,:,:,:),1); %1 x 494cl-performance x 98trials x 2eegs

%calculate integral of each average classification vector
for eeg_type=1:2 %tEEG and eEEG
    for trial_count=1:ntrials-2
        %store area under curve for each classification plot for each 
        roc(eeg_type,trial_count) = integral_sl_map(time_values,class_avg(1,:,trial_count,eeg_type)); %2eeg x 98trials
    end
end
%}

figure; %figure to display roc of both eeg types

%Plot average receiving operator characteristic curve for tEEG and eEEG
for eeg_type=1:2
    
    plot((1:ntrials-2),roc(eeg_type,:));
    hold on
end

%Configure individual classification plot
xlim([min(3),max(ntrials)]);
ylabel('Area Under Curve (Class Accuracy * ms)');
xlabel('Trials Used to Train Classifier');
title('ROC Curve: tEEG vs eEEG');
legend('tEEG','eEEG');
MarkPlot('Fix_pos:center');

%{

%calculate integral of each subject's classification vector
roc_indiv(1:10,1:2,ntrials-2) = zeros(2,1); %10subjects * 2eeg_types * 98trials
for subject=1:nsubjects
    
end

%Plot each subject's tEEG vs eEEG ROC curve

%}

