clear
clear sound
load('Computed_RIRs.mat');
load('HRTF');
[nb_samples, nb_mics, nb_audiosrc] = size(RIR_sources);
Lh = 400;
RIR_sources_cut = RIR_sources(1:Lh,:,:); %Lh = 400 (number of h(..))
Lg = 100; 
%Lg > Lh according to convolution (Lb > La) 
%<-> but in conflict with "we assume that the length of the HRTFs
%(=Lh+Lg-1) is much smaller than Lh"


xL = HRTF(:,1);
xL = xL(1:Lh + Lg - 1); %length HRTF = Lh + Lg -1
xR = HRTF(:,2);
xR = xR(1:Lh + Lg - 1);

%xL = [ zeros(300,1); 1 ; zeros(Lh+Lg-300-2,1)]; %should be Lh + Lg -1 long
%xL = [ 1 ; zeros(Lh+Lg-2,1)];
%xR = [ 1 ; zeros(Lh+Lg-2,1)];

Delta = ceil(sqrt(room_dim(1)^2+room_dim(2)^2)*fs_RIR/340);
xL = circshift(xL,Delta);
xR = circshift(xR,Delta); 
%% H matrix
H_left = [];
H_right = [];
for i = 1:nb_audiosrc
    H_left = [H_left convmtx(RIR_sources_cut(:,1,i),Lg)]; %second parameter should be Lg
    H_right = [H_right convmtx(RIR_sources_cut(:,2,i),Lg)];
end
% Set Delete zero rows 
% UPDATE: delete seperately for left and right

index = find(all(H_left==0,2));
for i = 1:length(index)
    H_left(index(i),:) = [];
    xL(index(i)) = [];
end

index = find(all(H_right==0,2));
for i = 1:length(index)
    H_right(index(i),:) = [];
    xR(index(i)) = [];
end


g_left = H_left\xL;
g_right = H_right\xR;

%% PLOTZORZ
% figure;
% hold on;
% plot(1:(400+length_HRTF-1 - length(index)),H_left*g_left,'b');
% plot(1:(400+length_HRTF-1 - length(index)),xL,'r');
% plot(1:(400+length_HRTF-1 - length(index)),H_right*g_right,'b');
% plot(1:(400+length_HRTF-1 - length(index)),xR,'r');
% 
synth_error_left = norm (H_left*g_left-xL);
synth_error_right = norm (H_right*g_right-xR);
disp(synth_error_left);
disp(synth_error_right);

%% READING FILE
fs_target = 8000;
length = 10; %in seconds
[speech_sampled, fs_speech] = audioread('speech1.wav');
speech_resampled = resample(speech_sampled, fs_target, fs_speech);
speech_cut = speech_resampled(1:fs_target*length);

%% FILTERING
binaural_sig = zeros(size(speech_cut,1),nb_mics);


%start_signal = fftfilt([g_left ; g_right],speech_cut);
%Left
for j=1:nb_audiosrc
    temp = fftfilt(RIR_sources(:,1,j), speech_cut); %first with room
    binaural_sig(:,1) = binaural_sig(:,1) + fftfilt(g_left((j-1)*Lg + 1: j*Lg),temp); %then with g
end

%Right
for j=1:nb_audiosrc
    temp = fftfilt(RIR_sources(:,2,j), speech_cut);
    binaural_sig(:,2) = binaural_sig(:,2) + fftfilt(g_right((j-1)*Lg + 1: j*Lg),temp);
end
    
soundsc([binaural_sig(:,1) binaural_sig(:,2)],fs_target);


