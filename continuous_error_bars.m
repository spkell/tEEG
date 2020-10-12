%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Author: Sean Kelly & Pr. Mruczek
%Filename: continuous_error_bars.m
%Date: 10/9/20
%
%Purpose: Plot continous data with similarly continous error bars.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function continuous_error_bars(data_vector, time_vector, error_magnitude, new_fig)

    if new_fig
        figure;
    end
    x = time_vector;
    y = data_vector;
    dy = error_magnitude;
    fill([x,flip(x)],[y-dy,flip(y+dy)],[.9 .9 .9],'EdgeColor',[.9 .9 .9]);
    line(x,y,'LineWidth',2)
    hline(.5,'k:','chance');
end