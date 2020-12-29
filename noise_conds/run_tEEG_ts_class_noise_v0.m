%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Author: Sean Kelly
%Filename: run_tEEG_ts_class_noise_v0.m
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
%Example: run_tEEG_ts_class_noise_v0

%TODO: mark plot with accurate labels including each target combination
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%Classifier conditions
noise_pos = [3,1]; %[Clench,Chew]
eeg_type = 2;
ntrials = 100;
parietal = 1; %Include parietal electrode channels

ntarget_combinations = length(noise_pos) * length(eeg_type);
chance = 1 / ntarget_combinations;

% reset citation list
cosmo_check_external('-tic');

time_values = (1:494); % first dim (channels got nuked)
nsubjects = 9; %all subjects but first, since they have no noise conditions

%Preallocate memory to store classification of each subject
class_raw_mat(nsubjects,size(time_values,2)) = zeros();

%Runs timeseries classification for each subject
for subject=2:nsubjects

    %runs ts classification
    sample_map = tEEG_ts_class_backend_noise_v0(subject, noise_pos, eeg_type, ntrials, parietal); %1class-score x 494timepoints
    
    class_raw_mat(subject,:) = sample_map; %10class-score x 494timepoints
end  

f = figure; %New figure

%Plot each subject's classification accuracy on superposition plot
subplot(2,1,1);
for sample=1:size(class_raw_mat,1)
    plot(time_values,class_raw_mat(sample,:));
    hold on
end

%Configure individual classification plot
xlim([min(time_values),max(time_values)]);
ylim([0 1]);
ylabel('classification accuracy');
xlabel('time (ms)');
title('Individual Superposition Classification Accuracy');
hline(chance,'k:','chance');

%Average classification accuracy across all subjects for each timepoint
class_avg = mean(class_raw_mat,1); %1avg-class-score x 494timepoints

%Determine 95% confidence interval of class_avg
%need to take into account <494ms subject
confidence_interval = ci(class_raw_mat,95,1);

%Plot average results with 95% confidence interval overlay in same figure
subplot(2,1,2);
continuous_error_bars(class_avg, time_values, confidence_interval, 0, 'b',1) %Change when superimposing teeg/eeeg externally

%Configure individual classification plot
xlim([min(time_values),max(time_values)]);
ylim([0 1]);
ylabel('classification accuracy');
xlabel('time (ms)');
postfix='Average Classification Accuracy - All Participants';
hline(chance,'k:','chance');
title(postfix);

%Label plot with relevent information
%fig_title = tEEG_figure_info(0, fix_pos, eeg_type, stim_size, ntrials);
conds = tEEG_conditions();
noise_types = {'Center','Clench','Chew'};

fig_title = strcat(conds.EEG_type{eeg_type},'_',noise_types{noise_pos(1)},'_',noise_types{noise_pos(2)});
MarkPlot(fig_title);

%{
%Save figure
mat_fig_fpath = strcat('ts_class_outputs/tEEG_ts_class_v3/autosave/mat_figs/',fig_title,'.fig');
pdf_fig_fpath = strcat('ts_class_outputs/tEEG_ts_class_v3/autosave/pdf_figs/',fig_title,'.pdf');
savefig(f,mat_fig_fpath) %save as matlab figure
orient landscape
print('-dpdf',pdf_fig_fpath) %save as pdf
%}