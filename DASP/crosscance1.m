clear
load('Computed_RIRs.mat');
load('HRTF');
[nb_samples, nb_mics, nb_audiosrc] = size(RIR_sources);
RIR_sources_cut = RIR_sources(1:400,:,:);
xL = HRTF(:,1);
%xL = xL(1:499);
xR = HRTF(:,2);
%xR = xR(1:499);
length_HRTF = 100;
xL = [ zeros(100,1); 1 ; zeros(400+length_HRTF-100-2,1)];
xR = [ 1 ; zeros(400+length_HRTF-2,1)];

Delta = ceil(sqrt(room_dim(1)^2+room_dim(2)^2)*fs_RIR/340);
xL = circshift(xL,Delta);
xR = circshift(xR,Delta);
%% H matrix
H_left = [];
H_right = [];
for i = 1:nb_audiosrc
    H_left = [H_left convmtx(RIR_sources_cut(:,1,i),length_HRTF)];
    H_right = [H_right convmtx(RIR_sources_cut(:,2,i),length_HRTF)];
end
% Set Delete zero rows
index = find(all(H_left==0,2));
for i = 1:length(index)
    H_left(index(i),:) = [];
    H_right(index(i),:) = [];
    xL(index(i)) = [];
    xR(index(i)) = [];
end

g_left = H_left\xL;
g_right = H_right\xR;

%% PLOTZORZ
figure;
hold on;
plot(1:(400+length_HRTF-1 - length(index)),H_left*g_left,'b');
plot(1:(400+length_HRTF-1 - length(index)),xL,'r');
plot(1:(400+length_HRTF-1 - length(index)),H_right*g_right,'b');
plot(1:(400+length_HRTF-1 - length(index)),xR,'r');

synth_error_left = norm (H_left*g_left-xL);
synth_error_right = norm (H_right*g_right-xR);
disp(synth_error_left);
disp(synth_error_right);

%% READING FILE
fs_target = 8000;
length = 10;
[speech_sampled, fs_speech] = audioread('speech1.wav');
speech_resampled = resample(speech_sampled, fs_target, fs_speech);
speech_cut = speech_resampled(1:fs_target*length);

%% FILTERING
binaural_sig = zeros(size(speech_cut,1),nb_mics);


start_signal = fftfilt([g_left ; g_right],speech_cut);
for i=1:nb_mics
    
    for j=1:nb_audiosrc
        binaural_sig(:,i) = binaural_sig(:,i) + fftfilt(RIR_sources(:, i, j), start_signal);
    end
        
end
    
soundsc([binaural_sig(:,1) binaural_sig(:,2)],fs_target);


