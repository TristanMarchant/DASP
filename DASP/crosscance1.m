clear
load('Computed_RIRs.mat');
load('HRTF');
[nb_samples, nb_mics, nb_audiosrc] = size(RIR_sources);
Lh = 1500; %Lh
Lg = 1000; %Lg
RIR_sources_cut = RIR_sources(1:Lh,:,:);


xL = [ 1 ; zeros(Lh+Lg-2,1)];
xR = [ 1 ; zeros(Lh+Lg-2,1)];

situation = 3; %CONTROL FOR THE SITUATIONS

if situation == 1
    xL = xL;
    
elseif situation == 2
    xR = .5*xR;
    
elseif situation == 3
    xR = circshift(xR,3);
    
elseif situation == 4
    xL = HRTF(:,1);
    xL = xL(1:Lh+Lg-1);
    xR = HRTF(:,2);
    xR = xR(1:Lh+Lg-1);
end

Delta = ceil(sqrt(room_dim(1)^2+room_dim(2)^2)*fs_RIR/340);
xL = circshift(xL,Delta);
xR = circshift(xR,Delta);

%% H matrix
H_left = [];
H_right = [];
H = [];
for i = 1:nb_audiosrc
    H_left = [H_left convmtx(RIR_sources_cut(:,1,i),Lg)];
    H_right = [H_right convmtx(RIR_sources_cut(:,2,i),Lg)];
    %H = [H [convmtx(RIR_sources_cut(:,1,i),length_HRTF); convmtx(RIR_sources_cut(:,2,i),length_HRTF)]];
end
X = [xL ; xR];
H = [H_left ; H_right];
% Set Delete zero rows
%index = find(all(H==0,2));
indexH = any(H,2);
H(indexH==0,:) = [];
X(indexH==0,:) = [];

%% ADD NOISE TO H
add_noise = 0;

if add_noise
    std_H_col1 = std(H(:,1));
    std_noise = 0.05*std_H_col1;
    power_noise = std_noise^2;
    [m,n] = size(H);
    noise = wgn(m, n, power_noise);
    H = H + noise; %note: the 0s are noised too this way
end

%% COMPUTE G
% for i = 1:length(index)
%     %H_left(index(i),:) = [];
%     %H_right(index(i),:) = [];
%     %xL(index(i)) = [];
%     %xR(index(i)) = [];
%     H(index(i),:) = [];
%     X(index(i)) = [];
% end
% for i = 1:length(indexH)
%     H(indexH(i),:) = [];
%     X(indexH(i)) = [];
% end
%Stille zero rows in H!
% indexi = [];
% for i = 1:(size(H,1)-2)
%     if norm(H(i,:)) ==0
%         indexi = [indexi i];
%     end
% end
% for i = length(indexi):-1:1
%     H(indexi(i),:) = [];
%     X(indexi(i)) = [];
% end

%g_left = H_left\xL;
%g_right = H_right\xR;


g =  H \ X;

%% PLOTZORZ

figure;
hold on;
%plot(1:(400+length_HRTF-1 - length(index)),H_left*g_left,'b');
%plot(1:(400+length_HRTF-1 - length(index)),xL,'r');
%plot(1:(400+length_HRTF-1 - length(index)),H_right*g_right,'b');
%plot(1:(400+length_HRTF-1 - length(index)),xR,'r');
plot(H*g,'b');
plot(X,'r');

%synth_error_left = norm (H_left*g_left-xL);
%synth_error_right = norm (H_right*g_right-xR);
synth_error = norm(H*g - X);
%disp(synth_error_left);
%disp(synth_error_right);
disp(synth_error);

%% READING FILE
fs_target = 8000;
length = 10; %in seconds
[speech_sampled, fs_speech] = audioread('speech1.wav');
speech_resampled = resample(speech_sampled, fs_target, fs_speech);
speech_cut = speech_resampled(1:fs_target*length);

%% RECONSTRUCTION
binaural_sig = zeros(size(speech_cut,1),nb_mics);

for i = 1:nb_audiosrc
    speechfiles{i} = fftfilt(g((i-1)*Lg+1:i*Lg), speech_cut);
end

%start_signal = fftfilt(g,speech_cut);
for i=1:nb_mics
    for j=1:nb_audiosrc
        binaural_sig(:,i) = binaural_sig(:,i) + fftfilt(RIR_sources(:, i, j), speechfiles{j}); %speechfiles{j}
    end
end

% for i=1:nb_mics
%     for j=1:nb_audiosrc
%         temp = fftfilt(RIR_sources(:, i, j), speech_cut);
%         temp = fftfilt(g((j-1)*length_HRTF+1:j*length_HRTF), temp);
%         binaural_sig(:,i) = binaural_sig(:,i) + temp;
%     end
% end

    
soundsc([binaural_sig(:,1) binaural_sig(:,2)],fs_target);
