% EXP13_KODAK  Benchmark on the 24 Kodak images (center-cropped, 264x264):
% baseline, closed-form inverse and the accepted Iteration-3 design (one
% search per image, seed 1); every design is
% re-scored with Q and Qp on 10 independent grids. Resumable per image.
pkg load image
cfg = setup_cfg(); cfg.nIndep = 10;
fn = fullfile(cfg.outdir, 'exp13_kodak.csv');
if ~exist(fn, 'file')
    f = fopen(fn, 'w'); fprintf(f, 'image,design,theta_C,theta_M,theta_Y,gamma_C,gamma_M,gamma_Y,q,qp,dE00,ssimL,chroma_vivid,vivid_frac\n'); fclose(f);
end
for k = 1:24
    name = sprintf('kodim%02d', k);
    if ~isempty(strfind(fileread(fn), [name ',iter3'])), continue; end
    [chans, rgb] = load_secret(fullfile('kodak', name), cfg.res);
    cfg.labS = srgb2lab(double(rgb) / 255); viv = hypot(cfg.labS(:,:,2), cfg.labS(:,:,3)) > 40;
    if ~any(viv(:)), viv = hypot(cfg.labS(:,:,2), cfg.labS(:,:,3)) >= prctile(reshape(hypot(cfg.labS(:,:,2), cfg.labS(:,:,3)), [], 1), 90); end
    cfg.R1indep = make_R1set([cfg.res cfg.res], cfg.nIndep, cfg.indepSeed);
    o3 = run_design_search(chans, 'thetagamma', 'GWO', 1, cfg);
    D = {{'baseline', [0 0 0 1 1 1], design_from_params([0 0 0], 'bias')}, {'analytic', [.5 .5 .5 1 1 1], design_from_params([], 'analytic')}, ...
         {'iter3', o3.params, design_from_params(o3.params, 'thetagamma')}};
    f = fopen(fn, 'a');
    for j = 1:3
        q = evaluate_design(chans, D{j}{3}, cfg.R1indep, cfg.win);
        [qp, dp] = evaluate_design_perceptual(chans, cfg.labS, D{j}{3}, cfg.R1indep, cfg.win, viv);
        fprintf(f, '%s,%s,%.4f,%.4f,%.4f,%.4f,%.4f,%.4f,%.6f,%.6f,%.4f,%.5f,%.4f,%.4f\n', name, D{j}{1}, D{j}{2}, mean(q), mean(qp), mean(dp.dE), mean(dp.ssimL), mean(dp.chromaVivid), mean(viv(:)));
    end
    fclose(f);
    printf('[exp13] %s done: Q iter3 %.4f\n', name, o3.indep_mean); fflush(stdout);
end
