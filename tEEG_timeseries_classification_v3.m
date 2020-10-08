%Author: Sean Kelly
%Filename: tEEG_timeseries_classification_v3.m
%Date: 10/5/20
%
%Purpose: This classifier performs MVPA analyses on tEEG and eEEG data.
% 1 plot is produced containing a superposition of all 10 subjects, and
% another plot containing the average classification performance for each
% time point.
%
% * targets: large vs. small checker stimuli
% * chunks: program assumes that every trial is independent
% * trials: each trial is the summation of a given index from each
%   of the 494 epochs
%
%Dependencies: FieldTrip, CosmoMVPA
%
%Example: tEEG_timeseries_classification_v3()


function class_avg = tEEG_timeseries_classification_v3(fix_pos,EEG)
    % Prepare MVPA

    % reset citation list
    cosmo_check_external('-tic');
    
    class_avg = zeros(1,494);
    
    n_subjects = 10;
    time_values = (1:494); % first dim (channels got nuked)
    
    figure; %new figure for superposition with individual participants
    subplot(2,1,1);
    
    for subject=1:n_subjects

        %loads formatted dataset
        %Params = subject(1:10), fixation_position(1:7), (t/e)EEG(1:2)
        ds_tl = tEEG_ds_format_v3(subject,fix_pos,EEG);

        % just to check everything is ok
        cosmo_check_dataset(ds_tl);

        % reset chunks so each one has an equal number of large and small target
        % trials. Each test set will contain 1 large and 1 small target.
        % assume all trials are independent (although not really true for the data collection method as trials occurr without an inter-trial interval)
        ds_tl.sa.chunks = (1:size(ds_tl.samples,1))';
        % create as many chunks as there are trials for each dataset (NOTE: not sure if last argument is defined in the best possible way here if ntrials differs for each dataset)
        ds_tl.sa.chunks = cosmo_chunkize(ds_tl,100);

        % do a take-one-fold out cross validation.
        % except when using a splithalf correlation measure it is important that
        % the partitions are *balanced*, i.e. each target (or class) is presented
        % equally often in each chunk
        partitions=cosmo_nchoosek_partitioner(ds_tl,1);
        partitions=cosmo_balance_partitions(partitions, ds_tl);

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
        % here a simple naive baysian classifier is used.
        % Alternative are @cosmo_classify_{svm,nn,lda}.
        measure=@cosmo_crossvalidation_measure;
        measure_args=struct();
        measure_args.classifier=@cosmo_classify_naive_bayes; % RM: consider other classifiers, such as SVM or nearest neighbor
        measure_args.partitions=partitions;

        ds_tl_sel = ds_tl; % RM: use all channels, no real selection here.  just keeping variable name consistent with tutorial code, below

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
        
        plot(time_values,sl_map.samples);
        hold on
        
        for timepoint=1:size(sl_map.samples,2)
            class_avg(timepoint) = class_avg(timepoint) + sl_map.samples(timepoint);
        end
        
        %cell array containing classification accuracies for each subject
        class_raw_trials{subject} = sl_map.samples;
        
    end  
    
    %Configure individual classification plot
    xlim([min(time_values),max(time_values)]);
    ylabel('classification accuracy (chance=.5)');
    xlabel('time (ms)');
    title('Individual Superposition Classification Accuracy');
    
    class_avg = class_avg/n_subjects;
    
    %Determine 95% confidence interval of class_avg
    %need to take into account <494ms subject
    confidence_interval = zeros(1,494); %std_dev for up to largest timepoint
    for i = 1:494
        
        sum = 0;
        count = 0;
        for j = 1:size(class_raw_trials,2)
            
            if size(class_raw_trials{j},2) >= i
                count = count + 1;
                temp = (class_raw_trials{j}(i) - class_avg(j))^2;
                sum = sum + temp;
            end
        end
        std_dev = sqrt(sum/count);
        confidence_interval(i) = 1.96 * (std_dev / sqrt(count));
    end
    
    
    %Plot Results
    subplot(2,1,2);
    plot(time_values,class_avg);

    xlim([min(time_values),max(time_values)]);
    ylabel('classification accuracy (chance=.5)');
    xlabel('time (ms)');

    postfix='Average Classification Accuracy - All Participants';

    %descr=sprintf('%s - %s', strrep(parent_type,'_',' '), postfix);
    title(postfix);
    
    %Plot average with standard deviation overlay
    continuous_error_bars(class_avg, time_values, confidence_interval)
        
end