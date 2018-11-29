function [mic] = create_micsigs_func(speechfiles, noisefiles,length)
%speechfiles and noisefiles should be arrays
%cf.    speechfiles{1} = "speech1.wav"
%       speechfiles{2} = "speech2.wav"
%       speechfiles{3} = "speech3.wav"
% best non-zero arrays, even if not used
% desired length of the mic signals is given in seconds
%
% mic is a matrix containing the resulting microphone signals where the rows are the samples
% and the columns correspond to the different microphones.

% ------- LOAD PARAMETERS --------- %

[~, nb_speechfiles] = size(speechfiles);
[~, nb_noisefiles] = size(noisefiles);

load('Computed_RIRs.mat');

if fs_RIR ~= 44100
    error('DASP: invalid sample frequency, should be 44100 Hz');
end

[nb_samples, nb_mics, nb_audiosrc] = size(RIR_sources);
[check, ~, nb_noisesrc] = size(RIR_noise);
if check ==0
    nb_noisesrc =0;
end

% ------- Set length of mic signals --------- %

nb_min = fs_RIR*length;
for i=1:nb_speechfiles
    [speech_sampled{i}, fs_speech{i}] = audioread(speechfiles{i});
    speech_resampled{i} = resample(speech_sampled{i}, fs_RIR, fs_speech{i}); %so sample TO fs_RIR
    [tempsize, ~] = size(speech_resampled{i});
    nb_min = min(nb_min, tempsize);
end


for i=1:nb_noisefiles
    [noise_sampled{i}, fs_noise{i}] = audioread(noisefiles{i});
    noise_resampled{i} = resample(noise_sampled{i}, fs_RIR, fs_noise{i});
    [tempsize, ~] = size(noise_resampled{i});
    nb_min = min(nb_min, tempsize);
end

for i=1:nb_speechfiles
    speech_resampled{i} = speech_resampled{i}(1:nb_min);
end

for i=1:nb_noisefiles
    noise_resampled{i} = noise_resampled{i}(1:nb_min);
end

% ------- Compute mic signals --------- %

speech = zeros(nb_min, nb_mics);


for i=1:nb_mics
    
    for j=1:nb_audiosrc
        speech(:,i) = speech(:,i) + fftfilt(RIR_sources(:, i, j), speech_resampled{j});
    end
        
end

VAD = abs(speech(:,1))>std(speech(:,1))*1e-3;
power_samples = speech(VAD==1,1);
power = var(power_samples);
noise = wgn(nb_min,nb_mics,10*log10(0.1*power));

for i=1:nb_mics
    
    for j=1:nb_noisesrc
        noise(:,i) = noise(:,i) + fftfilt(RIR_noise(:, i, j), noise_resampled{j});
    end
    
end

mic = speech+noise;

SNR_in = 10*log10(var(speech(VAD==1,1))/var(noise(:,1)));

save('speech')
save('noise')
save('mic')
save('SNR_in')
save('fs_RIR')
save('VAD')

