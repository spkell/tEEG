%Author: Sean Kelly
%Filename: plot_tEEG_electrode_avg.m
%Date: 9/21
%
%Purpose: 
% loads data with given characteristics and plots a specific
% electrode's average frequency over the course of 49.4 seconds
%
%Example: plot_tEEG_electrode_avg('0341','large','Center', 1)
%
%TODO: change directory path in load_tEEG_data()

function plot_tEEG_electrode_avg_RM(subject, stim, fixation_pos, electrode)
    
    time_series = load_tEEG_data(subject, stim, fixation_pos);
    
    %finds average frequency of a given electrode every 1ms for ~494ms
    average = avg_electrode_freq(time_series,electrode);
    
    ax = axes;
    ax.XAxisLocation = 'origin';
    hold on
    plot(average)
    hold off
    
    return
    
end