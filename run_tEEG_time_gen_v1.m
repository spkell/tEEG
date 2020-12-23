%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%{
tEEG time-by-time transfer classification

Author: Sean Kelly & Pr. Mruczek
Filename: run_tEEG_time_gen_v1.m
Date: 11/9/20

Purpose:
    Script runs MVPA generalization across time using all subjects.

TODO:
    1. Add back other time generalizations with average across participants

%}
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

conds = tEEG_conditions();

fix_pos = 1;
eeg_type = 1;
stim_size = [1,2];
ntrials = 100;
parietal = 1;

time_values = (1:494); % first dim (channels got nuked)
ntime_values = size(time_values,2);
nsubjects = 10; %all subjects

%Preallocate memory to store classification of each subject
class_raw_mat(nsubjects,ntime_values,ntime_values) = zeros();

for subject=1:nsubjects
    data_sample = tEEG_time_gen_backend(subject, fix_pos, eeg_type, stim_size, ntrials, parietal);
    class_raw_mat(subject,:,:) = data_sample;
end

data = squeeze(mean(class_raw_mat,1));

% show the results
figure()
%imagesc(data, [0.2 1]);
imagesc(flipud(data), [.3 0.8]);
title(sprintf('Average Classification Accuracy for %s',conds.EEG_type{eeg_type})); % use_chan_type));
colorbar();

labels = {'train_time','test_time'};

ylabel(strrep(labels{1},'_',' '));
xlabel(strrep(labels{2},'_',' '));
colorbar();

set(gca,'YDir','normal') %flip plot y-axis labels
    
%%%%%%%%%%% END first time generalization