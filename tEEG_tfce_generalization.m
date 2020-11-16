%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%{

Author: Sean Kelly & Pr. Mruczek
Filename: tEEG_tfce_generalization.m
Date: 11/4/20

Purpose:
 Script runs threshold-free cluster estimation (TFCE) to idenitify
 statistical significance in tEEG vs. eEEG classification ability.

TODO:
    1. Autosave .fig, .pdf, and .mat files

%}
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function zd_sig_results = tEEG_tfce_generalization(eeg_type, class_raw_mat)

    %input specification
    conds = tEEG_conditions();
    if length(eeg_type) == 1
        eeg = conds.EEG_type{eeg_type};
    else
        eeg = strcat(conds.EEG_type{eeg_type(1)},'-vs-',conds.EEG_type{eeg_type(2)});
    end
    
    if ndims(class_raw_mat) == 3
        nfeat = size(class_raw_mat,2);
    elseif ndims(class_raw_mat) == 4
        nfeat = size(class_raw_mat,3);
    end
        
    %nsamp = size(class_raw_mat,1);

    %{
    if ndims(class_raw_mat) == 3
        % plot average generalization without statistical test
        f(1) = figure;
        hold on
        data = squeeze(mean(class_raw_mat,1));
        imagesc(flipud(data), [.3 0.8]);
        title(sprintf('Average Classification Accuracy for %s',eeg)); % use_chan_type));
        colorbar();

        labels = {'train_time','test_time'};
        ylabel(strrep(labels{1},'_',' '));
        xlabel(strrep(labels{2},'_',' '));
        colorbar();
        set(gca,'YDir','normal') %flip plot y-axis labels
    end
    %}
    
    
    %Preallocate memory to store statistical test results matrix
    zd_sig_results(nfeat,nfeat) = zeros();
    
    %Run statistical tests
    for timei=1:nfeat
        if ndims(class_raw_mat) == 3
            ds_vector = squeeze(class_raw_mat(:,timei,:));
            comparison = 0;
        elseif ndims(class_raw_mat) == 4
            ds_v1 = squeeze(class_raw_mat(1,:,timei,:));
            ds_v2 = squeeze(class_raw_mat(2,:,timei,:));
            ds_vector = [ds_v1;ds_v2];
            comparison = 1;
        end
        zd_sig_results(timei,:) = tEEG_tfce_backend(ds_vector, comparison);
    end
    
    %{
    % plot average generalization with statistical test
    f(2) = figure;
    hold on
    imagesc(flipud(zd_sig_results), [0 1]);
    title(sprintf('TFCE of Classification Accuracy for %s',eeg)); % use_chan_type));
    colorbar();
    
    labels = {'train_time','test_time'};
    ylabel(strrep(labels{1},'_',' '));
    xlabel(strrep(labels{2},'_',' '));
    colorbar();
    set(gca,'YDir','normal') %flip plot y-axis labels
    
    %Save Analysis
    fname = strcat(eeg,'_time-gen_all-subj_lgsm');
    path = strcat('ts_class_outputs/tEEG_tfce/time_gen/',eeg,'_lgsm/',fname);
    mat_path = strcat(path,'.mat');
    fig_path = strcat(path,'.fig');
    pdf_path = strcat(path,'.pdf');
    save(mat_path,'zd_sig_results'); %save as mat variable
    savefig(f,fig_path) %save as matlab figure
    orient landscape
    print('-dpdf',pdf_path) %save as pdf
    %}
end
