clear
run('DAS_BF');
load('VAD');
%% SECTION
L = 1024;
mu = 0.1;
blocking_matrix = [1 -1 0 0 0; 1 0 -1 0 0; 1 0 0 -1 0; 1 0 0 0 -1];
input_matrix = zeros(nb_mics,nb_min);
for i = 1:nb_mics
    input_matrix(i,:) = circshift(mic(:,i),delays(i));
end

output = zeros(1,nb_min); % nb_min = aantal samples
d = zeros(1,nb_min);
X = zeros(nb_mics-1,L);
X_extended = zeros(nb_mics-1,nb_min);
X_vector = zeros(1,L*(nb_mics-1));
W = zeros(nb_mics-1,L);
W_vector = zeros(1,L*(nb_mics-1));
DAS_out_delayed = circshift(DAS_out,L/2);
for i = 1:nb_min
%     for j = 1:nb_mics
%         d(i) = d(i) + input_matrix(j,i);
%     end
%     d(i) = d(i)/5;
    if i>L
        X = blocking_matrix * input_matrix(:,i-L:i-1);
        %X_extended = [X_extended X];
        X_vector = reshape(X',1,[]);
        % Updating of W
        output(i) = DAS_out_delayed(i) - W_vector*X_vector';
        if VAD(i) == 0
            W_vector = W_vector + mu/norm(X_vector,'fro')^2.*X_vector.*(DAS_out_delayed(i) - W_vector*X_vector');
        end
        
    end
    
end
%% Plots
output = output';
figure;
hold on;
plot(1:nb_min,mic(:,1),'b');
plot(1:nb_min,DAS_out,'r');
plot(1:nb_min,circshift(output,-L/2),'g');
plot(1:nb_min,DAS_speech/5,'black');
soundsc(output,fs_RIR);

%% SNR
noisepower_GSC = var(output(VAD==0,1));
speechpower_GSC = var(output(VAD==1,1)) - noisepower_GSC;
SNR_out_GSC = 10*log10(speechpower_GSC/noisepower_GSC);
disp(['SNR_in: ',num2str(SNR_in)]);
disp(['SNR_DAS_out: ', num2str(DAS_out_SNR)]);
disp(['SNR_out_GSC: ', num2str(SNR_out_GSC)]);
