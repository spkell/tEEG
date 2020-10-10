%Author: Sean Kelly
%Filename: tEEG_timeseries_classification_v3.m
%Date: 10/8/20
%
%Purpose: This classifier performs MVPA analyses on tEEG and eEEG data.
% 1 plot is produced containing a superposition of all 10 subjects, and
% another plot containing the average classification performance for each
% time point.
%
% * targets: large vs. small checker stimuli
% * chunks: program assumes that every trial is independent
% * trials: each trial is the summation of a given index from each
%   of the 494 epochs
%
%Dependencies: FieldTrip, CosmoMVPA
%
%Example: tEEG_timeseries_classification_v3

%Classifier conditions
fix_pos = 1;
eeg_type = 1;
ntrials = 10;

% reset citation list
cosmo_check_external('-tic');

time_values = (1:494); % first dim (channels got nuked)
nsubjects = 10; %all subjects

%Preallocate memory to store classification of each subject
class_raw_mat(:,size(time_values,2)) = zeros(nsubjects,1);

%Runs timeseries classification for eacvh subject
for subject=1:nsubjects

    %runs ts classification
    sample_map = tEEG_ts_class_backend(subject, fix_pos, eeg_type, ntrials);
    
    class_raw_mat(subject,:) = sample_map;
end  

figure; %New figure

%Plot each subject's classification accuracy on superposition plot
subplot(2,1,1);
for sample=1:size(class_raw_mat,1)
    plot(time_values,class_raw_mat(sample,:));
    hold on
end

%Configure individual classification plot
xlim([min(time_values),max(time_values)]);
ylabel('classification accuracy (chance=.5)');
xlabel('time (ms)');
title('Individual Superposition Classification Accuracy');

%Average classification accuracy across all subjects for each timepoint
class_avg = mean(class_raw_mat,1);

%Determine 95% confidence interval of class_avg
%need to take into account <494ms subject
confidence_interval = ci(class_raw_mat,95,1);

%Plot average results with 95% confidence interval overlay in same figure
subplot(2,1,2);
continuous_error_bars(class_avg, time_values, confidence_interval, 0)

%Configure individual classification plot
xlim([min(time_values),max(time_values)]);
ylabel('classification accuracy (chance=.5)');
xlabel('time (ms)');
postfix='Average Classification Accuracy - All Participants';
title(postfix);