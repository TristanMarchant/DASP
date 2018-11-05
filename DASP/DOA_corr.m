% To be used with 2 mics, 1 audiosrc, 0 noisesrc.
% Calculate the DOA of an audiosrc given 2 microphone signals

speechfiles{1} = 'speech1.wav';
noisefiles{1} = 'Babble_noise1.wav'; % Just for functionality of function / not actually used
[doa_est, error] = DOA_corr_func(speechfiles, noisefiles);

disp('DOA_corr outputs');
disp(['...estimated direction: ', num2str(doa_est)]);
disp(['...error: ', num2str(error)]);