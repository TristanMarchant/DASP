% To be used with 2 mics, 1 audiosrc, 0 noisesrc.
% s_pos = audiosrc position
% m_pos = mic positions

%---- white noise ----------------%
disp('WHITE NOISE');
speechfiles{1} = 'White_noise1.wav';
noisefiles{1} = 'Babble_noise1.wav'; %just for functionality of function
TDOA_corr_func(speechfiles, noisefiles);

disp(' ');

%---- speech ---------------------%
disp('SPEECH');
speechfiles{1} = 'speech1.wav';
noisefiles{1} = 'Babble_noise1.wav'; %just for functionality of function
TDOA_corr_func(speechfiles, noisefiles);