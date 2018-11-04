
load('Computed_RIRs.mat');
%--- PARAMETERS ------------------%
L = 1024; %window
overlap = 0.5;
Q = size(RIR_sources,3);

%---- CHECK FOR SAMPLE FREQ-------%
if fs_RIR ~= 44100
    error('DASP: invalid sample frequency, should be 44100 Hz');
end

%---- CREATE MICSIGS ------------%
speechfiles{1} = 'speech1.wav';
speechfiles{2} = 'speech2.wav';
noisefiles{1} = 'Babble_noise1.wav'; %best let one noise file on, even if not used
mic = create_micsigs_func(speechfiles,noisefiles,10);
mic_size = size(mic);
mic_size1 = mic_size(1);
mic_nb = mic_size(2);

%---- STFTs --------------------%
nb_freqs = L*overlap+1;
nb_times =  ceil(mic_size1*1/nb_freqs);
stft_mtx = zeros(mic_nb, nb_freqs, nb_times);
%size = mics x freqs x times
%size depends on spectrogram output
%TODO: don't exactly know why + 1 and stuff...
for i = 1:mic_nb
    stft_mtx(i,:,:) = spectrogram(mic(:,i),hann(L),overlap*L);
%TODO: maybe 4th argument for less samples
%TODO: outputs 513 frequency bins?
end

%---- PSEUDOSPECTRUM -----------%
thetas = 0:0.5:180;
n0_thetas = size(thetas,2);
result_add = zeros(n0_thetas,1);
figure;
hold on
for freq = 2:(L/2)
    
    omega = 2*pi*(freq-0.5)*fs_RIR/L;

    Y = reshape( stft_mtx(:, freq, :), mic_nb, nb_times );
    R = Y * Y';

    [V,D] = eig(R); 
    [~,I] = sort( diag(D), 'descend' ); 
    V_sorted = V(:,I);
    E = V_sorted(:,(Q+1):end); 

    G = [ones(1,n0_thetas); zeros(mic_nb-1,n0_thetas)];
    for i = 2:mic_nb
        distance = m_pos(i,2) - m_pos(1,2);
        for l = 1:n0_thetas
            DOA = thetas(l);
            TDOA = Calculate_TDOA(DOA,distance);
            G(i,l) = exp(1j*omega*TDOA);
        end
    end

    numerator = diag(G'*(E*E')*G);
    P = 1./numerator;
    plot(thetas,abs(P));
    logarithmic_P = log(P);
    result_add = result_add+logarithmic_P;
end
exponent = 1/(L/2-1);
final_log = exponent*result_add;
final = exp(final_log);

figure;
hold on
plot(thetas,abs(final));
title('Averaged Pseudospectrum')
xlabel('Angle theta')
ylabel('Magnitude')

[~, indexes] = findpeaks(abs(final),'SortStr','descend');


DOA_est = zeros(1,Q);
for m = 1:Q
    DOA_est(m) = thetas(indexes(m));
end

for index = 1:Q
    value = abs(final(DOA_est(index)*2+1));
    stem(DOA_est(index),value);
end
save DOA_est

%---- DOA OF SPEECH SOURCE -----%

%QUESTION ABOUT REVERBERATION: GETS WAY BETTER FROM CLOSE, THERE ARE
%MULTIPLE PEAKS NOW AND THE RIGHT PEAK GETS LARGER WHEN PUTTING THE SOURCE
%CLOSER.

