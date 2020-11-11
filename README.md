# tEEG
Collection of files used for MVPA of visual evoked potentials generated with tripolar EEG.

The tEEG dataset was generated at UNR, Nevada.

This data analysis is conducted through the College of the Holy Cross as a component of Psychology Research for Credit (PSYC480) through the Visual Neuroscience Lab.

Analyses Theory

1. Time Series Classification (run_tEEG_ts_class_v3.m):

    This analysis uses a linear descriminant analysis or naive-bayes classifier that descriminates between given target conditions such as large vs small stimuli, left vs right fixation positions, the 4 corner fixation positions, large stim vs small stim vs left vs right, etc. The classifier is trained using half of the trials input to the analysis, an even number from each target condition, and is then tested on the other half of the input trials, when using a split half cross-validation.

    For each time point in the 494ms of each trial, a naive classifier is trained and tested at only this time point. This classification training and testing is repeated for each time point. The output of this analysis is a figure showing the time interval 0-494ms on the x-axis, and classification performance on the y-axis. Classification performance is in the interval of (0,1), with 0.5 indicating chance classification ability when only 2 targets are involved. One plot shows the classification curves for each independent subject, while another shows the mean classification accuracy of all 10 subjects, surrounded by a 95% confidence interval.
    
    A time sub-interval in this plot showing sustained classification performance above chance decoding indicates there is some pattern across the 6 tEEG or eEEG electrodes at each given time point in this sub-interval that differs between each target condition.

2. Time Generalization (run_tEEG_time_gen.m)

    This analysis uses the linear descriminant analysis as the classifier, and a split half cross-validation to train and test the input set of trials. Time generalization trains the classifier using half of the input trials for a given time point just as the time series classification does. However, this analysis differs in how the classifier performance is tested. Instead of training the classifier at one given time point, and testing the classifier at only the same time point, the classifier's performance is measured for how it classifies the pattern across 6 electrodes at every time point, and it returns a classification accuracy for each time point for the n-time point trained classifier. This is done for each classifier trained at each time point.

    The output of this analysis is a matrix (494x494) which illustrates the classification performance of each n-time point trained classifier at each m-time point that the classifier is tested on. The resulting heat map gives insight to the times in which a pattern across the 6 electrodes is repeated during the 494ms trial.
