function [est_delay, error] = TDOA_corr_func(speechfiles, noisefiles)
% To be used with 2 mics, 1 audiosrc, 0 noisesrc.
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
[~,max1] = max(RIR_sources(:,1));
[~,max2] = max(RIR_sources(:,2));
delay_groundtruth2 = (max1- max2)/fs_RIR; 

%---- CREATE_MICSIGS.M ----------------%
mic = create_micsigs_func(speechfiles,noisefiles,10);

% --- CROSS CORRELATION ---------%

[r, lags] = xcorr(mic(:,1), mic(:,2));
[val, idx] = max(r); %value and index at lags of highest value
est_delay = lags(idx)/fs_RIR; %lags(idx) is the lag (#samples) with max value
error = abs(est_delay - delay_groundtruth2);

% --------- OUTPUTS -------------------%
disp('tdoa_corr outputs');
disp(['...estimated: ', num2str(est_delay)]);
disp(['...groundtruth via RIR_sources: ', num2str(delay_groundtruth2)]);
disp(['...error with RIR_sources: ', num2str(error)]);

timestamps = (lags/fs_RIR)';
figure(4)
clf(4)
figure(4)
hold on
plot(timestamps,r, 'DisplayName', 'cross-correlation')
stem(delay_groundtruth2, val/2, 'r', 'DisplayName', 'groundtruth')
title('Cross-correlation of mic signals')
xlabel('Time (s)')
ylabel('Amplitude')
legend('cross-correlation', 'groundtruth')
