%Author: Sean Kelly
%Filename: tEEG_sl_map_dif.m
%Date: 10/5/20
%
% This programcalculates and plots the difference in classification
% accuracy between any given searchlight outputs of 
% tEEG_timeseries_classification_v2() (i.e. tEEG, eEEG output)

function dif_map = tEEG_sl_map_dif(map_1, map_2)
    
    %finds difference between the 2 maps
    dif_map = map_1.samples - map_2.samples;
    
    time_values = (1:size(dif_map,2));
    
    plot(time_values,dif_map);
    xlim([min(time_values),max(time_values)]);
    ylabel('classification accuracy difference');
    xlabel('time (ms)');
    
end