% EXP3_OPTIMIZERS  Same-harness optimizer comparison on the Iteration-2
% task (Baboon, 12 seeds, 400 evaluations each). GWO runs come from exp2;
% this script adds BDA, the corrected BHHO and pure random search.
pkg load image
cfg = setup_cfg();
[chans, ~] = load_secret('baboon', cfg.res);
cfg.R1indep = make_R1set([cfg.res cfg.res], cfg.nIndep, cfg.indepSeed);
qb = load(fullfile(cfg.outdir, 'exp2_baseline_indep_scores.txt'));
[fr, fc] = open_results(cfg.outdir, 'exp3');
rf = fullfile(cfg.outdir, 'exp3_runs.csv');
for opt = {'BDA', 'HHO', 'RS'}
    for s = cfg.seeds
        if run_done(rf, 'baboon', 'gamma', opt{1}, s), continue; end
        out = run_design_search(chans, 'gamma', opt{1}, s, cfg);
        save_run(fr, fc, 'baboon', 'gamma', opt{1}, s, out, mean(qb));
        printf('[exp3] %s seed %d: search %.5f indep %.5f evals %d\n', opt{1}, s, out.search_score, out.indep_mean, out.evals); fflush(stdout);
    end
end
fclose(fr); fclose(fc);
