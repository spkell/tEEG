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
    subject_id = subjects{subject}; % RM: use curly brackets to extract cell contents into embedded data type (here, a string)
    
    fixation_pos_list = {'Center','LeftCenter','LowerLeft',...
        'LowerRight','RightCenter','UpperLeft','UpperRight'};
    fixation_pos = fixation_pos_list{fixation_position}; %%%
    
    %Load data files for both stimuli
    stim = {'large','small'};
    lg_ds = load_tEEG_data_RM(subject_id, stim{1}, fixation_pos); %%%
    lg_ds = lg_ds.simian;  % RM: add some comments here : nchans X ntimepoints X ntrials
    sm_ds = load_tEEG_data_RM(subject_id, stim{2}, fixation_pos); %%%
    sm_ds = sm_ds.simian;
   
    % RM: extract some useful info (need to this for both lg and sm
    % separately, as ntrials in particular may change - as with 0341
    % center
    ntimepoints = size(lg_ds.data,2);
    ntrials     = size(lg_ds.data,3);
    
    % HERE, NTRIALS DIFFERS FOR LG AND SM DATASETS, SO MY CODE ISN'T GOING TO WORK WELL
    
   %select tEEG for channels 1-6, and eEEG for channels 7-12
   %channel_type = 'tEEG';
   channel_type = 'eEEG'; %%% suggest add this as an argument into this function for easy switching
   if strcmp(channel_type,'tEEG') % RM: strcmp already returns a logical result, no need for the == 1 part
       lg_ds = lg_ds.data(1:6,:,:);
       sm_ds = sm_ds.data(1:6,:,:);
   else
       lg_ds = lg_ds.data(7:12,:,:);
       sm_ds = sm_ds.data(7:12,:,:);
   end
   nchans = size(lg_ds,1); % RM: this is somewhat hardcoded, as it depends on the above selection code.  but should be ok because it should never change

   
   %reshape dataset
   len_lg_ds = length(lg_ds(1,1,:));  % RM: use size(lg_ds,3) to get length of a specific matrix dimension
   len_sm_ds = length(sm_ds(1,1,:));  % RM: rename these variables to be more descriptive - ntrials_lg and ntrials_sm
   lg_ds = squeeze(reshape (lg_ds, [], 1, len_lg_ds));
   sm_ds = squeeze(reshape (sm_ds, [], 1, len_sm_ds));
   lg_ds = lg_ds'; % RM: add some comments here : ntrials X (nchans*ntimepoints)
   sm_ds = sm_ds';
   
   %initializes samples as large and small data concatenated
   ds.samples = [lg_ds;sm_ds]; %DEBUG: in type single, should be of type double? RM: the range of values is likely ok with single precision, and it will be easier on memory.  but can use double to be cautious (or come back and test out later)
   
   %constructs feature attributes of dataset          % RM: may want to construct these in the full 3D matrix space, to be sure order is correct
   ds.fa.chan = repmat((1:nchans), [1 ntimepoints]);  % RM: pull the 494 from the data loaded initially so not hardcoded
   ds.fa.time = repelem((1:ntimepoints), nchans); %be cautious of participant with <494 time_points
   
   %constructs attributes of dataset
   
   %a.fdim.labels and a.eeg
   labels = {'chan','time'};
   ds.a.fdim.labels = labels';
   ds.a.eeg.samples_field = 'trial';
   
   %a.fdim.values
   channels = {'O1', 'Oz', 'O2', 'P3', 'Pz', 'P4'};
   values = {channels, 0:ntimepoints-1}; % RM: I need to check to see if first time point represents time zero (synchronous with stimulus onset), in which case this might be (1:ntimepoints)-1 to represent time in ms
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