% EXP6_WEIGHT_SENSITIVITY  How the optimal common tone exponent and its
% gain over gamma = 1 depend on the PSNR/SSIM/contrast weights (Baboon).
pkg load image
cfg = setup_cfg();
[chans, ~] = load_secret('baboon', cfg.res);
R1i = make_R1set([cfg.res cfg.res], cfg.nIndep, cfg.indepSeed);
G = 0.5:0.125:3.0; W = [0.4 0.4 0.2; 1/3 1/3 1/3; 0.6 0.2 0.2; 0.2 0.6 0.2; 0.2 0.2 0.6; 0 1 0];
Pn = zeros(numel(G),1); Ss = Pn; Cn = Pn;
for i = 1:numel(G)
    [~, d] = evaluate_design(chans, design_from_params([G(i) G(i) G(i)], 'gamma'), R1i, cfg.win);
    Pn(i) = mean(mean(min(d.psnr / 40, 1))); Ss(i) = mean(d.ssim(:)); Cn(i) = mean(mean(min(max(d.contrast,0) / 0.5, 1)));
end
fid = fopen(fullfile(cfg.outdir, 'exp6_weights.csv'), 'w');
fprintf(fid, 'w_psnr,w_ssim,w_contrast,best_gamma,q_best,q_gamma1,gain_pct\n');
i1 = find(abs(G - 1) < 1e-9);
for w = W'
    q = w(1) * Pn + w(2) * Ss + w(3) * Cn; [qb, ib] = max(q);
    fprintf(fid, '%.3f,%.3f,%.3f,%.3f,%.5f,%.5f,%.2f\n', w, G(ib), qb, q(i1), 100 * (qb / q(i1) - 1));
end
fclose(fid);
fid = fopen(fullfile(cfg.outdir, 'exp6_components.csv'), 'w');
fprintf(fid, 'gamma,psnr_norm,ssim,contrast_norm\n');
fprintf(fid, '%.3f,%.5f,%.5f,%.5f\n', [G; Pn'; Ss'; Cn']);
fclose(fid);
printf('exp6 done\n');
