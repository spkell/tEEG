%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Author: Sean Kelly & Pr. Mruczek
%Filename: load_tEEG_data_v2.m
%Date: 10/8/20
%
%Purpose:
% Function loads tEEG data file given subject, fixation position,
% stim as string inputs. Function returns struct containing 
% data pertaining to given params
%
%Example: load_tEEG_data_v2('0341', 'UpperRight', 'large')
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function data = load_tEEG_data_v2(subject, fixation_pos, stim)

    %Sets path for tEEG data
    %Change depending on desired path
    directory_path = '~/Documents/GitHub/tEEG/tEEG_checkerboard_data';
    %directory_path = '~/VNL/projects/tEEG/DataMat'; %dir path in lab

    %Build requested file name in correct path
    fname = ['tEEG_' subject '_' stim '_' fixation_pos '.mat']; % filename (no path)
    fn = fullfile(directory_path,fname);
    
    %checks if parameters match a given file
    if exist(fn,'file')
        fprintf('loading %s...\n',fname);
        simian = load(fname); %file exists, load file
        data = simian.simian;
        fprintf('\tn timepoints = %d\n',size(data.data,2)) %trial info
        fprintf('\tn trials     = %d\n',size(data.data,3))
    else
        error("File (%s) not found in %s",fname,directory_path)
    end
    
    
end %End function

%{
tEEG: 1-6
eEEG: 7-12
O1, Oz, O2, P3, Pz, P4
%}