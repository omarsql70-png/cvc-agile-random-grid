% EXP10_POSTERIZATION_CHECK  Why gamma is bounded below by 0.5 in Iteration 3:
% as gamma -> 0 the knee curve becomes a hard threshold (posterization);
% Q keeps rising through its contrast term while CIEDE2000 deteriorates.
pkg load image
cfg = setup_cfg();
[chans, rgb] = load_secret('baboon', cfg.res); labS = srgb2lab(double(rgb) / 255);
R = make_R1set([cfg.res cfg.res], 10, cfg.indepSeed);
fid = fopen(fullfile(cfg.outdir, 'exp10_posterization.csv'), 'w');
fprintf(fid, 'theta,gamma,q,kappa,ssim_channel,dE00,ssim_L\n');
for th = [0.5 0.6]
    for g = [1 0.75 0.5 0.25 0.1 0.01]
        D = design_from_params([th th th g g g], 'thetagamma');
        [q, det] = evaluate_design(chans, D, R, cfg.win);
        de = 0; sl = 0;
        for r = 1:10
            L = srgb2lab(reconstruct_rgb(chans, D, R{r}, cfg.win));
            de = de + mean(deltaE2000(labS, L)) / 10; sl = sl + ssim_gauss(labS(:,:,1)/100, L(:,:,1)/100) / 10;
        end
        fprintf(fid, '%.2f,%.2f,%.5f,%.4f,%.4f,%.3f,%.4f\n', th, g, mean(q), mean(det.contrast(:)), mean(det.ssim(:)), de, sl);
    end
end
fclose(fid);
