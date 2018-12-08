clear
load('Computed_RIRs.mat');
load('HRTF');
[nb_samples, nb_mics, nb_audiosrc] = size(RIR_sources);
length_RIR = 1500;
length_HRTF = 1000;
RIR_sources_cut = RIR_sources(1:length_RIR,:,:);
xL = HRTF(:,1);
xL = xL(1:length_RIR+length_HRTF-1);
xR = HRTF(:,2);
xR = xR(1:length_RIR+length_HRTF-1);

%xL = [ 1 ; zeros(length_RIR+length_HRTF-2,1)];
%xR = [ 1 ; zeros(length_RIR+length_HRTF-2,1)];

Delta = ceil(sqrt(room_dim(1)^2+room_dim(2)^2)*fs_RIR/340);
xL = circshift(xL,Delta);
xR = circshift(xR,Delta);
%X = [xL ; xR];
%X = circshift(X, Delta);
%% H matrix
H_left = [];
H_right = [];
H = [];
for i = 1:nb_audiosrc
    H_left = [H_left convmtx(RIR_sources_cut(:,1,i),length_HRTF)];
    H_right = [H_right convmtx(RIR_sources_cut(:,2,i),length_HRTF)];
    %H = [H [convmtx(RIR_sources_cut(:,1,i),length_HRTF); convmtx(RIR_sources_cut(:,2,i),length_HRTF)]];
end
X = [xL ; xR];
H = [H_left ; H_right];
% Set Delete zero rows
%index = find(all(H==0,2));
indexH = any(H,2);
H(indexH==0,:) = [];
X(indexH==0,:) = [];
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
    speechfiles{i} = fftfilt(g((i-1)*length_HRTF+1:i*length_HRTF),speech_cut);
end



%start_signal = fftfilt(g,speech_cut);
for i=1:nb_mics
    
    for j=1:nb_audiosrc
        binaural_sig(:,i) = binaural_sig(:,i) + fftfilt(RIR_sources(:, i, j), speechfiles{j});
    end
        

end
    
soundsc([binaural_sig(:,1) binaural_sig(:,2)],fs_target);


