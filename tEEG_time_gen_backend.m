%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%{

Author: Sean Kelly
Filename: tEEG_time_gen_backend.m
Date: 10/10/20

Purpose: This classifier performs MVPA analyses on tEEG and eEEG data.
    returns timeseries classification of data with given parameters.

%}
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function data = tEEG_time_gen_backend(subject, fix_pos, eeg_type, stim_size, ntrials)

    %load formatted dataset
    %Params = subject(1:10), fixation_position(1:7), (t/e)EEG(1:2), stim_size(1:2), ntrials(3:100)
    ds_tl = tEEG_ds_format_v5(subject, fix_pos, eeg_type, stim_size, ntrials);

    % reset chunks so each one has an equal number of large and small target
    % trials. Each test set will contain 1 large and 1 small target.
    % assume all trials are independent (although not really true for the data collection method as trials occurr without an inter-trial interval)
    ds_tl.sa.chunks = (1:size(ds_tl.samples,1))';
    % create as many chunks as there are trials for each dataset (NOTE: not sure if last argument is defined in the best possible way here if ntrials differs for each dataset)

    nchunks = 2; %Need 2 chunks for split half analysis  
    ds_tl.sa.chunks = cosmo_chunkize(ds_tl, nchunks);

    % just to check everything is ok
    cosmo_check_dataset(ds_tl);

    % set arguments for the cosmo_dim_generalization_measure
    measure_args=struct();

    % the cosmo_dim_generalization_measure requires that another
    % measure (here: the crossvalidation measure) is specified. The
    % specified measure is applied for each combination of time points
    measure_args.measure=@cosmo_crossvalidation_measure;

    % When used ordinary, the cosmo_crossvalidation_measure itself
    % requires two arguments:
    % - classifier (here: LDA)
    % - partitions
    % However, because the cosmo_dim_generalization_measure defines
    % the partitions itself, they are not set here.
    measure_args.classifier=@cosmo_classify_lda;

    % define the dimension over which generalization takes place
    measure_args.dimension='time';

    % define the radius for the time dimension. Here not just a single
    % time-point is used, but also the time-point before it and the time-point
    % after it.
    measure_args.radius=0; %default 1

    ds_sel = ds_tl;

    % make 'time' a sample dimension
    % (this necessary for cosmo_dim_generalization_measure)
    ds_time=cosmo_dim_transpose(ds_sel,'time',1);

    % run transfer across time with the searchlight neighborhood
    cdt_ds=cosmo_dim_generalization_measure(ds_time,measure_args);

    fprintf('The output is:\n')
    cosmo_disp(cdt_ds);

    % unflatten the data to get train_time x test_time matrix
    [data, labels, values]=cosmo_unflatten(cdt_ds,1);
   
    data = flipud(data);
end
