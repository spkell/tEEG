%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Author: Sean Kelly
%Filename: integral_sl_map.m
%Date: 10/9/20
%
%Purpose: This function takes the integral of an eeg sl_map
% as the area above chance classification.
%
%Example: integral_sl_map((1:494),(1:494))
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function res_integral = integral_sl_map(time,map)
    map = map - 0.5; %normalizes map to represent area under curve, over chance
    F = griddedInterpolant(time,map);
    fun = @(t) F(t);
    res_integral = integral(fun, time(1), time(end));
end