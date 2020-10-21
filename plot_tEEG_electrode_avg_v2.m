%Author: Sean Kelly
%Filename: plot_tEEG_electrode_avg_v2.m
%Date: 9/21
%
%Purpose: 
% loads data with given characteristics and plots a specific
% electrode's average frequency over the course of 49.4 seconds
%
%                 subj2, large, center, all-tEEG-chans, set-axes
%Example: plot_tEEG_electrode_avg(2,1,1,[1:6],1)
%
%TODO: change directory path in load_tEEG_data()

function val = plot_tEEG_electrode_avg_v2(subject, stim, fixation_pos, electrode, set_axes)
    
    %loads file with given conditions
    conds = tEEG_conditions();
    time_series = load_tEEG_data_v2(conds.subject{subject}, conds.stim{stim}, conds.fix_pos{fixation_pos});
    
    %finds average frequency of a given channel every 1ms for ~494ms
    electrode_vector = time_series.data(electrode,:,:); %nchans x 494ms * 100 epochs
    avg_electrode_vector = mean(electrode_vector,3); %nchans x 494ms // mean of amplitude of epoch for selected channels
    average = mean(avg_electrode_vector,1); %1 x 494ms  // mean of amplitude over selected channels

    val = {electrode_vector, avg_electrode_vector, average};
    if set_axes == 1
        figure;
        ax = axes;
        ax.XAxisLocation = 'origin';
        plot(average)
        hline(0)
        hold on
        ylabel('Amplitude (mV)'); %mV amplitude?
        xlabel('time (ms)');
        postfix='Average Timeseries';
        title(postfix);
    else
        plot(average)
        hold on
    end
    
    return
    
end