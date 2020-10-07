%Author: Sean Kelly & Pr. Mruczek
%Filename: load_tEEG_data_v2.m
%Date: 10/5/20
%
%Purpose:
% Function loads tEEG data file given subject, stim,
% fixation position, as string inputs. Function returns struct containing 
% data pertaining to given params
%
%Example: load_tEEG_data_v2('0341', 'large', 'UpperRight')

function simian = load_tEEG_data_v2(subject, stim, fixation_pos)

    %Sets path for tEEG data
    directory_path = '/Users/sean/Documents/MATLAB/VNL/projects/tEEG/tEEG_checkerboard_data'; %Change depending on desired path
    %directory_path = '~/VNL/projects/tEEG/DataMat'; %dir path in lab

    %Build requested file name in correct path
    fn = fullfile(directory_path,['tEEG_' subject '_' stim '_' fixation_pos '.mat']);
    
    %checks if parameters match a given file
    if exist(fn,'file')
        simian = load(fn); %file exists, load file
    else
        error("No file was located matching the given parameters.")
    end
    
    
end %End function

%{
tEEG: 1-6
eEEG: 7-12
O1, Oz, O2, P3, Pz, P4
%}