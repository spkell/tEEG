%Author: Sean Kelly
%Filename: tEEG_ds_format_v0.m
%Date: 9/24/20
%
%Purpose: Create tEEG dataset structure containing all data from tEEG
% experiment. Dataset is not correctly formatted for use as sample by 
% feature dataset in CosmoMVPA classifier analysis, but it illustrates
% a complete structure to the experimental data.
%
%Example: tEEG_ds_format_v0()

function tEEG_dataset_samples = tEEG_ds_format_v0()
    
    subjects = {'0341','0976','1419','2630','2785','5469','6541',... %ellipsis
        '6892','8003','9133'};
    
    stim = {'large','small'};
    
    fixation_pos = {'Center','LeftCenter','LowerLeft',...
        'LowerRight','RightCenter','UpperLeft','UpperRight'};
    
    for id=1:length(subjects)
        
        clear subject_set %contains all samples for a given subject // represent chunks?
        for checker=1:length(stim)
            
            clear stim_set %array of structs storing each fixation_pos time_series for a given subject and given stim
            for pos=1:length(fixation_pos)

                time_series = load_tEEG_data(subjects(id), stim(checker), fixation_pos(pos));
                stim_set(pos).name = fixation_pos(pos);
                stim_set(pos).fixation_pos = time_series.simian; %append time_series to stim_set
            end
            
            subject_set(checker).name = stim(checker); %If I initialize size of array, struct of dissimilar size is returned... repmat()?
            subject_set(checker).stim = stim_set;
        end
        
        %tEEG_dataset_samples contains subject set for every subject
        tEEG_dataset_samples(id).name = subjects(id);
        tEEG_dataset_samples(id).sample = subject_set;
    end
end