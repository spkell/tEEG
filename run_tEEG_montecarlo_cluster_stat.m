%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Author: Sean Kelly
%Filename: run_tEEG_montecarlo_cluster_stat.m
%Date: 10/21/20
%
%Purpose: Perform Anova on tEEG timeseries to derive statistical
% significance in channel amplitude at given timepoints
%
%TODO: 1. How does this analysis perform a statistical test on classifier
% performance when its input requires a sample by feature dataset?
% 2. How do I generalize the anova to show significance in all 6 channels
% vs 1 in a timeseries?
% 3. What does the output tell us about the targets in the ds?
%
%Example: run_tEEG_montecarlo_cluster_stat
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%Dataset Parameters
subject = 2;
fixation_pos = 1;
eeg_type = 1;
stim_size = [1,2];
ntrials_request = 100;

ds = tEEG_ds_format_v5(subject, fixation_pos, eeg_type, stim_size, ntrials_request);

nbrhood = cosmo_cluster_neighborhood(ds);

niter = 1000; %publication quality: 1,000 <= niter <= 10,000
ds_z=cosmo_montecarlo_cluster_stat(ds,nbrhood,'niter',100); %1 x 2964

z_scores_chans = reshape(ds_z.samples,6,494); %6 x 494

z_scores(1:length(z_scores_chans)) = zeros();

for timepoint=1:length(z_scores_chans)
    max = 0;
    min = 0;
    for chan=1:size(z_scores_chans,1)
        if z_scores_chans(chan,timepoint) > 1.96 %1 tailed or 2 tailed?
            max = z_scores_chans(chan,timepoint);
        elseif z_scores_chans(chan,timepoint) < -1.96
            min = z_scores_chans(chan,timepoint);
        end
    end
    if abs(max) > abs(min)
        z_scores(timepoint) = 1;
    elseif abs(max) < abs(min)
        z_scores(timepoint) = -1;
    else
        z_scores(timepoint) = 0;
    end
end

figure;

plot(z_scores);