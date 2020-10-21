%Author: Sean Kelly
%Filename: plot_tEEG_electrode_avg.m
%Date: 9/21
%
%Purpose: 
% loads data with given characteristics and plots a specific
% electrode's average frequency over the course of 49.4 seconds
%                               ('0341','large','Center', 1)
%Example: plot_tEEG_electrode_avg(1,1,1,1)
%
%TODO: change directory path in load_tEEG_data()

function plot_tEEG_electrode_avg(subject, fixation_pos, stim, electrode)
    
    conds = tEEG_conditions();
    time_series = load_tEEG_data_v2(conds.subject{subject}, conds.stim{stim}, conds.fix_pos{fixation_pos});
    
    %finds average frequency of a given channel every 1ms for ~494ms
    electrode_vector = time_series.data(electrode,:,:);
    average = mean(electrode_vector,3);

    ax = axes;
    ax.XAxisLocation = 'origin';
    hold on
    plot(average)
    hold off
    
    return
    
end