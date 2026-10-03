% EXP1_SPRINT3_DIAGNOSTICS  Sprint-3 evidence that triggered the redesign.
%  (a) halftone dot density vs. threshold bias (error diffusion preserves tone)
%  (b) independent quality vs. a common threshold bias  (Iteration-1 knob)
%  (c) independent quality vs. a common tone exponent    (Iteration-2 knob)
%  (d) noise level of a single-draw fitness evaluation
pkg load image
cfg = setup_cfg();
[chans, ~] = load_secret('baboon', cfg.res);
R1i = make_R1set([cfg.res cfg.res], cfg.nIndep, cfg.indepSeed);
names = {'C','M','Y'};

fid = fopen(fullfile(cfg.outdir, 'exp1a_density_vs_bias.csv'), 'w');
fprintf(fid, 'channel,mean_ink,bias,black_fraction,pct_pixels_changed_vs_bias0\n');
for k = 1:3
    bw0 = halftone(chans{k}, 0);
    for b = -80:10:80
        bw = halftone(chans{k}, b);
        fprintf(fid, '%s,%.4f,%d,%.4f,%.2f\n', names{k}, mean(chans{k}(:))/255, b, mean(bw(:)), 100*mean(bw(:) ~= bw0(:)));
    end
end
fclose(fid);

fid = fopen(fullfile(cfg.outdir, 'exp1b_quality_vs_bias.csv'), 'w');
fprintf(fid, 'bias,q_mean,q_sd,psnr_mean,ssim_mean,contrast_mean\n');
for b = -80:20:80
    [q, d] = evaluate_design(chans, design_from_params([b b b], 'bias'), R1i, cfg.win);
    fprintf(fid, '%d,%.5f,%.5f,%.3f,%.4f,%.4f\n', b, mean(q), std(q), mean(d.psnr(:)), mean(d.ssim(:)), mean(d.contrast(:)));
end
fclose(fid);

fid = fopen(fullfile(cfg.outdir, 'exp1c_quality_vs_gamma.csv'), 'w');
fprintf(fid, 'gamma,q_mean,q_sd,psnr_mean,ssim_mean,contrast_mean,black_fraction\n');
for g = 0.5:0.25:3.0
    [q, d] = evaluate_design(chans, design_from_params([g g g], 'gamma'), R1i, cfg.win);
    bf = mean(cellfun(@(c) mean(mean(halftone(tone_precompensate(c, g), 0))), chans));
    fprintf(fid, '%.2f,%.5f,%.5f,%.3f,%.4f,%.4f,%.4f\n', g, mean(q), std(q), mean(d.psnr(:)), mean(d.ssim(:)), mean(d.contrast(:)), bf);
end
fclose(fid);
printf('exp1 done\n');
