clear
run('MUSIC_wideband');
load('DOA_est')
load('Computed_RIRs.mat')
load('VAD')
%% SECTION
[nb_samples, nb_mics, nb_audiosrc] = size(RIR_sources);
delays = zeros(1,nb_mics);
delays(1) = 0; 

for i = 2:nb_mics
    distance = m_pos(i,2) - m_pos(1,2);
    delays(i) = round(Calculate_TDOA(DOA_est,distance)*fs_RIR);
end


load('mic');
load('speech');
load('noise');
DAS_out = zeros(size(mic,1),1);
DAS_speech = zeros(size(speech,1),1);
DAS_noise = zeros(size(noise,1),1);
for i = 1:nb_mics
    DAS_out = DAS_out + circshift(mic(:,i),delays(i));
    DAS_speech = DAS_speech + circshift(speech(:,i),delays(i));
    DAS_noise = DAS_noise + circshift(noise(:,i), delays(i));
end
%assert(isequal(DAS_out,(DAS_speech + DAS_noise)));

DAS_out = DAS_out/5;

figure;
hold on;
plot(1:nb_min,mic(:,1),'b');
plot(1:nb_min,DAS_out,'r');

%VAD = abs(DAS_out(:,1))>std(DAS_out(:,1))*1e-3; % Heeft maar 0.01 SNR invloed, dus mss niet meer nodig

DAS_out_SNR = 10*log10(var(DAS_speech(VAD==1,1))/var(DAS_noise));

load('SNR_in');
disp(['SNR_in: ',num2str(SNR_in)]);
disp(['SNR_DAS_out: ', num2str(DAS_out_SNR)]);

%soundsc(mic(:,1),fs_RIR);
%soundsc(DAS_out,fs_RIR);
