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
% stim_size which is extracted from tEEG_conditions(). The 
% additional input is the number of trials that wil be considered for each
% sample.
%
%Example: tEEG_ds_format_v4(1, [2,5], 1, 1, 50)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function ds = tEEG_ds_format_v5(subject, fixation_pos, eeg_type, stim_size, ntrials)
    
    %load string representations of trial parameters
    conditions = tEEG_conditions();
    
    %number of inputs for each parameter
    len_subject = length(subject);
    len_fix_pos = length(fix_pos);
    len_stim_size = length(stim_size);
    
    ntargets = 0;
    if len_subject > 1
        ntargets = ntargets + len_subject;
    end
    if len_fix_pos > 1
        ntargets = ntargets + len_fix_pos;
    end
    if len_stim_size > 1
        ntargets = ntargets + len_stim_size;
    end
    
    %set of target params
    targs = cell(ntargets,1);
    
    %parameters to load datasets.
    %if length(param) > 1, the parameter is a target for the classifier
    
    subject_param = cell(len_subject,1);
    for subj=1:len_subject
        subject_param{subj} = conditions{1}{subject(subj)};
    end
    
    fix_pos_param = cell(len_fix_pos,1);
    for pos=1:len_fix_pos
        fix_pos_param{pos} = conditions{2}{subject(pos)};
    end
    
    stim_param = cell(len_stim_size,1);
    for stim=1:len_stim_size
        stim_param{stim} = conditions{1}{stim_size(stim)};
    end
    
    
    ds_targ1 = load_tEEG_data_v2(subject_param{1}, fix_pos_param{1}, stim_param{1}); %Load data files for both stimuli
    ds_targ2 = load_tEEG_data_v2(subject_param{2}, fix_pos_param{2}, stim_param{2}); %12 chans x 494 timepoints x ~100 trials
    
    %Select tEEG for channels 1-6, and eEEG for channels 7-12
    %Results in 6 chans x 494 timepoints x n_trials for both ds_targs
    if length(eeg_type) == 2 %eeg_type targets
        ds_targ1 = ds_targ1.data(1:6,:,1:ntrials); %TODO: take random mix of trials instead
        ds_targ2 = ds_targ2.data(7:12,:,1:ntrials);
    else
        if eeg_type == 1 %input is tEEG
            ds_targ1 = ds_targ1.data(1:6,:,1:ntrials); %TODO: take random mix of trials instead
            ds_targ2 = ds_targ2.data(1:6,:,1:ntrials);
        else %input is eEEG
            ds_targ1 = ds_targ1.data(7:12,:,1:ntrials);
            ds_targ2 = ds_targ2.data(7:12,:,1:ntrials);
        end
    end
   
   nchans = size(ds_targ1,1); % RM: this is somewhat hardcoded, as it depends on the above selection code.  but should be ok because it should never change

   %Extract number of time points and trials for each stimuli
   ntimepoints = size(ds_targ1,2); %should be same for both targ1 and targ2
   
   %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
   %reshape dataset
   ds_targ1 = squeeze(reshape (ds_targ1, [], 1, ntrials));
   ds_targ2 = squeeze(reshape (ds_targ2, [], 1, ntrials));
   ds_targ1 = ds_targ1'; %ntrials X (nchans*ntimepoints)
   ds_targ2 = ds_targ2';
   
   %initializes samples as large and small data concatenated
   ds.samples = [ds_targ1;ds_targ2]; %DEBUG: in type single, should be of type double? RM: the range of values is likely ok with single precision, and it will be easier on memory.  but can use double to be cautious (or come back and test out later)
   
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
   labels_targ1 = repmat({targs{1}}, ntrials,1);
   labels_targ2 = repmat({targs{2}}, ntrials,1);
   
   size(labels_targ1)
   size(labels_targ2)
   
   labels = [labels_targ1; labels_targ2];
   ds.sa.labels = labels;
   
   %each component of each epoch is an independent chunk
   chunks = (1:(2 * ntrials));
   ds.sa.chunks = chunks';
   
   %repeats target code (1,2) for the amount of trials in the sample and
   %concatenates them
   targets_1 = repelem(1,ntrials);
   targets_2 = repelem(2,ntrials);
   targets_1 = targets_1';
   targets_2 = targets_2';
   targets = [targets_1; targets_2];
   ds.sa.targets = targets;
   
   ds.sa.trialinfo(:,1) = targets;
   ds.sa.trialinfo(:,2) = [(1:ntrials)'; (1:ntrials)'];
   
end