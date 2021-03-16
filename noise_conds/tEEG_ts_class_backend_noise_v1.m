%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Author: Sean Kelly
%Filename: tEEG_ts_class_backend_noise_v1.m
%Date: 12/29/20
%
%Purpose: This classifier performs MVPA analyses on tEEG and eEEG data.
% returns timeseries classification of data with given parameters.
%
% * targets: 2 subjects XOR fix_pos XOR eeg_type XOR stim_size
% * chunks: program assumes that every trial is independent
% * trials: each trial is the summation of a given index from each
%   of the 494 epochs
%
%Dependencies: FieldTrip, CosmoMVPA
%
%Example: tEEG_ts_class_backend_noise_v1(2,2,1,50,1)
%         => Subject 2, Clench, tEEG, lg vs sm stim, 50 trials,
%         include parietal
%
%TODO: 1. use different target inputs for classification
%      2. randomize which trials are selected with ntrials
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function sample = tEEG_ts_class_backend_noise_v1(subject, noise_pos, eeg_type, ntrials, parietal)

    %load formatted datasets
    %Params = subject(1:10), noise_condition(1:2), (t/e)EEG(1:2), ntrials(3:100), (1,2)
    
    %Train on large center Vs. small center
    ds_train = tEEG_ds_format_noise_v1(subject, 1, eeg_type, ntrials, parietal);
    %ds_train = tEEG_ds_format_noise_v1(2, 1, 1, 30, 1);
    
    %Test on clench or chew
    ds_test = tEEG_ds_format_noise_v1(subject, noise_pos, eeg_type, ntrials, parietal);
    %ds_test = tEEG_ds_format_noise_v1(2, 2, 1, 30, 1);

    nchunks = 2; %Need 2 chunks for time generalization analysis  
    ds_train.sa.chunks = cosmo_chunkize(ds_train, nchunks);
    ds_test.sa.chunks = cosmo_chunkize(ds_test, 1);
    
    % just to check everything is ok
    cosmo_check_dataset(ds_train);
    cosmo_check_dataset(ds_test);
   
    partitions=cosmo_nchoosek_partitioner(ds_train,'half'); %take-one-fold out  
    %partitions=cosmo_balance_partitions(partitions, ds_train); %no change for split half
    
    ds_tl_sel = ds_train;
    
    %Insert noise test samples into training indices of clean training samples
    for i=1:length(partitions.train_indices{1})
        ds_tl_sel.samples(partitions.train_indices{1}(i)) = ds_train.samples(partitions.train_indices{1}(i));
    end
    
    %npartitions=numel(partitions);
    fprintf('There are %d partitions\n', numel(partitions.train_indices));
    fprintf('# train samples:%s\n', sprintf(' %d', cellfun(@numel, ...
                                            partitions.train_indices)));
    fprintf('# test samples:%s\n', sprintf(' %d', cellfun(@numel, ...
                                            partitions.test_indices)));

    % in the time searchlight analysis, select the time-point itself, and the
    % radius of timepoints after and before it
    time_radius=0; %2; %only look at single time points

    % define the measure and its argument.
    measure=@cosmo_crossvalidation_measure;
    measure_args=struct();
    
    % Alternative are @cosmo_classify_{svm,nn,lda}.
    measure_args.classifier=@cosmo_classify_lda; %lda similar to svm with more efficient performance
    
    measure_args.partitions=partitions;

    % define neighborhood over time; for each time point the time
    % point itself is included, as well as the two time points before
    % and the two time points after it
    nbrhood=cosmo_interval_neighborhood(ds_tl_sel,'time',...
        'radius',time_radius);

    % run the searchlight using the measure, measure arguments, and
    % neighborhood defined above.
    % Note that while the input has both 'chan' and 'time' as feature
    % dimensions, the output only has 'time' as the feature dimension
    sl_map=cosmo_searchlight(ds_tl_sel,nbrhood,measure,measure_args);
    fprintf('The output has feature dimensions: %s\n', ...
        cosmo_strjoin(sl_map.a.fdim.labels,', '));

    sample = sl_map.samples; %1class-score x 494timepoints
end
