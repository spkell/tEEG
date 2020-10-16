%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Author: Sean Kelly
%Filename: tEEG_figure_info.m
%Date: 10/15/20
%
%Labels plot with relevent information
%
%Example: tEEG_figure_info(
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function fig_title = tEEG_figure_info(subject, fix_pos, eeg_type, stim_size, ntrials)

    conds = tEEG_conditions();
    targs = {'null','null'};
    params = {'null','null'};
    
    if subject == 0 && ntrials == 0 && eeg_type == 0 %tEEG_ts_class_varTrials_v1.m
        if length(fix_pos) == 2
            targs = {conds{2}{fix_pos(1)}, conds{2}{fix_pos(2)}};
            params = conds{4}{stim_size};
        elseif length(stim_size) == 2
            targs = {conds{4}{stim_size(1)}, conds{4}{stim_size(2)}};
            params = conds{2}{fix_pos};
        end
        fig_title = strcat("Targets: ",targs{1},", ",targs{2}," / Conditions: ",params);

    elseif subject == 0 %plot contains >2 participants // tEEG_timeseries_classification_v3.m
        if length(fix_pos) == 2
            targs = {conds{2}{fix_pos(1)}, conds{2}{fix_pos(2)}};
            params = {conds{3}{eeg_type}, conds{4}{stim_size}};
        elseif length(eeg_type) == 2
            targs = {conds{3}{eeg_type(1)}, conds{3}{eeg_type(2)}};
            params = {conds{2}{fix_pos}, conds{4}{stim_size}};
        elseif length(stim_size) == 2
            targs = {conds{4}{stim_size(1)}, conds{4}{stim_size(2)}};
            params = {conds{2}{fix_pos}, conds{3}{eeg_type}};
        end
        fig_title = strcat("Targets: ",targs{1},", ",targs{2}," / Conditions: ",params{1},", ",params{2},", ",string(ntrials)," Trials");
    
    end
end