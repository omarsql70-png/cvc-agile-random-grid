% EXP12B_BUDGET  Is Iteration 4 limited by the search budget? Seeds 1-3
% repeated with twice the evaluations (T = 50, 800 evaluations).
pkg load image
cfg = setup_cfg(); cfg.T = 50;
[chans, rgb] = load_secret('baboon', cfg.res);
cfg.labS = srgb2lab(double(rgb) / 255);
cfg.R1indep = make_R1set([cfg.res cfg.res], cfg.nIndep, cfg.indepSeed);
fr = fullfile(cfg.outdir, 'exp12b_budget.csv');
if ~exist(fr, 'file'), f = fopen(fr, 'w'); fprintf(f, 'image,mode,optimizer,seed,search_qp,indep_qp,indep_q,indep_dE,indep_ssimL,evals\n'); fclose(f); end
for s = 1:3
    if run_done(fr, 'baboon', 'knee4', 'GWO', s), continue; end
    out = run_design_search(chans, 'knee4', 'GWO', s, cfg);
    f = fopen(fr, 'a'); fprintf(f, 'baboon,knee4,GWO,%d,%.6f,%.6f,%.6f,%.4f,%.5f,%d\n', s, out.search_score, out.indep_qp, out.indep_mean, out.indep_dE, out.indep_ssimL, out.evals); fclose(f);
    printf('[exp12b] seed %d: Qp %.4f\n', s, out.indep_qp); fflush(stdout);
end
