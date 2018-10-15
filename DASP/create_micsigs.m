% Adapt speechfiles- and noisefiles-array according to the nb of audio and
% noise elements.
% mic = matrix(rows = samples, columns = mics)

speechfiles{1} = 'speech1.wav'; %number of speechfiles should be same as audiosrcs in RIR-gui
%speechfiles{2} = 'speech2.wav';
%noisefiles{1} = 'Babble_noise1.wav';
%noisefiles{2} = 'Babble_noise1.wav';

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
    speech_resampled{i} = resample(speech_sampled{i}, fs_RIR, fs_speech{i});
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

% speech1_resampled = resample(speech1_sampled, fs_RIR, fs_speech1);
% speech2_resampled = resample(speech2_sampled, fs_RIR, fs_speech2);
% noise1_resampled = resample(noise1_sampled, fs_RIR, fs_noise1);
% noise2_resampled = resample(noise2_sampled, fs_RIR, fs_noise2);

%testing

mic = zeros(nb_min, nb_mics);

for i=1:nb_mics
    
    for j=1:nb_audiosrc
        mic(:,i) = mic(:,i) + fftfilt(RIR_sources(:, i, j), speech_resampled{j});
    end
    
    
    for j=1:nb_noisesrc
        mic(:,i) = mic(:,i) + fftfilt( RIR_noise(:, i, j), noise_resampled{j});
    end
end

figure
hold on
plot(mic(:,1));
plot(mic(:,2),'--r');

% speech1_mic1 = fftfilt(speech1_resampled, RIR_sources(:, 1, 1));
% speech1_mic2 = fftfilt(speech1_resampled, RIR_sources(:, 2, 1));
% speech1_mic3 = fftfilt(speech1_resampled, RIR_sources(:, 3, 1));
% speech2_mic1 = fftfilt(speech2_resampled, RIR_sources(:, 1, 2));
% speech2_mic2 = fftfilt(speech2_resampled, RIR_sources(:, 2, 2));
% speech2_mic3 = fftfilt(speech2_resampled, RIR_sources(:, 3, 2));
% noise1_mic1 = fftfilt(noise1_resampled, RIR_noise(:, 1));
% noise1_mic2 = fftfilt(noise1_resampled, RIR_noise(:, 2));
% noise1_mic3 = fftfilt(noise1_resampled, RIR_noise(:, 3));

% total_mic1 = speech1_mic1 + speech2_mic1 + noise1_mic1;
% total_mic2 = speech1_mic2 + speech2_mic2 + noise1_mic2;
% total_mic3 = speech1_mic3 + speech2_mic3 + noise1_mic3;

%mic = [total_mic1, total_mic2, total_mic3];






