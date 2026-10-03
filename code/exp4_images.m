% EXP4_IMAGES  Generalization: Astronaut, Coffee, Chelsea (Baboon comes
% from exp2), 5 seeds each, both design iterations, GWO.
pkg load image
cfg = setup_cfg();
[fr, fc] = open_results(cfg.outdir, 'exp4');
rf = fullfile(cfg.outdir, 'exp4_runs.csv');
for img = {'astronaut', 'coffee', 'chelsea'}
    [chans, ~] = load_secret(img{1}, cfg.res);
    cfg.R1indep = make_R1set([cfg.res cfg.res], cfg.nIndep, cfg.indepSeed);
    qb = evaluate_design(chans, design_from_params([0 0 0], 'bias'), cfg.R1indep, cfg.win);
    for mode = {'bias', 'gamma'}
        for s = 1:5
            if run_done(rf, img{1}, mode{1}, 'GWO', s), continue; end
            out = run_design_search(chans, mode{1}, 'GWO', s, cfg);
            save_run(fr, fc, img{1}, mode{1}, 'GWO', s, out, mean(qb));
            printf('[exp4] %s %s seed %d: indep %.5f (baseline %.5f)\n', img{1}, mode{1}, s, out.indep_mean, mean(qb)); fflush(stdout);
        end
    end
end
fclose(fr); fclose(fc);
