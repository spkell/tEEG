%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Author: Sean Kelly & Pr. Mruczek
%Filename: load_tEEG_data_noise_v0.m
%Date: 10/8/20
%
%Purpose:
% Function loads tEEG data file given subject, fixation position,
% stim as string inputs. Function returns struct containing 
% data pertaining to given params
%
%                                  [Center,Clench,Chew]
%Example: load_tEEG_data_v2('0341','Clench')
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function data = load_tEEG_data_noise_v0(subject, noise)

    %Sets path for tEEG data
    %Change depending on desired path
    directory_path = '~/Documents/GitHub/tEEG/tEEG_checkerboard_data';
    %directory_path = '~/VNL/Projects/tEEG/DataMat'; %dir path in lab
    
    if strcmp(noise,'Center') %Center
        stim = 'small';
    else %clench,chew
        stim = 'large';
    end

    %Build requested file name in correct path
    fname = ['tEEG_' subject '_' stim '_' noise '.mat']; % filename (no path)
    fn = fullfile(directory_path,fname);
    
    %checks if parameters match a given file
    if exist(fn,'file')
        fprintf('loading %s...\n',fname);
        simian = load(fn); %file exists, load file
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