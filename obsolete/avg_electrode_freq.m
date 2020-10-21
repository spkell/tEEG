%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Author: Sean Kelly & Pr. Mruczek
%Filename: avg_electrode_freq.m
%Date: 9/21
%
%Purpose:
% returns average frequency of a given electrode every 1ms for ~494ms
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function average = avg_electrode_freq(time_series,electrode)
    electrode_vector = time_series.data(electrode,:,:);
    average = mean(electrode_vector,3);
end
