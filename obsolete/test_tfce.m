% quick script to test threshold-free cluster estimation (TFCE)

% make a fake dataset using randomized data
clear d nh zd
nsamp = 10; % number of samples (participants)
nfeat = 100; % number of features (timepoints)
d.samples = rand([nsamp nfeat]); % random data, centered around 0.5 (e.g., chance decoding)

% add an offset to artificially force more significant time points
offset = .25;
d.samples = d.samples + offset;

% feature attributes
d.fa.time = 1:nfeat;
d.a.fdim.labels = {'time'};
d.a.fdim.values = {1:nfeat};

% sample attributes
d.sa.targets = ones(nsamp,1); % assume one condition (e.g., is decoding above chance for one condition, one type of electrode timecourse)
d.sa.chunks = (1:nsamp)'; % each participant contributes one sample row of data

% create neighborhood structure, but keep time points independent
nh = cosmo_cluster_neighborhood(d,'time',false); % we don't really want to cluster over anything (which treats multiple time points as a single time point).  we want to treat each time point independently, i think.

% run TFCE (might play around with some options here)
opt = struct(); % reset options structure
opt.cluster_stat = 'tfce';  % Threshold-Free Cluster Enhancement
opt.niter = 1000; % should be near 10k for publication, but can test at lower values
opt.h0_mean = 0.5; % for this example, chance decoding represents 0.5
opt.seed = 1; % should usually not be used, unless exact replication of results is required (keeping for this test script)
opt.progress = true; % let's show for now

zd = cosmo_montecarlo_cluster_stat(d,nh,opt); % returns TFCE-corrected z-score for each column, the results of a one-sample t-test against 0.5

% plot results
figure

% random order (so expect no clusters)
t = 1:nfeat;
plot(t,mean(d.samples)); % mean decoding over time
ylim([0 1]);
xlabel('time');
ylabel('random decoding perf');
hline(0.5,':k','chance');

% mark location where performance is "significant" by tfce
zd_sig = abs(zd.samples) > 1.96; % two-tailed (this is really an estimate, assuming a large sample size - we need to look up threshold for n=10 for out study)
hold on;
plot(t(zd_sig),.95*zd_sig(zd_sig),'.r','MarkerSize',10);

% mark locations where performance is "significant" by uncorrected t-tests
[h,p] = ttest(d.samples,0.5); % one-sample t-test (each column separately) against 0.5
t_sig = p < 0.05; % uncorrected p-value less than alpha = .05
plot(t(t_sig),.05*t_sig(t_sig),'.b','MarkerSize',10);