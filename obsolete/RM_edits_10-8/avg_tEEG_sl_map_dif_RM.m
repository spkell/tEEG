%Author: Sean Kelly
%Filename: avg_tEEG_sl_map_dif.m
%Date: 10/5/20
%
% This programcalculates and plots the difference in classification
% accuracy between any given searchlight outputs of 
% tEEG_timeseries_classification_v2() (i.e. tEEG, eEEG output)

function dif_map = avg_tEEG_sl_map_dif(map_1, map_2)
    
    dif_map = zeros(1,size(map_1.samples, 2));
    
    %finds difference between the 2 maps
    for i = 1:size(map_1.samples, 2) % RM: can this be vectorized?  i need to look at structure of matrices going in, but why not >> map_1.samples - map_2.samples (element-by-element subtraction)
        dif_map(i) = map_1.samples(i) - map_2.samples(i);
    end
    
    time_values = (1:size(dif_map,2));
    
    plot(time_values,dif_map);
    xlim([min(time_values),max(time_values)]);
    ylabel('classification accuracy difference');
    xlabel('time (ms)');
    
end