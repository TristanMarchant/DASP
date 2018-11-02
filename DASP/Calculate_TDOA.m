function [TDOA] = Calculate_TDOA(DOA,distance)
% Calculates the TDOA based on the DOA and the distance between the mics
c = 340;
TDOA = cosd(DOA)*distance/c;
end

