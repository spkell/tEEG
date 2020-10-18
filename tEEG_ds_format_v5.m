%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Author: Sean Kelly
%Filename: tEEG_ds_format_v5.m
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
%Example: tEEG_ds_format_v5(1, [2,5], [1,2], 1, 50)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function ds = tEEG_ds_format_v5(subject, fixation_pos, eeg_type, stim_size, ntrials)
    
    %load string representations of trial parameters in conditions struct
    conditions = tEEG_conditions();
    
    %number of inputs for each parameter
    len_subject = length(subject);
    len_fix_pos = length(fixation_pos);
    len_eeg_type = length(eeg_type);
    len_stim_size = length(stim_size);
    
    ntarget_combinations = length(subject) * length(fixation_pos) * length(eeg_type) * length(stim_size);
    
    %{
    target combinations ex:
     1a 1b 2a 2b 3a 3b
     1a2a3a 1a2a3b 1a2b3a 1a2b3b 1b2a3a 1b2a3b 1b2b3a 1b2b3b
    
    1a 1b 1c 2a 2b
    1a2a 1a2b 1b2a 1b2b 1c2a 1c2b
    %}
    
    %identify parameters to load datasets.
    subject_param = conditions.subject(subject)'; 
    fix_pos_param = conditions.fix_pos(fixation_pos)';
    stim_param = conditions.stim(stim_size);
    
    targ_labels = cell(ntarget_combinations,1);%identify labels for each target condition
    ds_targs = cell(ntarget_combinations,1); %set of target datasets
    
    %load dataset for each target condition
    targ = 1;
    for subj=1:len_subject
        for pos=1:len_fix_pos
            for stim=1:len_stim_size
                temp_ds_targs = load_tEEG_data_v2(subject_param{subj}, fix_pos_param{pos}, stim_param{stim}); %12 chans x 494 timepoints x ~100 trials
                for eeg=1:len_eeg_type % RM: this loop should work, even if len_eeg_type==1
                    switch eeg_type(eeg)
                        case 1 % eeg_type of 1 is tEEG
                            ds_targs{targ} = temp_ds_targs.data(1:6,:,1:ntrials); %TODO: take random mix of trials instead
                        case 2 % eeg_type of 2 is eEEG
                            ds_targs{targ} = temp_ds_targs.data(7:12,:,1:ntrials); %TODO: take random mix of trials instead
                        otherwise
                            error('invalid eeg_type (%d) requested',eeg_type(eeg))
                    end
                    targ_labels{targ} = strcat(conditions.EEG_type{eeg},'_',subject_param{subj},'_',stim_param{stim},'_',fix_pos_param{pos});
                    targ = targ + 1;
                end %6 chans x 494 timepoints x n_trials
            end
        end
    end
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

   nchans = size(ds_targs{1},1); % RM: this is somewhat hardcoded, as it depends on the above selection code.  but should be ok because it should never change

   %Extract number of time points and trials for each stimuli
   ntimepoints = size(ds_targs{1},2); %same for all targets
   
   %reshape dataset for each target combination
   for combo=1:ntarget_combinations
       ds_targs{combo} = squeeze(reshape (ds_targs{combo}, [], 1, ntrials));
       ds_targs{combo} = ds_targs{combo}'; %ntrials X (nchans*ntimepoints)
   end
   
   %combine multiple cell arrays into a single cell
   ds.samples = cat(1, ds_targs{:}); %RM: the range of values is likely ok with single precision, and it will be easier on memory.  but can use double to be cautious (or come back and test out later)
   
   %constructs feature attributes of dataset
   ds.fa.chan = repmat((1:nchans), [1 ntimepoints]);  
   ds.fa.time = repelem((1:ntimepoints), nchans);
   
   %constructs attributes of dataset
   
   %a.fdim.labels and a.eeg
   labels = {'chan','time'};
   ds.a.fdim.labels = labels';
   ds.a.eeg.samples_field = 'trial';
   
   %a.fdim.values
   channels = conditions.channel;
   values = {channels, 0:ntimepoints-1}; % RM: I need to check to see if first time point represents time zero (synchronous with stimulus onset), in which case this might be (1:ntimepoints)-1 to represent time in ms
   values = values';
   ds.a.fdim.values = values;
   
   %constructs sample attributes of dataset
   label_list = repmat(targ_labels',ntrials,1); % do the replication of all lists in one shot
   label_list = label_list(:); % unpack into a single vector (columns get stacked)
   ds.sa.labels = label_list;
   
   %each component of each epoch is an independent chunk
   chunks = (1:(ntarget_combinations * ntrials));
   ds.sa.chunks = chunks';
   
   %repeats target codes for the amount of trials in the sample and concatenates them
   targets = repmat(1:ntarget_combinations,[ntrials 1]); % same as your targets, above
   target_stack = targets(:); % this will convert a mXn matrix into an m*n X 1 vector, stacking each column
   
   ds.sa.targets = target_stack;
   ds.sa.trialinfo(:,1) = target_stack;
   
   trial_info = repmat(1:ntrials,[ntarget_combinations 1])';
   trial_info = trial_info(:);
   
   ds.sa.trialinfo(:,2) = trial_info;
   
end