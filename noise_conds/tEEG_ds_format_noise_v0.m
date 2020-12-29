%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Author: Sean Kelly
%Filename: tEEG_ds_format_noise_v0.m
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
%                                    [clench large, small]
%Example: tEEG_ds_format_noise_v0(1, [2,1], 1, 100, 0)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function ds = tEEG_ds_format_noise_v0(subject, noise_pos, eeg_type, ntrials_request, parietal)

    %load string representations of trial parameters in conditions struct
    conditions = tEEG_conditions();
    
    %number of inputs for each parameter
    len_subject = length(subject);
    len_noise_pos = length(noise_pos);
    len_eeg_type = length(eeg_type);
    
    %ntrials_total = 100; %some participants have a couple more, 76 for 1419_large_RightCenter
    
    ntarget_combinations = length(subject) * length(noise_pos) * length(eeg_type);
    
    %{
    target combinations ex:
     1a 1b 2a 2b 3a 3b
     1a2a3a 1a2a3b 1a2b3a 1a2b3b 1b2a3a 1b2a3b 1b2b3a 1b2b3b
    
    1a 1b 1c 2a 2b
    1a2a 1a2b 1b2a 1b2b 1c2a 1c2b
    %}
    
    noise_types = {'Center','Clench','Chew'};
    
    %identify parameters to load datasets.
    subject_param = conditions.subject(subject)'; 
    noise_pos_param = noise_types(noise_pos)';
    
    targ_labels = cell(ntarget_combinations,1);%identify labels for each target condition
    ds_targs = cell(ntarget_combinations,1); %set of target datasets
    
    %load dataset for each target condition
    targ = 1;
    for subj=1:len_subject
        for pos=1:len_noise_pos
            temp_ds_targs = load_tEEG_data_noise_v0(subject_param{subj}, noise_pos_param{pos}); %12 chans x 494 timepoints x ~100 trials
            for eeg=1:len_eeg_type % RM: this loop should work, even if len_eeg_type==1
                rand_trials = randperm(size(temp_ds_targs.data,3)); %ideally ntrials_total // tEEG_1419_large_RightCenter.mat: ntrials = 76
                rand_trials = rand_trials(1:ntrials_request);

                if parietal == 1
                    switch eeg_type(eeg)
                        case 1 % eeg_type of 1 is tEEG
                            ds_targs{targ} = temp_ds_targs.data(1:6,:,rand_trials);
                        case 2 % eeg_type of 2 is eEEG
                            ds_targs{targ} = temp_ds_targs.data(7:12,:,rand_trials);
                        case 3 % eeg_type of 2 is tEEG and eEEG
                            ds_targs{targ} = temp_ds_targs.data(:,:,rand_trials);
                        otherwise
                            error('invalid eeg_type (%d) requested',eeg_type(eeg))
                    end
                elseif parietal == 0
                    switch eeg_type(eeg)
                        case 1 % eeg_type of 1 is tEEG
                            ds_targs{targ} = temp_ds_targs.data(1:3,:,rand_trials);
                        case 2 % eeg_type of 2 is eEEG
                            ds_targs{targ} = temp_ds_targs.data(7:9,:,rand_trials);
                        case 3 % eeg_type of 2 is tEEG and eEEG
                            ds_targs{targ} = temp_ds_targs.data([1:3,7:9],:,rand_trials);
                        otherwise
                            error('invalid eeg_type (%d) requested',eeg_type(eeg))
                    end

                end
                if pos > 1 %clench,chew
                    stim = 'large';
                else %Center
                    stim = 'small';
                end
                targ_labels{targ} = strcat(conditions.EEG_type{eeg},'_',subject_param{subj},'_',stim,'_',noise_pos_param{pos});
                targ = targ + 1;
            end %6 chans x 494 timepoints x n_trials_request
        end
    end
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

   nchans = size(ds_targs{1},1); % RM: this is somewhat hardcoded, as it depends on the above selection code.  but should be ok because it should never change
   %ds.fa.chan can only use integers (1:6)
   
   %Extract number of time points and trials for each stimuli
   ntimepoints = size(ds_targs{1},2); %same for all targets
   
   %reshape dataset for each target combination
   for combo=1:ntarget_combinations
       ds_targs{combo} = squeeze(reshape (ds_targs{combo}, [], 1, ntrials_request));
       ds_targs{combo} = ds_targs{combo}'; %ntrials_request X (nchans*ntimepoints)
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
   if nchans == 12 %combined tEEG/eEEG
       channels = [channels;channels];
   end
   values = {channels, 0:ntimepoints-1}; % RM: I need to check to see if first time point represents time zero (synchronous with stimulus onset), in which case this might be (1:ntimepoints)-1 to represent time in ms
   values = values';
   ds.a.fdim.values = values;
   
   %constructs sample attributes of dataset
   label_list = repmat(targ_labels',ntrials_request,1); % do the replication of all lists in one shot
   label_list = label_list(:); % unpack into a single vector (columns get stacked)
   ds.sa.labels = label_list;
   
   %each component of each epoch is an independent chunk
   chunks = (1:(ntarget_combinations * ntrials_request));
   ds.sa.chunks = chunks';
   
   %repeats target codes for the amount of trials in the sample and concatenates them
   targets = repmat(1:ntarget_combinations,[ntrials_request 1]); % same as your targets, above
   target_stack = targets(:); % this will convert a mXn matrix into an m*n X 1 vector, stacking each column
   
   ds.sa.targets = target_stack;
   ds.sa.trialinfo(:,1) = target_stack;
   
   trial_info = repmat(1:ntrials_request,[ntarget_combinations 1])';
   trial_info = trial_info(:);
   
   ds.sa.trialinfo(:,2) = trial_info;
   
end