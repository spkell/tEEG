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
    len_fix_pos = length(fixation_pos);
    len_eeg_type = length(eeg_type);
    len_stim_size = length(stim_size);
    
    ntarget_combinations = 1; %identify number of combinations of targets
    
    if len_subject > 1
        ntarget_combinations = ntarget_combinations * len_subject;
    end
    if len_fix_pos > 1
        ntarget_combinations = ntarget_combinations * len_fix_pos;
    end
    if len_eeg_type > 1
        ntarget_combinations = ntarget_combinations * len_eeg_type;
    end
    if len_stim_size > 1
        ntarget_combinations = ntarget_combinations * len_stim_size;
    end
    
    %{
    target combinations ex:
     1a 1b 2a 2b 3a 3b
     1a2a3a 1a2a3b 1a2b3a 1a2b3b 1b2a3a 1b2a3b 1b2b3a 1b2b3b
    
    1a 1b 1c 2a 2b
    1a2a 1a2b 1b2a 1b2b 1c2a 1c2b
    %}
    
    %identify parameters to load datasets.
    %if length(param) > 1, the parameter is a target for the classifier
    subject_param = cell(len_subject,1);
    for subj=1:len_subject
        subject_param{subj} = conditions{1}{subject(subj)};
    end
    
    fix_pos_param = cell(len_fix_pos,1);
    for pos=1:len_fix_pos
        fix_pos_param{pos} = conditions{2}{fixation_pos(pos)};
    end
    
    stim_param = cell(len_stim_size,1);
    for stim=1:len_stim_size
        stim_param{stim} = conditions{4}{stim_size(stim)};
    end
    
    targ_labels = cell(ntarget_combinations,1);%identify labels for each target condition
    
    ds_targs = cell(ntarget_combinations,1); %set of target datasets
    
    %load dataset for each target condition
    targ = 1;
    for subj=1:len_subject
        for pos=1:len_fix_pos
            for stim=1:len_stim_size
                temp_ds_targs = load_tEEG_data_v2(subject_param{subj}, fix_pos_param{pos}, stim_param{stim}); %12 chans x 494 timepoints x ~100 trials
                if len_eeg_type == 1
                    if eeg_type == 1 %input is tEEG
                        ds_targs{targ} = temp_ds_targs.data(1:6,:,1:ntrials); %TODO: take random mix of trials instead
                    else %input is eEEG
                        ds_targs{targ} = temp_ds_targs.data(7:12,:,1:ntrials);
                    end
                    targ_labels{targ} = strcat(conditions{3}{eeg_type},'_',subject_param{subj},'_',stim_param{stim},'_',fix_pos_param{pos});
                    targ = targ + 1;
                else
                    for eeg=1:len_eeg_type 
                        ds_targs{targ} = temp_ds_targs.data(1:6,:,1:ntrials); %TODO: take random mix of trials instead
                        targ_labels{targ} = strcat(conditions{3}{eeg},'_',subject_param{subj},'_',stim_param{stim},'_',fix_pos_param{pos});
                        targ = targ + 1;
                    end %6 chans x 494 timepoints x n_trials
                end
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
   
   %initializes samples as concatenated target datasets
   temp_sample = ds_targs{1};
   for combo=2:ntarget_combinations
       temp_sample = [temp_sample;ds_targs{combo}]; %how to preallocate this or stack ds from each cell?
   end

   ds.samples = temp_sample; %DEBUG: in type single, should be of type double? RM: the range of values is likely ok with single precision, and it will be easier on memory.  but can use double to be cautious (or come back and test out later)
   
   %constructs feature attributes of dataset
   ds.fa.chan = repmat((1:nchans), [1 ntimepoints]);  
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
   label_list = cell(ntarget_combinations,1);
   for combo=1:ntarget_combinations
       label_list{combo} = repmat({targ_labels{combo}},ntrials,1); %{A{i}} == A(i) matlab automatic suggestion?
   end 
   
   temp_labels = label_list{1};
   for combo=2:ntarget_combinations
       temp_labels = [temp_labels; label_list{combo}]; %how to preallocate this or stack ds from each cell?
   end

   ds.sa.labels = temp_labels;
   
   %each component of each epoch is an independent chunk
   chunks = (1:(ntarget_combinations * ntrials));
   ds.sa.chunks = chunks';
   
   %repeats target codes for the amount of trials in the sample and
   %concatenates them
   targets = zeros(ntarget_combinations,ntrials);
   for combo=1:ntarget_combinations
       targets(combo,:) = combo;
   end
   targets = targets';
   
   target_stack = targets(:,1);
   for combo=2:ntarget_combinations
       target_stack = [target_stack; targets(:,combo)]; %how to preallocate this or stack ds from each matrix?
   end
   
   ds.sa.targets = target_stack;
   
   ds.sa.trialinfo(:,1) = target_stack;
   
   trial_info = (1:ntrials)';
   for combo=2:ntarget_combinations
       trial_info = [trial_info; (1:ntrials)']; %how to preallocate this or stack ds from each array?
   end
   
   ds.sa.trialinfo(:,2) = trial_info;
   
end