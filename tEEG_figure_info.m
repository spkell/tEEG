%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Author: Sean Kelly
%Filename: tEEG_figure_info.m
%Date: 10/15/20
%
%Produces file name and labels plot with relevent information.
%subject = 0 indicates all subjects param
%
%Example: tEEG_figure_info(1,[2,5],1,[1,2],50)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function fig_title = tEEG_figure_info(subject, fix_pos, eeg_type, stim_size, ntrials)

    conds = tEEG_conditions();
    
    len_subject = length(subject);
    len_fix_pos = length(fix_pos);
    len_eeg_type = length(eeg_type);
    len_stim_size = length(stim_size);
    
    nparams = 0;
    if len_subject == 1
        nparams = nparams + 1;
    end
    if len_fix_pos == 1
        nparams = nparams + 1;
    end
    if len_eeg_type == 1
        nparams = nparams + 1;
    end
    if len_stim_size == 1
        nparams = nparams + 1;
    end
    
    ntarget_combinations = len_subject * len_fix_pos * len_eeg_type * len_stim_size;
    
    targs = cell(ntarget_combinations,1);
    params = cell(nparams,1);
    targ_idx = 1;
    param_idx = 1;
    
    %Identify which conditions are targets or static parameters
    
    if len_subject > 1 %Subject
        for subj=1:len_subject
            targs{targ_idx} = conds.subject{subject(subj)};
            targ_idx = targ_idx + 1;
        end
    elseif len_subject == 1
        if subject == 0 %not a target, but fig includes all subjects
            params{param_idx} = 'all-subjects';
        else
            params{param_idx} = conds.subject{subject};
        end
        param_idx = param_idx + 1;
    end
    
    if len_fix_pos > 1 %Fixation Position
        for pos=1:len_fix_pos
            targs{targ_idx} = conds.fix_pos{fix_pos(pos)};
            targ_idx = targ_idx + 1;
        end
    else
        params{param_idx} = conds.fix_pos{fix_pos};
        param_idx = param_idx + 1;
    end
    
    if len_eeg_type > 1 %tEEG or eEEG
        for eeg=1:len_eeg_type
            if eeg_type(eeg) == 3
                targs{targ_idx} = 'tEEG_eEEG';
            else
                targs{targ_idx} = conds.EEG_type{eeg_type(eeg)};
            end
            targ_idx = targ_idx + 1;
        end
    elseif len_eeg_type == 1
        if eeg_type == 0 %not a target, but fig includes both eeg types
            params{param_idx} = 'tEEG-eEEG';
        elseif eeg_type == 3 %eeg type is both tEEG and eEEG in same struct
            params{param_idx} = 'tEEG+eEEG';
        else
            params{param_idx} = conds.EEG_type{eeg_type};
        end
        param_idx = param_idx + 1;
    end
    
    if len_stim_size > 1 %large or small stim
        for stim=1:len_stim_size
            targs{targ_idx} = conds.stim{stim_size(stim)};
            targ_idx = targ_idx + 1;
        end
    else
        params{param_idx} = conds.stim{stim_size};
    end
        
    
    targ_str = 'Targets(';
    for targ=1:length(targs)
        if targ == 1
            targ_str = strcat(targ_str, targs{targ});
        else
            targ_str = strcat(targ_str,'+', targs{targ});
        end
    end
    targ_str = strcat(targ_str,')');
    
    param_str = 'Conditions(';
    for param=1:length(params)
        if param == 1
            param_str = strcat(param_str, params{param});
        else
            param_str = strcat(param_str,'+', params{param});
        end
    end
    
    trial_len = strcat(string(ntrials),'-Trials');
    if ntrials == 0
        trial_len = 'var-trials';
    end
    
    param_str = strcat(param_str,'+',trial_len,')');
    
    fig_title = strcat(targ_str,'_',param_str);
        
end