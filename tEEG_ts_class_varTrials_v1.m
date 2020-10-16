%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
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
%
%TODO: take steps between trials instead of classifying for every 3:ntrials
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% reset citation list
cosmo_check_external('-tic');

%Classifier conditions

nsubjects = 10; %all subjects
%nsubjects = 1; %DEBUG: only 1 subject to reduce time complexity by 10x

fix_pos = 1;
stim_size = [1,2];

%ntrials = 100; %all trials
ntrials = 15; %DEBUG: small number of trials

%retrieve participant conditions
conditions = tEEG_conditions();

time_values = (1:494); % first dim (channels got nuked)

%Preallocate memory of matrix to store all classification scores generated
ts_class_mat(1:nsubjects,size(time_values,2),ntrials-2,2) = zeros(); %10subjects x 494ms x 98trial_sizes x 2eegs

%Extract classifier scored for each trial combination
for eeg_type=1:2 %tEEG and eEEG

    for trial_count=1:ntrials-2

        %Runs timeseries classification for each subject
        for subject=1:nsubjects

            %runs ts classification
            sample_map = tEEG_ts_class_backend(subject, fix_pos, eeg_type, stim_size, trial_count+2); %1subject x 494(classifier performance)
            %trial_count+2 since 1,2 trials aren't accepted by classifier
            
            ts_class_mat(subject,:,trial_count,eeg_type) = sample_map; %10subjects x 494cl-performance x 98trials x 2eegs
        end
    end
end

%{
%DEBUG: 1 subject, makes all subject's data match subject 1
for subject=2:nsubjects
    ts_class_mat(subject,:,:,:) = ts_class_mat(1,:,:,:);
end
%}

%Average classification accuracy across all subjects for each timepoint
class_avg = mean(ts_class_mat,1); %1 x 494cl-performance x 98trials x 2eegs
class_avg = squeeze(class_avg); %494cl-performance x 98trials x 2eegs

%Preallocate memory to store roc for both tEEG and eEEG
roc_zeros(1:2,ntrials-2) = zeros(); %2eeg_types * 98trials
roc = roc_zeros; %resets size in case of larger roc matrix loaded

%calculate integral of each average classification vector
for eeg_type=1:2 %tEEG and eEEG
    for trial_count=1:ntrials-2
        %store area under curve for each classification plot for each 
        roc(eeg_type,trial_count) = integral_sl_map(time_values,class_avg(:,trial_count,eeg_type)); %2eeg x 98trials
    end
end

figure; %figure to display roc of both eeg types

%Plot average receiving operator characteristic curve for tEEG and eEEG
for eeg_type=1:2
    
    plot((1:ntrials-2),roc(eeg_type,:));
    hold on
end

%Configure average classification plot
xlim([min(3),max(ntrials)]);
ylabel('Area Under Curve (Class Accuracy * ms)');
xlabel('Trials Used to Train Classifier');
title('Average ROC Curve: tEEG vs eEEG');
legend('tEEG','eEEG');
figure_title = tEEG_figure_info(0,fix_pos,0,stim_size,0);
MarkPlot(figure_title);
hline(0,'k','chance');

%calculate integral of each subject's classification vector
roc_indiv_zeros(1:nsubjects,1:2,ntrials-2) = zeros(); %10subjects * 2eeg_types * 98trials
roc_indiv = roc_indiv_zeros;
for eeg_type=1:2
    for subject=1:nsubjects
        for trial_count=1:ntrials-2
            roc_indiv(subject,eeg_type,trial_count) = integral_sl_map(time_values,ts_class_mat(subject,:,trial_count,eeg_type));
        end
    end
end

%Plot each subject's tEEG vs eEEG ROC curve separately
figure;
for subject=1:nsubjects
    subplot(ceil(nsubjects/2),2,subject);
    for eeg_type=1:2
        roc_vector = squeeze(roc_indiv(subject,eeg_type,:));
        plot(1:ntrials-2,roc_vector);
        hold on
    end
    
    %Configure individual classification plot
    xlim([min(3),max(ntrials)]);
    ylabel('Classifier Integral'); %Class Accuracy * ms
    xlabel('Trials Used to Train Classifier');
    title_string = strcat('ROC: tEEG vs eEEG // Subject: ', conditions{1}{subject});
    title(title_string);
    legend('tEEG','eEEG');
    hline(0,'k','chance');
    hold off
end

figure_title = tEEG_figure_info(0,fix_pos,0,stim_size,0);
MarkPlot(figure_title);
