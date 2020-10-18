%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Author: Sean Kelly
%Filename: tEEG_conditions.m
%Date: 10/5/20
%
%Purpose: The function outputs a cell structure containing the string 
% representation of each condition in the study
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function conds = tEEG_conditions()

    conds = struct();
    
    conds.subject = {'0341','0976','1419','2630','2785',... %ellipsis
        '5469','6541','6892','8003','9133'};
    
    conds.fix_pos = {'Center','LeftCenter','LowerLeft',...
        'LowerRight','RightCenter','UpperLeft','UpperRight'};
    
    conds.EEG_type = {'tEEG','eEEG'};
    
    conds.stim = {'large','small'};
    
    conds.channel = {'O1', 'Oz', 'O2', 'P3', 'Pz', 'P4'};

end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%{
     1                 2               3            4           5
Participants   Fixation Positions   EEG Type   Stimuli Size   Channel
1:'0341'       1:'Center'           1:'tEEG'   1:'large'      1:'O1'
2:'0976'       2:'LeftCenter'       2:'eEEG'   2:'small'      2:'Oz'
3:'1419'       3:'LowerLeft'                                  3:'O2'
4:'2630'       4:'LowerRight'                                 4:'P3'
5:'2785'       5:'RightCenter'                                5:'Pz'
6:'5469'       6:'UpperLeft'                                  6:'P4'
7:'6541'       7:'UpperRight'
8:'6892'
9:'8003'
10:'9133'
%}