%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Author: Sean Kelly & Pr. Mruczek
%Filename: continuous_error_bars.m
%Date: 10/9/20
%
%Purpose: Plot continous data with similarly continous error bars.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function continuous_error_bars(data_vector, time_vector, error_magnitude, new_fig, color, pl_mean)

    if new_fig
        figure;
    end
    x = time_vector;
    y = data_vector;
    dy = error_magnitude;
    p = fill([x,flip(x)],[y-dy,flip(y+dy)], color); %[.9 .9 .9],'EdgeColor',[.9 .9 .9]);
    p.FaceColor = 'none';%gives filled overlay on plot   
    p.EdgeColor = color; %lines overlap in ts-class-varTrials
    hold on
    %line(x,y,'LineWidth',2) %plot x,y
    if pl_mean == 1
        plot(x,y,color,'LineWidth',2)
    end
    %hline(0,'chance');
end