%Author: Sean Kelly
%Filename: continuous_error_bars.m
%Date: 10/5/20
%
%Purpose: Plot continous data with similarly continous error bars

function continuous_error_bars_RM(data_vector, time_vector, error_magnitude)

    figure;
    x = time_vector;
    y = data_vector;
    dy = error_magnitude;  % made-up error values <-????RM
    fill([x,flip(x)],[y-dy,flip(y+dy)],[.9 .9 .9],'EdgeColor',[.9 .9 .9]);
    line(x,y,'LineWidth',2)
    % hline(.5,'k:','chance');
end