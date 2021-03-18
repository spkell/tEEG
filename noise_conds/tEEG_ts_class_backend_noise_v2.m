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
%Example: tEEG_ts_class_backend_noise_v2(2,2,1,50,1)
%         => Subject 2, Clench, tEEG, lg vs sm stim, 50 trials,
%         include parietal
%
%TODO: 1. use different target inputs for classification
%      2. randomize which trials are selected with ntrials
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function avg_class_score = tEEG_ts_class_backend_noise_v2(subject, noise_pos, eeg_type, ntrials, parietal)

    %load formatted datasets
    %Params = subject(1:10), noise_condition(1:2), (t/e)EEG(1:2), ntrials(3:100), (1,2)

    %Train on large center Vs. small center
    ds_train = tEEG_ds_format_noise_v1(subject, 1, eeg_type, ntrials, parietal);
    %ds_train = tEEG_ds_format_noise_v1(2, 1, 1, 30, 1);

    %Test on clench or chew
    ds_test = tEEG_ds_format_noise_v1(subject, noise_pos, eeg_type, 100, parietal);
    %ds_test = tEEG_ds_format_noise_v1(2, 2, 1, 30, 1);

    nfeat = 494;
    nchan = size(ds_train.samples,2)/nfeat;
    ntrials = size(ds_test.samples,1);
    targets = ds_train.sa.targets;

    class_score = zeros(1,nfeat); %number of correct predictions / timepoint
    avg_class_score = class_score; %class accuracy % for each timepoint

    %For each timepoint, average the lda classification scores for ntrials
    for time=0:nfeat-1
        timepoint = (time*nchan+1:time*nchan+nchan);
        train = ds_train.samples(:,timepoint);
        test = ds_test.samples(:,timepoint);

        prediction = cosmo_classify_lda(train, targets, test);

        for pred=1:length(prediction)
            if prediction(pred) == 1
                class_score(time+1) = class_score(time+1) + 1;
            end
        end

        avg_class_score(time+1) = class_score(time+1)/ntrials;


    end

end
