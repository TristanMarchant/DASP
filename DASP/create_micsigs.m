% Adapt speechfiles- and noisefiles-array according to the nb of audio and
% noise sources.
% mic = matrix(rows = samples, columns = mics)

load('Computed_RIRs.mat');


speechfiles{1} = 'speech1.wav'; %number of speechfiles should be same as audiosrcs in RIR-gui
speechfiles{2} = 'speech2.wav';
noisefiles{1} = 'Babble_noise1.wav'; %best let one noise file on, even if not used
%noisefiles{2} = 'Babble_noise1.wav';
length = 10; %desired length of the microphone signals in seconds

mic = create_micsigs_func(speechfiles,noisefiles,length);

%--- PLOT THE MIC signals ----%
figure(2)
clf(2)
figure(2)
hold on
plot(mic(:,1));
plot(mic(:,2),'--r');
title('Microphone signals (create micsigs)')
xlabel('samples')
ylabel('amplitude')

%--- PLAY SOUNDS ------%
soundsc(mic(:,1),fs_RIR);

%---- PLOT THE RIRS -------%
figure(3)
clf(3)
figure(3)
hold on
plot(RIR_sources(:,1));
plot(RIR_sources(:,2), '--r');
title('RIRs to 2 microphones');
xlabel('samples');
ylabel('amplitude');

load('SNR_in.mat');
display(SNR_in);