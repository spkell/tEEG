% VNL_lab_startup_SK.m
%
% This is a MATLAB startup file that can be used by Sean's
% personal computer
%
% These commands will get executed when Matlab starts up.  Useful for
% setting the path to specific directories and executing other
% toolbox/package initialization scripts.

fprintf('loading Seans VNL startup file (VNL_lab_startup_SK.m)...');

% custom code
addpath('~/Documents/MATLAB/VNL/shared/Basic');
addpath(genpath('~/Documents/MATLAB/VNL/shared/Plotting'));
addpath('~/Documents/MATLAB/VNL/shared/PTB');
addpath(genpath('~/Documents/MATLAB/VNL/shared/Stats'));
addpath(genpath('~/Documents/MATLAB/VNL/shared/Stim'));
addpath(genpath('~/Documents/MATLAB/VNL/shared/Utility'));

%ADAM
addpath(genpath('/Users/sean/Documents/MATLAB/VNL/ADAM-1.09-beta'));

% EEGLAB
addpath('~/Documents/MATLAB/VNL/eeglab2020');

% CosMoMVPA
tmp_curpath = pwd; % current path
%addpath('~/VNL/Code/CoSMoMVPA/mvpa');
cd ~/Documents/MATLAB/VNL/CoSMoMVPA/mvpa
cosmo_set_path;
cd(tmp_curpath); clear tmp_curpath;


% FieldTrip
addpath('~/Documents/MATLAB/VNL/fieldtrip')
ft_defaults;


% AFNI Matlab Functions
addpath('~/Documents/MATLAB/VNL/afni_matlab')

%VNL projects
addpath(genpath('~/Documents/MATLAB/VNL/projects'))

%tEEG github project
addpath(genpath('~/Documents/GitHub/tEEG'))

fprintf('done!\n');

