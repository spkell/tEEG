%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%{
tEEG time-by-time transfer classification

Author: Sean Kelly
Filename: run_tEEG_context_gen_v0.m
Date: 11/12/20

Purpose:
 Script runs MVPA context generalization across time using all subjects.
 The output is a 494x494 matrix displaying performance of a classifier
 trained using either tEEG or eEEG of each time point, and is tested on the
 opposite eeg type at every time point for each time point.

TODO:
    1. Add back other time generalizations with average across participants

%}
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

conds = tEEG_conditions();

fix_pos = 1;
eeg_type = [1,3]; %train with eEEG, test with tEEG
stim_size = [1,2]; %large vs small stimuli target conditions
ntrials = 100;
parietal = 1;

time_values = (1:494); % first dim (channels got nuked)
ntime_values = size(time_values,2);
nsubjects = 10; %all subjects

%Preallocate memory to store classification of each subject
class_raw_mat(nsubjects,ntime_values,ntime_values) = zeros();

for subject=1:nsubjects
    data_sample = tEEG_context_gen_backend(subject, fix_pos, eeg_type, stim_size, ntrials, parietal);
    class_raw_mat(subject,:,:) = data_sample;
end

data = squeeze(mean(class_raw_mat,1));

% show the results
figure()
%imagesc(data, [0.2 1]);
imagesc(flipud(data), [.3 0.8]);

eeg1 = conds.EEG_type{eeg_type(1)};
eeg2 = conds.EEG_type{eeg_type(2)};
eeg_label = strcat(eeg1,'-',eeg2);
title(sprintf('Average Classification Accuracy for %s',eeg_label)); % use_chan_type));
colorbar();

labels = {strcat('train_time','-',eeg1),strcat('test_time','-',eeg2)};

ylabel(strrep(labels{1},'_',' '));
xlabel(strrep(labels{2},'_',' '));
colorbar();

set(gca,'YDir','normal') %flip plot y-axis labels
    
%%%%%%%%%%% END first time generalization