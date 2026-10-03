function [q, parts] = quality_score(ms)
% QUALITY_SCORE  Aggregate Sprint-3 objective over the three channels:
%   q = 0.4*mean(min(PSNR/40,1)) + 0.4*mean(SSIM) + 0.2*mean(min(alpha/0.5,1))
%   ms : 1x3 struct array of eval_metrics outputs (C, M, Y)
    p = [ms.psnr]; s = [ms.ssim]; c = [ms.contrast];
    parts.psnr_norm = mean(min(p / 40, 1));
    parts.ssim = mean(s);
    parts.contrast_norm = mean(min(max(c, 0) / 0.5, 1));
    q = 0.4 * parts.psnr_norm + 0.4 * parts.ssim + 0.2 * parts.contrast_norm;
end
