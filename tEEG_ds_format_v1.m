%Author: Sean Kelly
%Filename: tEEG_ds_format_v2
%Date: 9/28/20
%
%Purpose: Create tEEG dataset structure to use as sample by feature dataset
% for use in CosmoMVPA classifier analysis.
%
% This dataset is specifically structured to examine (e/t)EEG classifier
% performance for one given fixation point to differentiate between
% large and small checker stimuli.
%
%Example: tEEG_ds_format_v1(1,1)

function ds = tEEG_ds_format_v1(subject, fixation_position)

    subjects = {'0341','0976','1419','2630','2785','5469','6541',... %ellipsis
        '6892','8003','9133'};
    subject_id = subjects(subject);
    
    fixation_pos_list = {'Center','LeftCenter','LowerLeft',...
        'LowerRight','RightCenter','UpperLeft','UpperRight'};
    fixation_pos = fixation_pos_list(fixation_position);
    
    %Load data files for both stimuli
    stim = {'large','small'};
    lg_ds = load_tEEG_data(subject_id, stim(1), fixation_pos);
    lg_ds = lg_ds.simian;
    sm_ds = load_tEEG_data(subject_id, stim(2), fixation_pos);
    sm_ds = sm_ds.simian;
   
   %select tEEG for channels 1-6, and eEEG for channels 7-12
   %channel_type = 'tEEG';
   channel_type = 'eEEG';
   if (strcmp(channel_type,'tEEG') == 1)
       lg_ds = lg_ds.data(1:6,:,:);
       sm_ds = sm_ds.data(1:6,:,:);
   else
       lg_ds = lg_ds.data(7:12,:,:);
       sm_ds = sm_ds.data(7:12,:,:);
   end
   
   %reshape dataset
   len_lg_ds = length(lg_ds(1,1,:));
   len_sm_ds = length(sm_ds(1,1,:));
   lg_ds = squeeze(reshape (lg_ds, [], 1, len_lg_ds));
   sm_ds = squeeze(reshape (sm_ds, [], 1, len_sm_ds));
   lg_ds = lg_ds';
   sm_ds = sm_ds';
   
   %initializes samples as large and small data concatenated
   ds.samples = [lg_ds;sm_ds]; %DEBUG: in type single, should be of type double?
   
   %constructs feature attributes of dataset
   ds.fa.chan = repmat((1:6), [1 494]);
   ds.fa.time = repelem((1:494), 6); %be cautious of participant with <494 time_points
   
   %constructs attributes of dataset
   
   %a.fdim.labels and a.eeg
   labels = {'chan','time'};
   ds.a.fdim.labels = labels';
   ds.a.eeg.samples_field = 'trial';
   
   %a.fdim.values
   channels = {'O1', 'Oz', 'O2', 'P3', 'Pz', 'P4'};
   values = {channels, 1:494};
   values = values';
   ds.a.fdim.values = values;
   
   %constructs sample attributes of dataset
   labels_lg = repmat({'large'}, len_lg_ds,1);
   labels_sm = repmat({'small'}, len_sm_ds,1);
   labels = [labels_lg; labels_sm];
   ds.sa.labels = labels;
   
   %each component of each epoch is an independent chunk
   chunks = (1:(len_lg_ds + len_sm_ds));
   ds.sa.chunks = chunks';
   
   %repeats target code (1,2) for the amount of trials in the sample and
   %concatenates them
   targets_lg = repelem(1,len_lg_ds);
   targets_sm = repelem(2,len_sm_ds);
   targets_lg = targets_lg';
   targets_sm = targets_sm';
   targets = [targets_lg; targets_sm];
   ds.sa.targets = targets;
   
   ds.sa.trialinfo(:,1) = targets;
   ds.sa.trialinfo(:,2) = [(1:len_lg_ds)'; (1:len_sm_ds)'];
   
end