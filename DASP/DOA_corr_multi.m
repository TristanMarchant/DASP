% To be used with 2 mics, 1 audiosrc, 0 noisesrc.
% s_pos = audiosrc position
% m_pos = mic positions

load('Computed_RIRs.mat');

% --- LOOKING FOR GROUNDTRUTH ----------------------%
c = 340; %speed of sound 340 m/s
d = 0.10; %distance between mics in [m]

m1_pos = m_pos(1,:);
m2_pos = m_pos(2,:);

m1_s_dist = norm(m1_pos - s_pos); %distance between mic1 and audio src
m2_s_dist = norm(m2_pos - s_pos);

m1_s_arrival = m1_s_dist/c;
m2_s_arrival = m2_s_dist/c;

delay_groundtruth = m1_s_arrival - m2_s_arrival; %or abs value?

%---- COPIED FROM CREATE_MICSIGS.M ----------------%
speechfiles{1} = 'speech1.wav';
speechfiles{2} = 'speech2.wav';
speechfiles{3} = 'speech3.wav';
noisefiles{1} = 'Babble_noise1.wav';
%noisefiles{2} = 'Babble_noise1.wav';

[~, nb_speechfiles] = size(speechfiles);
[~, nb_noisefiles] = size(noisefiles);

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

mic = zeros(nb_min, nb_mics);
DOA_est = zeros(1,nb_audiosrc);

for j=1:nb_audiosrc
    
    for i=1:nb_mics
        mic(:,i) = mic(:,i) + fftfilt(RIR_sources(:, i, j), speech_resampled{j});
    end
    
    [r, lags] = xcorr(mic(:,1), mic(:,2)); % adjusted for accuracte autocorr, longer computing though
    [val, idx] = max(r); %value and index at lags of highest value
    est_delay = lags(idx)/fs_RIR;
    if (est_delay*c/d) > 1
        DOA_est(j) = acos(1)*180/pi;
    else
        DOA_est(j) = acos(est_delay*c/d)*180/pi; %Tested with ground truth should be done with estimate
    end
    
    for i=1:nb_mics
        mic(:,i) = 0;
    end
end

save DOA_est
% for i=1:nb_mics
%    
%     for j=1:nb_audiosrc
%         mic(:,i) = mic(:,i) + fftfilt(RIR_sources(:, i, j), speech_resampled{j});
%     end
%     
%     
%     for j=1:nb_noisesrc
%         mic(:,i) = mic(:,i) + fftfilt( RIR_noise(:, i, j), noise_resampled{j});
%     end
% end
% 
% % --------- END OF COPY ---------------% --------- CROSS CORRELATION
% % ---------%
% 
% [r, lags] = xcorr(mic(:,1), mic(:,2)); % adjusted for accuracte autocorr, longer computing though
% [val, idx] = max(r); %value and index at lags of highest value
% est_delay = lags(idx)/fs_RIR; 
% 
% % --------- COPY OF TDOA TILL THIS POINT ------
% 
% DOA_est = acos(est_delay*c/d)*180/pi; %Tested with ground truth should be done with estimate
% save DOA_est