function [S1, S2] = random_grid_encrypt(bw, R1)
% RANDOM_GRID_ENCRYPT  (2,2) random-grid visual secret sharing
% (Kafri & Keren, 1987) of one binary halftone channel.
%   bw : logical, true = black secret pixel
%   R1 : optional logical random grid of size(bw) (share 1). If omitted it
%        is drawn as fair coin flips. Passing R1 explicitly lets the
%        experiments use common random numbers and independent re-draws.
%   S1 = R1;  S2 = R1 where bw is white, ~R1 where bw is black.
% Each share alone is uniformly random and independent of bw; S1 OR S2 is
% black on every black secret pixel and 50% black on white pixels.
% Shares are the same size as bw (no pixel expansion).
    if nargin < 2 || isempty(R1)
        R1 = rand(size(bw)) < 0.5;
    end
    S1 = logical(R1);
    S2 = S1;
    S2(bw) = ~S1(bw);
end
