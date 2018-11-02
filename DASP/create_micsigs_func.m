function [mic] = create_micsigs_func(speechfiles, noisefiles)
%speechfiles and noisefiles should be arrays
%cf.    speechfiles{1} = "speech1.wav"
%       speechfiles{2} = "speech2.wav"
%       speechfiles{3} = "speech3.wav"
% best non-zero arrays, even if not used


[~, nb_speechfiles] = size(speechfiles);
[~, nb_noisefiles] = size(noisefiles);

load('Computed_RIRs.mat');

[nb_samples, nb_mics, nb_audiosrc] = size(RIR_sources);
[check, ~, nb_noisesrc] = size(RIR_noise);
if check ==0
    nb_noisesrc =0;
end

nb_min = inf;
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

mic = zeros(nb_min, nb_mics);

for i=1:nb_mics
    
    for j=1:nb_audiosrc
        mic(:,i) = mic(:,i) + fftfilt(RIR_sources(:, i, j), speech_resampled{j});
    end
    
    
    for j=1:nb_noisesrc
        mic(:,i) = mic(:,i) + fftfilt( RIR_noise(:, i, j), noise_resampled{j});
    end
end

%figure
%hold on
%plot(mic(:,1));
%plot(mic(:,2),'--r');



