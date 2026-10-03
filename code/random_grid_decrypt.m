function rec = random_grid_decrypt(S1, S2)
% RANDOM_GRID_DECRYPT  Physical/logical "stacking" of two random-grid
% shares: rec = S1 OR S2. Black pixels of the secret reconstruct as
% exact black; white pixels reconstruct as 50% gray speckle.
%
%   rec : double matrix in [0,1], 1 = black, 0.5 = reconstructed white
%         speckle (averaged over a local window for display/metrics),
%         0 = would only occur if both shares agreed white, which OR
%         never fully cancels out at pixel level -> we return the raw
%         stacked bitmap here; averaging for display is done by the
%         caller when down-sampling to gray levels.

    rec = double(S1 | S2);
end
