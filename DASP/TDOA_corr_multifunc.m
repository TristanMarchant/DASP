function [est_delay, error] = TDOA_corr_multifunc(speechfiles, noisefiles)
% To be used with 2 mics, 2 audiosrc, 0 noisesrc.
% s_pos = audiosrc position
% m_pos = mic positions
%
%speechfiles and noisefiles should be arrays
%cf.    speechfiles{1} = "speech1.wav"
%       speechfiles{2} = "speech2.wav"
%       speechfiles{3} = "speech3.wav"
% best non-zero arrays, even if not used
%
% est_delay = estimated delay between the two mics in seconds
% error = error between est_delay and groundtruth (from RIRs)


load('Computed_RIRs.mat');

% --- LOOKING FOR GROUNDTRUTH ----------------------%
% for audiosource 1
[~,max1s1] = max(RIR_sources(:,1, 1));
[~,max2s1] = max(RIR_sources(:,2, 1));
delay_groundtruth_s1 = (max1s1- max2s1)/fs_RIR; 

% for audiosource 2
[~,max1s2] = max(RIR_sources(:,1, 2));
[~,max2s2] = max(RIR_sources(:,2, 2));
delay_groundtruth_s2 = (max1s2- max2s2)/fs_RIR; 

%---- CREATE_MICSIGS.M ----------------%
mic = create_micsigs_func(speechfiles,noisefiles);

% --- CROSS CORRELATION ---------%

[r, lags] = xcorr(mic(:,1), mic(:,2));
[val, idx] = max(r); %value and index at lags of highest value
est_delay = lags(idx)/fs_RIR; %lags(idx) is the lag (#samples) with max value
error_s1 = abs(est_delay - delay_groundtruth_s1);
error_s2 = abs(est_delay - delay_groundtruth_s2);

% --------- OUTPUTS -------------------%
disp('tdoa_corr outputs');
disp(['...estimated: ', num2str(est_delay)]);
disp(['...groundtruth audiosrc 1: ', num2str(delay_groundtruth_s1)]);
disp(['...groundtruth audiosrc 2: ', num2str(delay_groundtruth_s2)]);
disp(['...error audiosrc 1: ', num2str(error_s1)]);
disp(['...error audiosrc 2: ', num2str(error_s2)]);

timestamps = (lags/fs_RIR)';
figure(4)
clf(4)
figure(4)
hold on
plot(timestamps,r, 'DisplayName', 'cross-correlation')
stem(delay_groundtruth_s1, val/2, 'r', 'DisplayName', 'groundtruth')
stem(delay_groundtruth_s2, val/2, 'g', 'DisplayName', 'groundtruth')
title('Cross-correlation of mic signals')
xlabel('Time (s)')
ylabel('Amplitude')
legend('cross-correlation', 'groundtruth s1', 'groundtruth s2')
