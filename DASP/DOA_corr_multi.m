%To be used with multiple audio sources

load('Computed_RIRs.mat');

% --- LOOKING FOR GROUNDTRUTH ----------------------%
c = 340; %speed of sound 340 m/s


m1_pos = m_pos(1,:);
m2_pos = m_pos(2,:);
m1_2_distance = norm(m1_pos - m2_pos);

m1_s_dist = norm(m1_pos - s_pos); %distance between mic1 and audio src
m2_s_dist = norm(m2_pos - s_pos);

m1_s_arrival = m1_s_dist/c;
m2_s_arrival = m2_s_dist/c;

delay_groundtruth = m1_s_arrival - m2_s_arrival; %or abs value?

%---- COPIED FROM CREATE_MICSIGS.M ----------------%
speechfiles{1} = 'speech1.wav';
speechfiles{2} = 'speech2.wav';
speechfiles{3} = 'speech3.wav';
noisefiles{1} = 'Babble_noise1.wav'; %just keep one noise file
%noisefiles{2} = 'Babble_noise1.wav';

[~, nb_speechfiles] = size(speechfiles);
[~, nb_noisefiles] = size(noisefiles);

[nb_samples, nb_mics, nb_audiosrc] = size(RIR_sources);
[check, ~, nb_noisesrc] = size(RIR_noise);
if check ==0
    nb_noisesrc =0;
end

for i=1:nb_audiosrc
    speechfiles{i} = 'speech1.wav';
end
nb_speechfiles = nb_audiosrc;


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

mic = zeros(nb_min, nb_mics);
DOA_est = zeros(1,nb_audiosrc);

for j=1:nb_audiosrc
    
    for i=1:nb_mics
        mic(:,i) = mic(:,i) + fftfilt(RIR_sources(:, i, j), speech_resampled{j});
    end
    
    [r, lags] = xcorr(mic(:,1), mic(:,2)); % adjusted for accuracte autocorr, longer computing though
    [val, idx] = max(r); %value and index at lags of highest value
    est_delay = lags(idx)/fs_RIR;
    
    if (est_delay*c/m1_2_distance) > 1
        DOA_est(j) = acosd(1);
    elseif (est_delay*c/m1_2_distance) < -1
        DOA_est(j) = acosd(-1);
    else
        DOA_est(j) = acosd(est_delay*c/m1_2_distance); %Tested with ground truth should be done with estimate
    end
    
    for i=1:nb_mics
        mic(:,i) = 0;
    end
end

save DOA_est
