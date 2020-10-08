%Author: Sean Kelly & Pr. Mruczek
%Filename: tEEG_ds_format_v3.m
%Date: 10/5/20
%
%Purpose: Create tEEG dataset structure to use as sample by feature dataset
% for use in CosmoMVPA classifier analysis.
%
% This dataset is specifically structured to examine (e/t)EEG classifier
% performance for one given fixation point to differentiate between
% large and small checker stimuli.
%
%Example: tEEG_ds_format_v1(1,1,1)

function ds = tEEG_ds_format_v3(subject, fixation_position, channel)

    %identify string
    conditions = tEEG_conditions(subject, fixation_position); % defines list of subjects, and conditions
    
    %Load data files for both stimuli
    stim = {'large','small'};
    lg_ds = load_tEEG_data_v2(conditions{1}, stim{1}, conditions{2});
    lg_ds = lg_ds.simian; %12 chans x 494 timepoints x 100 trials
    sm_ds = load_tEEG_data_v2(conditions{1}, stim{2}, conditions{2}); 
    sm_ds = sm_ds.simian; %12 chans x 494 timepoints x 100 trials
        
   %Select tEEG for channels 1-6, and eEEG for channels 7-12
   %Results in 6 chans x 494 timepoints x 100 trials for lg_ds and sm_ds
   channel_types = {'tEEG', 'eEEG'};  % RM: consider putting this in tEEG_conditions.m
   if strcmp(channel_types{channel},'tEEG')
       lg_ds = lg_ds.data(1:6,:,:);
       sm_ds = sm_ds.data(1:6,:,:);
   else
       lg_ds = lg_ds.data(7:12,:,:);
       sm_ds = sm_ds.data(7:12,:,:);
   end
   nchans = size(lg_ds,1); % RM: this is somewhat hardcoded, as it depends on the above selection code.  but should be ok because it should never change

   %Extract number of time points and trials for each stimuli
   ntimepoints = size(lg_ds,2); %should be same for both lg and sm
   ntrials_lg = size(lg_ds,3);
   ntrials_sm = size(sm_ds,3);

   % RM: here is a good place to trim down to 100 trials (or number
   % requested as an argument)
   
   %reshape dataset
   lg_ds = squeeze(reshape (lg_ds, [], 1, ntrials_lg));
   sm_ds = squeeze(reshape (sm_ds, [], 1, ntrials_sm));
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
   labels_lg = repmat({'large'}, ntrials_lg,1);
   labels_sm = repmat({'small'}, ntrials_sm,1);
   labels = [labels_lg; labels_sm];
   ds.sa.labels = labels;
   
   %each component of each epoch is an independent chunk
   chunks = (1:(ntrials_lg + ntrials_sm));
   ds.sa.chunks = chunks';
   
   %repeats target code (1,2) for the amount of trials in the sample and
   %concatenates them
   targets_lg = repelem(1,ntrials_lg);
   targets_sm = repelem(2,ntrials_sm);
   targets_lg = targets_lg';
   targets_sm = targets_sm';
   targets = [targets_lg; targets_sm];
   ds.sa.targets = targets;
   
   ds.sa.trialinfo(:,1) = targets;
   ds.sa.trialinfo(:,2) = [(1:ntrials_lg)'; (1:ntrials_sm)'];
   
end