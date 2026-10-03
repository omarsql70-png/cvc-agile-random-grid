function [q, detail] = evaluate_design(chans, designs, R1set, winSize)
% EVALUATE_DESIGN  Quality of a 3-channel design averaged over a set of
% share-1 random grids (same pipeline as build_cvc_channel, with the
% deterministic tone/halftone stage computed once per channel).
%   chans  : {C, M, Y} original density channels, [0,255]
%   designs: 1x3 struct array (fields bias, gamma)
%   R1set  : cell array, R1set{r}{k} = logical grid for draw r, channel k
%   q      : 1 x numel(R1set) per-draw quality scores (quality_score.m)
%   detail : per-draw psnr/ssim/contrast, one column per channel
    if nargin < 4, winSize = 4; end
    R = numel(R1set);
    q = zeros(1, R);
    detail.psnr = zeros(R, 3); detail.ssim = zeros(R, 3); detail.contrast = zeros(R, 3);
    bw = cell(1, 3); orig = cell(1, 3);
    for k = 1:3
        th = 0; if isfield(designs, 'theta'), th = designs(k).theta; end
        bw{k}   = halftone(tone_precompensate(chans{k}, designs(k).gamma, th), designs(k).bias);
        orig{k} = double(chans{k}) / 255;
    end
    for r = 1:R
        for k = 1:3
            [S1, S2] = random_grid_encrypt(bw{k}, R1set{r}{k});
            m = eval_metrics(orig{k}, view_filter(random_grid_decrypt(S1, S2), winSize), bw{k});
            detail.psnr(r, k) = m.psnr; detail.ssim(r, k) = m.ssim; detail.contrast(r, k) = m.contrast;
        end
        ms = struct('psnr', num2cell(detail.psnr(r, :)), 'ssim', num2cell(detail.ssim(r, :)), ...
                    'contrast', num2cell(detail.contrast(r, :)));
        q(r) = quality_score(ms);
    end
end
