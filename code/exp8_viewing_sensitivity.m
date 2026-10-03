% EXP8_VIEWING_SENSITIVITY  Does the Iteration-2 conclusion depend on the
% viewing window or on the working resolution? Baboon, common gamma grid.
pkg load image
cfg = setup_cfg();
fid = fopen(fullfile(cfg.outdir, 'exp8_viewing.csv'), 'w');
fprintf(fid, 'resolution,window,n_grids,q_gamma1,best_gamma,q_best,gain_pct,q_bias_m80,q_bias_p80\n');
G = 0.5:0.25:3.0;
for res = [264 512]
    [chans, ~] = load_secret('baboon', res);
    nG = 30 * (res == 264) + 10 * (res == 512);
    R1 = make_R1set([res res], nG, cfg.indepSeed + res);
    for w = [2 3 4 6 8]
        q = arrayfun(@(g) mean(evaluate_design(chans, design_from_params([g g g], 'gamma'), R1, w)), G);
        qm = mean(evaluate_design(chans, design_from_params([-80 -80 -80], 'bias'), R1, w));
        qp = mean(evaluate_design(chans, design_from_params([80 80 80], 'bias'), R1, w));
        [qb, ib] = max(q); q1 = q(G == 1);
        fprintf(fid, '%d,%d,%d,%.5f,%.2f,%.5f,%.2f,%.5f,%.5f\n', res, w, nG, q1, G(ib), qb, 100*(qb/q1-1), qm, qp); fflush(fid);
        printf('res %d win %d: Q(g=1)=%.4f best g=%.2f Q=%.4f gain %+.1f%% | bias -80 %.4f +80 %.4f\n', res, w, q1, G(ib), qb, 100*(qb/q1-1), qm, qp); fflush(stdout);
    end
end
fclose(fid);
