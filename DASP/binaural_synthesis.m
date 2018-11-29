%% Parameters
clear
length = 10;
fs_target = 8000;
load('HRTF');
%% Binauralsig _1
[speech_sampled, fs_speech] = audioread('speech1.wav');
speech_resampled = resample(speech_sampled, fs_target, fs_speech);
x = speech_resampled(1:fs_target*length);
binaural_sig1_1 = [x x];
binaural_sig2_1 = [x 0.5*x];
binaural_sig3_1 = [x circshift(x,3)];
binaural_sig4_1 = [fftfilt(HRTF(:,1),x) fftfilt(HRTF(:,2),x)];
%% Binauralsig _2
[speech_sampled2, fs_speech2] = audioread('speech2.wav');
speech_resampled2 = resample(speech_sampled2, fs_target, fs_speech2);
x = speech_resampled2(1:fs_target*length);
binaural_sig1_2 = [x x];
binaural_sig2_2 = [0.5*x x];
binaural_sig3_2 = [circshift(x,3) x];
binaural_sig4_2 = [fftfilt(HRTF(:,2),x) fftfilt(HRTF(:,1),x)];
%% Binauralsig total
binaural_sig1 = binaural_sig1_1 + binaural_sig1_2;
binaural_sig2 = binaural_sig2_1 + binaural_sig2_2;
binaural_sig3 = binaural_sig3_1 + binaural_sig3_2;
binaural_sig4 = binaural_sig4_1 + binaural_sig4_2;
%% Play sound
soundsc([binaural_sig4(:,1) binaural_sig4(:,2)], fs_target);
