%Author: Sean Kelly
%Filename: avg_electrode_freq.m
%Date: 9/21
%
%Purpose:
% returns average frequency of a given electrode every 1ms for ~494ms

%{
function average = avg_freq(time_series)

    average = zeros(1, length(time_series.data(1,:))/100); %initialize average
    avg_temp = 0;
    count = 0;
    
    %Averages every 100 frequency values to give average for every 100ms
    for i=1:length(time_series.data(1,:))
        avg_temp = avg_temp + time_series.data(i);
        count = count + 1;
        if count == 100
            count = 0;
            average(i/100) = avg_temp / 100;
            avg_temp = 0;
        end
    end
    
    
    return
end
%}

function average = avg_electrode_freq(time_series,electrode)
    %average = mean(reshape(time_series.data(electrode,:), 100, []), 1);
    electrode_vector = time_series.data(electrode,:,:);
    average = mean(electrode_vector,3);
    return
end
