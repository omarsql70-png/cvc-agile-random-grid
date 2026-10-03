function m = eval_metrics(orig01, rec01, bwHalftone)
% EVAL_METRICS  Reconstruction metrics for one channel.
%   orig01     : ORIGINAL colorant-density channel of the secret, in [0,1]
%   rec01      : perceived reconstruction (view-filtered stacked shares),
%                ink fraction in [0,1]
%   bwHalftone : the halftone map the shares were built from
%   m.psnr     : PSNR (dB) between orig01 and rec01, peak = 1
%   m.ssim     : standard SSIM (ssim_gauss)
%   m.contrast : random-grid contrast in the sense of Shyu (2007),
%                alpha = (mu_B - mu_W) / (1 + mu_W), where mu_B / mu_W are
%                the mean perceived ink over secret-black / secret-white
%                halftone pixels (ink-fraction convention)
%   m.pixel_expansion : 1 (share size == secret size)
    mse = mean((orig01(:) - rec01(:)).^2);
    m.psnr = 10 * log10(1 / max(mse, 1e-10));
    m.ssim = ssim_gauss(orig01, rec01);
    muB = mean(rec01(bwHalftone));
    muW = mean(rec01(~bwHalftone));
    if isempty(muB) || isnan(muB), muB = 1; end
    if isempty(muW) || isnan(muW), muW = 0; end
    m.contrast = (muB - muW) / (1 + muW);
    m.pixel_expansion = 1;
end
