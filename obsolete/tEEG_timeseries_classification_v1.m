%% (t,e)EEG timeseries classification
%
%Author: Sean Kelly (adapted from demo_meeg_timeseries_classification.m)
%Filename: tEEG_timeseries_classification_v1.m
%Date: 9/28/20
%
% This classifier performs MVPA analyses on tEEG and eEEG data.
%
% * targets: large vs. small checker stimuli
% * chunks: program assumes that every trial is independent
% * trials: each trial is the summation of a given index from each
%   of the 494 epochs
%
% Note: running this code requires FieldTrip.
%
%Example: tEEG_timeseries_classification_v1
%
%TODO: This code currently produces an error when partitioning the data
% in the "Prepare MVPA" step
%% get timelock data in CoSMoMVPA format

% set configuration
config=cosmo_config();

% reset citation list
cosmo_check_external('-tic');

%loads formatted dataset
ds_tl = tEEG_ds_format_v1(1,1); %subject(1:10), fixation_position(1:7)

% just to check everything is ok
cosmo_check_dataset(ds_tl);

%% Prepare MVPA
% reset chunks: use four chunks
%nchunks=4;
%ds_tl.sa.chunks=cosmo_chunkize(ds_tl,nchunks);

% do a take-one-fold out cross validation.
% except when using a splithalf correlation measure it is important that
% the partitions are *balanced*, i.e. each target (or class) is presented
% equally often in each chunk
partitions=cosmo_nchoosek_partitioner(ds_tl,1)
partitions=cosmo_balance_partitions(partitions, ds_tl);

npartitions=numel(partitions);
fprintf('There are %d partitions\n', numel(partitions.train_indices));
fprintf('# train samples:%s\n', sprintf(' %d', cellfun(@numel, ...
                                        partitions.train_indices)));
fprintf('# test samples:%s\n', sprintf(' %d', cellfun(@numel, ...
                                        partitions.test_indices)));




%% Run time-series searchlight on magneto- and gradio-meters seperately

% try two different classification approaches:
% 1) without averaging the samples in the train set
% 2) by averaging 5 samples at the time in the train set, and re-using
%    every sample 3 times.
% (Note: As of July 2015, there is no clear indication in the literature
%  which approach is 'better'. These two approaches are used here to
%  illustrate how they can be used with a searchlight).
average_train_args_cell={{},...                                  % {  1
                         {'average_train_count',5,...            %  { 2
                                'average_train_resamplings',3}}; %  { 2
n_average_train_args=numel(average_train_args_cell);

% compute and plot accuracies for magnetometers and gradiometers separately
chantypes={'meg_axial','meg_planar'};

% in the time searchlight analysis, select the time-point itself, the two
% timepoints after it, and the two timepoints before it
time_radius=2;
nchantypes=numel(chantypes);

ds_chantypes=cosmo_meeg_chantype(ds_tl);
plot_counter=0;
for j=1:n_average_train_args
    % define the measure and its argument.
    % here a simple naive baysian classifier is used.
    % Alternative are @cosmo_classify_{svm,nn,lda}.
    measure=@cosmo_crossvalidation_measure;
    measure_args=struct();
    measure_args.classifier=@cosmo_classify_naive_bayes;
    measure_args.partitions=partitions;

    % add the options to average samples to the measure arguments.
    % (if no averaging is desired, this step can be left out.)
    average_train_args=average_train_args_cell{j};
    measure_args=cosmo_structjoin(measure_args, average_train_args);


    for k=1:nchantypes
        parent_type=chantypes{k};

        % find feature indices of channels matching the parent_type
        chantype_idxs=find(cosmo_match(ds_chantypes,parent_type));

        % define mask with channels matching those feature indices
        chan_msk=cosmo_match(ds_tl.fa.chan,chantype_idxs);

        % slice the dataset to select only the channels matching the channel
        % types
        ds_tl_sel=cosmo_dim_slice(ds_tl, chan_msk, 2);
        ds_tl_sel=cosmo_dim_prune(ds_tl_sel); % remove non-indexed channels

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

        plot_counter=plot_counter+1;
        subplot(n_average_train_args,nchantypes,plot_counter);

        time_values=sl_map.a.fdim.values{1}; % first dim (channels got nuked)
        plot(time_values,sl_map.samples);

        ylim([.4 .8])
        xlim([min(time_values),max(time_values)]);
        ylabel('classification accuracy (chance=.5)');
        xlabel('time');

        if isempty(average_train_args)
            postfix=' no averaging';
        else
            postfix=' with averaging';
        end

        descr=sprintf('%s - %s', strrep(parent_type,'_',' '), postfix);
        title(descr);
    end
end
% Show citation information
cosmo_check_external('-cite');

