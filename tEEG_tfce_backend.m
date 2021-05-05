%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%{

Author: Sean Kelly & Pr. Mruczek
Filename: tEEG_tfce_backend.m
Date: 11/14/20

Purpose:
    Runs threshold-free cluster estimation (TFCE) to idenitify
    statistical significance in tEEG vs. eEEG classification ability.

Input: 
    -10x494 matrix with features subjects x classification
    performance.
    -comparison of dataset to chance (0) or to dataset appended to ds (2)

Output: 1x494 vector of significant time point

TODO:
    
    1. Allow comparison between multiple datasets

%}
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function zd_sig = tEEG_tfce_backend(ds,comparison)

    chance = 0.5;

    clear d nh zd
    nsamp = 10; % number of samples (participants)
    nfeat = 494; % number of features (timepoints)
    
    d.samples = ds;

    % feature attributes
    d.fa.time = 1:nfeat;
    d.a.fdim.labels = {'time'};
    d.a.fdim.values = {1:nfeat};

    % sample attributes
    targets = ones(nsamp,1); % assume one condition (e.g., is decoding above chance for one condition, one type of electrode timecourse)
    chunks = (1:nsamp)'; % each participant contributes one sample row of data
    if comparison == 0
        d.sa.targets = targets;
        d.sa.chunks = chunks;
    else
        d.sa.targets = [targets;2*targets];
        d.sa.chunks = [chunks;chunks];
    end

    % create neighborhood structure, but keep time points independent
    nh = cosmo_cluster_neighborhood(d,'time',false); % we don't really want to cluster over anything (which treats multiple time points as a single time point).  we want to treat each time point independently, i think.

    % run TFCE (might play around with some options here)
    opt = struct(); % reset options structure
    opt.cluster_stat = 'tfce';  % Threshold-Free Cluster Enhancement
    opt.niter = 10000; % should be near 10k for publication, but can test at lower values
    if comparison == 0
        opt.h0_mean = chance; % not allowed in 2-tailed tests
    end
    opt.seed = 1; % should usually not be used, unless exact replication of results is required (keeping for this test script)
    opt.progress = true; % let's show for now

    zd = cosmo_montecarlo_cluster_stat(d,nh,opt); % returns TFCE-corrected z-score for each column, the results of a one-sample t-test against 0.5
    % mark location where performance is "significant" by tfce
    zd_sig = abs(zd.samples) > 1.96; % two-tailed (this is really an estimate, assuming a large sample size - we need to look up threshold for n=10 for out study)

    %{
    % mark locations where performance is "significant" by uncorrected t-tests
    alpha = 0.05;
    [h,p] = ttest(d.samples,chance); % one-sample t-test (each column separately) against chance (0.5 for 2 targets)
    t_sig = p < alpha; % uncorrected p-value less than alpha = .05
    %}
    
end