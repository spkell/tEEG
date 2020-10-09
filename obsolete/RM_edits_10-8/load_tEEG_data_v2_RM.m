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

function simian = load_tEEG_data_v2_RM(subject, stim, fixation_pos)

    %Sets path for tEEG data
    %Change depending on desired path
    %directory_path = '~/Documents/GitHub/tEEG/tEEG_checkerboard_data';
    directory_path = '~/VNL/projects/tEEG/DataMat'; %dir path in lab

    %Build requested file name in correct path
    fname = ['tEEG_' subject '_' stim '_' fixation_pos '.mat']; % filename (no path)
    fn = fullfile(directory_path,fname);
    
    %checks if parameters match a given file
    if exist(fn,'file')
        fprintf('loading %s...\n',fname);
        simian = load(fn); %file exists, load file % RM: this is where we get the extra depth to the simian structure.  the datafile (fn) already has a simian structure.  that structure gets added to the output structure.  alternatively, use >> load(fn,'simian')
        fprintf('\tn timepoints = %d\n',size(simian.simian.data,2))
        fprintf('\tn trials     = %d\n',size(simian.simian.data,3))
    else
        error("File (%s) not found in %s",fname,directory_path)
    end
end %End function

%{
tEEG: 1-6
eEEG: 7-12
O1, Oz, O2, P3, Pz, P4
%}