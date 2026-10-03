% EXP12_ITERATION4  Design Iteration 4 on Baboon: the contrast-driven Q is
% replaced by a perceptual objective Qp (CIEDE2000 + lightness SSIM) and the
% gamma guard of Iteration 3 is relaxed to [0.1, 3]. Every reference design
% is re-scored with both Q and Qp on the same 30 independent grids.
pkg load image
cfg = setup_cfg();
[chans, rgb] = load_secret('baboon', cfg.res);
cfg.labS = srgb2lab(double(rgb) / 255);
cfg.R1indep = make_R1set([cfg.res cfg.res], cfg.nIndep, cfg.indepSeed);
fref = fullfile(cfg.outdir, 'exp12_reference.csv');
if ~exist(fref, 'file')
    f = fopen(fref, 'w'); fprintf(f, 'design,seed,q,qp,dE00,ssimL\n');
    T9 = csv2cell_simple(fullfile(cfg.outdir, 'exp9_runs.csv')); T2 = csv2cell_simple(fullfile(cfg.outdir, 'exp2_runs.csv'));
    D = {{'baseline', 0, design_from_params([0 0 0], 'bias')}, {'analytic', 0, design_from_params([], 'analytic')}};
    for s = 1:12
        p2 = cellfun(@str2double, T2(strcmp(T2(:,2), 'gamma') & strcmp(T2(:,4), num2str(s)), 5:7));
        p3 = cellfun(@str2double, T9(strcmp(T9(:,1), 'baboon') & strcmp(T9(:,4), num2str(s)), 5:10));
        D{end+1} = {'iter2', s, design_from_params(p2, 'gamma')}; D{end+1} = {'iter3', s, design_from_params(p3, 'thetagamma')};
    end
    for j = 1:numel(D)
        q = evaluate_design(chans, D{j}{3}, cfg.R1indep, cfg.win);
        [qp, dp] = evaluate_design_perceptual(chans, cfg.labS, D{j}{3}, cfg.R1indep, cfg.win);
        fprintf(f, '%s,%d,%.6f,%.6f,%.4f,%.5f\n', D{j}{1}, D{j}{2}, mean(q), mean(qp), mean(dp.dE), mean(dp.ssimL));
    end
    fclose(f);
end
fr = fullfile(cfg.outdir, 'exp12_runs.csv'); fcv = fullfile(cfg.outdir, 'exp12_curves.csv');
if ~exist(fr, 'file')
    f = fopen(fr, 'w'); fprintf(f, 'image,mode,optimizer,seed,theta_C,theta_M,theta_Y,gamma_C,gamma_M,gamma_Y,search_qp,indep_qp,indep_q,indep_dE,indep_ssimL,evals\n'); fclose(f);
    f = fopen(fcv, 'w'); fprintf(f, 'image,mode,optimizer,seed,curve\n'); fclose(f);
end
for s = 1:12
    if run_done(fr, 'baboon', 'knee4', 'GWO', s), continue; end
    out = run_design_search(chans, 'knee4', 'GWO', s, cfg);
    f = fopen(fr, 'a'); fprintf(f, 'baboon,knee4,GWO,%d,%.4f,%.4f,%.4f,%.4f,%.4f,%.4f,%.6f,%.6f,%.6f,%.4f,%.5f,%d\n', s, out.params, ...
        out.search_score, out.indep_qp, out.indep_mean, out.indep_dE, out.indep_ssimL, out.evals); fclose(f);
    f = fopen(fcv, 'a'); fprintf(f, 'baboon,knee4,GWO,%d,%s\n', s, sprintf('%.6f;', out.curve)); fclose(f);
    printf('[exp12] seed %d: Qp %.4f Q %.4f dE %.2f params %s\n', s, out.indep_qp, out.indep_mean, out.indep_dE, mat2str(out.params, 3)); fflush(stdout);
end
