function [qp, det] = evaluate_design_perceptual(chans, labS, designs, R1set, winSize, vivid)
% EVALUATE_DESIGN_PERCEPTUAL  Perceptual score Qp of a 3-channel design over
% a set of share grids (halftones computed once per channel).
    if nargin < 5, winSize = 4; end
    bw = cell(1, 3);
    for k = 1:3
        bw{k} = halftone(tone_precompensate(chans{k}, designs(k).gamma, designs(k).theta), designs(k).bias);
    end
    R = numel(R1set); qp = zeros(1, R); det.dE = qp; det.ssimL = qp; det.chromaVivid = nan(1, R);
    if nargin >= 6, CS = hypot(labS(:,:,2), labS(:,:,3)); end
    rec = zeros([size(chans{1}) 3]);
    for r = 1:R
        for k = 1:3
            [S1, S2] = random_grid_encrypt(bw{k}, R1set{r}{k});
            rec(:, :, k) = 1 - view_filter(S1 | S2, winSize);
        end
        [qp(r), det.dE(r), det.ssimL(r)] = perceptual_score(labS, rec);
        if nargin >= 6
            L = srgb2lab(rec); CR = hypot(L(:,:,2), L(:,:,3)); det.chromaVivid(r) = mean(CR(vivid)) / mean(CS(vivid));
        end
    end
end
