function [qp, dE, sL] = perceptual_score(labS, rec01)
% PERCEPTUAL_SCORE  Iteration-4 objective for one perceived reconstruction:
%   Qp = 0.5 * (1 - mean CIEDE2000 / 50) + 0.5 * SSIM(L*_secret, L*_rec)
% labS  : CIELAB of the secret (precomputed); rec01 : sRGB reconstruction in [0,1]
    labR = srgb2lab(rec01);
    dE = mean(deltaE2000(labS, labR));
    sL = ssim_gauss(labS(:,:,1) / 100, labR(:,:,1) / 100);
    qp = 0.5 * (1 - dE / 50) + 0.5 * sL;
end
