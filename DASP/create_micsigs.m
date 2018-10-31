% Adapt speechfiles- and noisefiles-array according to the nb of audio and
% noise elements.
% mic = matrix(rows = samples, columns = mics)

speechfiles{1} = 'speech1.wav'; %number of speechfiles should be same as audiosrcs in RIR-gui
%speechfiles{2} = 'speech2.wav';
noisefiles{1} = 'Babble_noise1.wav'; %best let one noise file on, even if not used
%noisefiles{2} = 'Babble_noise1.wav';

create_micsigs_func(speechfiles,noisefiles);