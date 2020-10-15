%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Author: Sean Kelly
%Filename: tEEG_ds_format_v4.m
%Date: 10/15/20
%
%Purpose: Create tEEG dataset structure to use as sample by feature dataset
% for use in CoSMoMVPA classifier analysis.
%
% This dataset is structured to examine (e/t)EEG classifier performance
% for any given pair of targets.
%
% Function takes integer params of subject, fix_pos, and EEG_type,
% stim_size which will be extracted from tEEG_conditions(). The 
% additional input is the number of trials that wil be considered for each
% sample.
%
%Example: tEEG_ds_format_v1(
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function ds = tEEG_ds_format_v4(subject, fixation_pos, eeg_type, stim_size, ntrials)
    

    %load string representations of trial parameters
    conditions = tEEG_conditions();

    %targets number corresponds to which condition input parameters are
    % structured as a set containing 2 values to be treated as the 2
    % targets of the classifier
    switch targets
        
        case 1 %subject targets
            
            subject_param = {conditions{1}{subject(1)}, conditions{1}{subject(2)}};
            fix_pos_param = {conditions{2}{fixation_pos}, conditions{2}{fixation_pos}};
            stim_param = {conditions{4}{stim_size}, conditions{4}{stim_size}};
            
        case 2 %fixation_pos targets
            
            subject_param = {conditions{1}{subject}, conditions{1}{subject}};
            fix_pos_param = {conditions{2}{fixation_pos(1)}, conditions{2}{fixation_pos(1)}};
            stim_param = {conditions{4}{stim_size}, conditions{4}{stim_size}};
            
        case 3 %eeg_type targets (tEEG vs eEEG)
            
            subject_param = {conditions{1}{subject}, conditions{1}{subject}};
            fix_pos_param = {conditions{2}{fixation_pos}, conditions{2}{fixation_pos}};
            stim_param = {conditions{4}{stim_size}, conditions{4}{stim_size}};
            
        case 4 %stim_size targets
            
            subject_param = {conditions{1}{subject}, conditions{1}{subject}};
            fix_pos_param = {conditions{2}{fixation_pos}, conditions{2}{fixation_pos}};
            stim_param = {conditions{4}{stim_size(1)}, conditions{4}{stim_size(2)}};
            
        otherwise %error catch
            error("Error: Only 1 param must be input as set E.g. (1, [1,2], 1, 1, 100, 2)")
            
    end
    
    if length(subject) == 2 %subject targets
        subject_param = {conditions{1}{subject(1)}, conditions{1}{subject(2)}};
        fix_pos_param = {conditions{2}{fixation_pos}, conditions{2}{fixation_pos}};
        stim_param = {conditions{4}{stim_size}, conditions{4}{stim_size}};
        
    elseif length(fixation_pos) == 2 %fixation_pos targets
        subject_param = {conditions{1}{subject}, conditions{1}{subject}};
        fix_pos_param = {conditions{2}{fixation_pos(1)}, conditions{2}{fixation_pos(1)}};
        stim_param = {conditions{4}{stim_size}, conditions{4}{stim_size}};
        
    elseif length(eeg_type) == 2 %eeg_type targets (tEEG vs eEEG)
        %N/A
        
    elseif length(stim_size) == 2 %stim_size targets
        subject_param = {conditions{1}{subject}, conditions{1}{subject}};
        fix_pos_param = {conditions{2}{fixation_pos}, conditions{2}{fixation_pos}};
        stim_param = {conditions{4}{stim_size(1)}, conditions{4}{stim_size(2)}};
        
    else %error catch
        error("Error: 1 param must be input as set E.g. (1, [1,2], 1, 1, 100)") 
    end
    
    
    ds_targ1 = load_tEEG_data_v2(subject_param{1}, fix_pos_param{1}, stim_param{1}); %Load data files for both stimuli
    ds_targ2 = load_tEEG_data_v2(subject_param{2}, fix_pos_param{2}, stim_param{2}); %12 chans x 494 timepoints x ~100 trials
    
    %Select tEEG for channels 1-6, and eEEG for channels 7-12
    %Results in 6 chans x 494 timepoints x n_trials for lg_ds and sm_ds
    if eeg_type == 1 %input is tEEG
        ds_targ1 = ds_targ1.data(1:6,:,1:ntrials); %TODO: take random mix of trials instead
        ds_targ2 = ds_targ2.data(1:6,:,1:ntrials);
    else %input is eEEG
        ds_targ1 = ds_targ1.data(7:12,:,1:ntrials);
        ds_targ2 = ds_targ2.data(7:12,:,1:ntrials);
    end
    
    subject_id = conditions{1}{subject};
    fix_pos = conditions{2}{fixation_pos};
    stim = conditions{4}; %can use as function parameter
    
    
   %Select tEEG for channels 1-6, and eEEG for channels 7-12
   %Results in 6 chans x 494 timepoints x n_trials for lg_ds and sm_ds
   if eeg_type == 1 %input is tEEG
       lg_ds = lg_ds.data(1:6,:,1:ntrials); %TODO: take random mix of trials instead
       sm_ds = sm_ds.data(1:6,:,1:ntrials);
   else %input is eEEG
       lg_ds = lg_ds.data(7:12,:,1:ntrials);
       sm_ds = sm_ds.data(7:12,:,1:ntrials);
   end
   
   %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
   
   nchans = size(lg_ds,1); % RM: this is somewhat hardcoded, as it depends on the above selection code.  but should be ok because it should never change

   %Extract number of time points and trials for each stimuli
   ntimepoints = size(lg_ds,2); %should be same for both lg and sm
    
   %reshape dataset
   lg_ds = squeeze(reshape (lg_ds, [], 1, ntrials));
   sm_ds = squeeze(reshape (sm_ds, [], 1, ntrials));
   lg_ds = lg_ds'; %ntrials X (nchans*ntimepoints)
   sm_ds = sm_ds';
   
   %initializes samples as large and small data concatenated
   ds.samples = [lg_ds;sm_ds]; %DEBUG: in type single, should be of type double? RM: the range of values is likely ok with single precision, and it will be easier on memory.  but can use double to be cautious (or come back and test out later)
   
   %constructs feature attributes of dataset          % RM: may want to construct these in the full 3D matrix space, to be sure order is correct
   ds.fa.chan = repmat((1:nchans), [1 ntimepoints]);  % RM: pull the 494 from the data loaded initially so not hardcoded
   ds.fa.time = repelem((1:ntimepoints), nchans);
   
   %constructs attributes of dataset
   
   %a.fdim.labels and a.eeg
   labels = {'chan','time'};
   ds.a.fdim.labels = labels';
   ds.a.eeg.samples_field = 'trial';
   
   %a.fdim.values
   channels = conditions{5};
   values = {channels, 0:ntimepoints-1}; % RM: I need to check to see if first time point represents time zero (synchronous with stimulus onset), in which case this might be (1:ntimepoints)-1 to represent time in ms
   values = values';
   ds.a.fdim.values = values;
   
   %constructs sample attributes of dataset
   labels_lg = repmat(stim{1}, ntrials,1);
   labels_sm = repmat(stim{2}, ntrials,1);
   labels = [labels_lg; labels_sm];
   ds.sa.labels = labels;
   
   %each component of each epoch is an independent chunk
   chunks = (1:(2 * ntrials));
   ds.sa.chunks = chunks';
   
   %repeats target code (1,2) for the amount of trials in the sample and
   %concatenates them
   targets_lg = repelem(1,ntrials);
   targets_sm = repelem(2,ntrials);
   targets_lg = targets_lg';
   targets_sm = targets_sm';
   targets = [targets_lg; targets_sm];
   ds.sa.targets = targets;
   
   ds.sa.trialinfo(:,1) = targets;
   ds.sa.trialinfo(:,2) = [(1:ntrials)'; (1:ntrials)'];
   
end