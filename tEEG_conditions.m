%Author: Sean Kelly
%Filename: tEEG_conditions.m
%Date: 10/5/20
%
%Purpose: Takes input representing index position of tEEG
% participant, fixation position, and stimulus size. The function 
% outputs the string represntation of the input parameters.

function conds = tEEG_conditions(subject, fixation_position)

    subject_list = {'0341','0976','1419','2630','2785','5469',... %ellipsis
        '6541','6892','8003','9133'};
    
    fixation_pos_list = {'Center','LeftCenter','LowerLeft',...
        'LowerRight','RightCenter','UpperLeft','UpperRight'};
    
    subject_id = subject_list{subject};
    fixation_pos = fixation_pos_list{fixation_position};
    
    %Returns pair of subject identifier and fixation position strings
    conds = {subject_id, fixation_pos};
end

%{
Participants        Fixation Positions
1:'0341'            1:'Center'
2:'0976'            2:'LeftCenter'
3:'1419'            3:'LowerLeft'
4:'2630'            4:'LowerRight'
5:'2785'            5:'RightCenter'
6:'5469'            6:'UpperLeft'
7:'6541'            7:'UpperRight'
8:'6892'
9:'8003'
10:'9133'
%}