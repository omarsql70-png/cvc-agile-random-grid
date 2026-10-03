% EXP2_ITERATIONS  Baboon, 12 seeds, GWO: design Iteration 1 (threshold
% bias) vs. design Iteration 2 (tone pre-compensation). Every run is
% re-scored on 30 independent share grids the optimizer never saw.
pkg load image
cfg = setup_cfg();
[chans, ~] = load_secret('baboon', cfg.res);
cfg.R1indep = make_R1set([cfg.res cfg.res], cfg.nIndep, cfg.indepSeed);
qb = evaluate_design(chans, design_from_params([0 0 0], 'bias'), cfg.R1indep, cfg.win);
save('-ascii', fullfile(cfg.outdir, 'exp2_baseline_indep_scores.txt'), 'qb');
[fr, fc] = open_results(cfg.outdir, 'exp2');
rf = fullfile(cfg.outdir, 'exp2_runs.csv');
for mode = {'bias', 'gamma'}
    for s = cfg.seeds
        if run_done(rf, 'baboon', mode{1}, 'GWO', s), continue; end
        out = run_design_search(chans, mode{1}, 'GWO', s, cfg);
        save_run(fr, fc, 'baboon', mode{1}, 'GWO', s, out, mean(qb));
        printf('[exp2] %s seed %d: search %.5f indep %.5f (baseline %.5f) params %s\n', mode{1}, s, ...
            out.search_score, out.indep_mean, mean(qb), mat2str(out.params, 4)); fflush(stdout);
    end
end
fclose(fr); fclose(fc);
