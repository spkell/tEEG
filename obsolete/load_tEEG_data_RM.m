%Author: Sean Kelly
%Filename: load_tEEG_data.m
%Date: 9/16/20
%
%Purpose:
% Function loads tEEG data file given subject, stim,
% fixation position, as string inputs. Function returns struct containing 
% data pertaining to given params
% 
% TODO: Some files are improperly named.
%
%Example: load_tEEG_data('0341', 'large', 'UpperRight')

function simian = load_tEEG_data(subject, stim, fixation_pos)

    %Reads names of files into datasets as strings
    directory_path = '~/VNL/projects/tEEG/DataMat'; %Change depending on desired path
    
    
    % consider the following
    fn = fullfile(directory_path,['tEEG_' subject '_' stim '_' fixation_pos '.mat']); % build requested file name, with path
    if exist(fn,'file') % does the file exist?
        simian = load(fn);
    else
        error("No file was located matching the given parameters.")
    end
    
    
%     file_sets = dir(directory_path);
%     dataset = strings(1, length(file_sets)-2); %first 2 file names are . & ..
%     for file = 3:length(file_sets)
%         dataset(file-2) = file_sets(file).name;
%     end
% 
%     %checks if parameters match a given file
%     for file = 1:length(dataset)
%         name = split(dataset(file),"_");
%         mat_file = split(name(4), ".");
%         if subject == name(2) && stim == name(3) && fixation_pos == mat_file(1)
%             
%             %disp(dataset(file));
%             file_path = directory_path + "/" + dataset(file);
%             simian = load(file_path);
%             fclose('all');
%             return
%         end
%     end
%     
%     disp("No file was located matching the given parameters.")
%     return 
    
end %End function

%{
tEEG: 1-6
eEEG: 7-12
O1, Oz, O2, P3, Pz, P4
%}