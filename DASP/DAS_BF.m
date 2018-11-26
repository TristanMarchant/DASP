clear
run('MUSIC_wideband');
load('DOA_est')
load('Computed_RIRs.mat')
%%
[nb_samples, nb_mics, nb_audiosrc] = size(RIR_sources);
delays = zeros(1,nb_mics);
delays(1) = 0; 

for i = 2:nb_mics
    distance = m_pos(i,2) - m_pos(1,2);
    delays(i) = round(Calculate_TDOA(DOA_est,distance)*fs_RIR);
end

