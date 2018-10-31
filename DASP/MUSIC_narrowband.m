
load('Computed_RIRs.mat');
%--- PARAMETERS ------------------%
L = 1024; %window
overlap = 0.5;


%---- CHECK FOR SAMPLE FREQ-------%
if fs_RIR ~= 44100
    error('DASP: invalid sample frequency, should be 44100 Hz');
end

%---- TRUNCATE AUDIO -------------%
speechfile = 'speech1.wav';
[speech_sampled, fs_speech] = audioread(speechfile);
speech_sampled = speech_sampled(1:fs_speech*10); %truncate 10s

audiowrite('speech1_truncated10s.wav',speech_sampled,fs_speech);

%---- CREATE MICSIGS ------------%
speechfiles{1} = 'speech1_truncated10s.wav';
noisefiles{1} = 'Babble_noise1.wav'; %best let one noise file on, even if not used
mic = create_micsigs_func(speechfiles,noisefiles);
mic_size = size(mic);
mic_size1 = mic_size(1);
mic_nb = mic_size(2);

%---- STFTs --------------------%
nb_freqs = L*overlap+1;
nb_times =  ceil(mic_size1*1/nb_freqs);
stft_mtx = zeros(mic_nb, nb_freqs, nb_times);
%size = mics x freqs x times
%size depends on spectrogram output
%TODO: don't exactly know why + 1 and stuff...
for i = 1:mic_nb
    stft_mtx(i,:,:) = spectrogram(mic(:,i),L,overlap*L);
%TODO: maybe 4th argument for less samples
%TODO: outputs 513 frequency bins?
end

%---- POWERS PER BIN -----------%
powers = zeros(nb_freqs, 1);
for i = 1:nb_freqs
    temp_power = 0;
    for j = 1:mic_nb 
        temp = stft_mtx(j,i,:);
        temp = reshape(temp,1,nb_times);
        temp_power = temp_power + norm(temp);
    end
    powers(i) = temp_power/mic_nb;
end

[~, freq_maxpower] = max(powers);
%---- PSEUDOSPECTRUM -----------%

%---- DOA OF SPEECH SOURCE -----%


