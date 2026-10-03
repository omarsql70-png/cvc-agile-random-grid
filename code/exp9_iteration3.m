% EXP9_ITERATION3  Sprint-3 check of Iteration 2 against the closed-form
% inverse of the (1+d)/2 compression, and design Iteration 3: GWO search
% of a knee-plus-power tone curve (theta_c, gamma_c) that contains the
% closed-form inverse as a special case. Baboon: 12 seeds; Astronaut,
% Coffee, Chelsea: seeds 1-5. Resumable.
pkg load image
cfg = setup_cfg();
fa = fullfile(cfg.outdir, 'exp9_analytic.csv');
if ~exist(fa, 'file')
    fid = fopen(fa, 'w'); fprintf(fid, 'image,baseline_q,analytic_q,analytic_sd\n');
    for img = {'baboon', 'astronaut', 'coffee', 'chelsea'}
        [chans, ~] = load_secret(img{1}, cfg.res);
        R = make_R1set([cfg.res cfg.res], cfg.nIndep, cfg.indepSeed);
        qb = evaluate_design(chans, design_from_params([0 0 0], 'bias'), R, cfg.win);
        qa = evaluate_design(chans, design_from_params([], 'analytic'), R, cfg.win);
        fprintf(fid, '%s,%.6f,%.6f,%.6f\n', img{1}, mean(qb), mean(qa), std(qa));
    end
    fclose(fid);
end
fr_name = fullfile(cfg.outdir, 'exp9_runs.csv'); fc_name = fullfile(cfg.outdir, 'exp9_curves.csv');
if ~exist(fr_name, 'file')
    f = fopen(fr_name, 'w'); fprintf(f, 'image,mode,optimizer,seed,theta_C,theta_M,theta_Y,gamma_C,gamma_M,gamma_Y,search_score,indep_mean,indep_sd,evals\n'); fclose(f);
    f = fopen(fc_name, 'w'); fprintf(f, 'image,mode,optimizer,seed,curve\n'); fclose(f);
end
jobs = {};
for s = 1:12, jobs(end+1, :) = {'baboon', s}; end
for img = {'astronaut', 'coffee', 'chelsea'}, for s = 1:5, jobs(end+1, :) = {img{1}, s}; end, end
cur = '';
for j = 1:size(jobs, 1)
    img = jobs{j, 1}; s = jobs{j, 2};
    if run_done(fr_name, img, 'thetagamma', 'GWO', s), continue; end
    if ~strcmp(cur, img)
        [chans, ~] = load_secret(img, cfg.res); cur = img;
        cfg.R1indep = make_R1set([cfg.res cfg.res], cfg.nIndep, cfg.indepSeed);
    end
    out = run_design_search(chans, 'thetagamma', 'GWO', s, cfg);
    f = fopen(fr_name, 'a');
    fprintf(f, '%s,thetagamma,GWO,%d,%.4f,%.4f,%.4f,%.4f,%.4f,%.4f,%.6f,%.6f,%.6f,%d\n', img, s, out.params, out.search_score, out.indep_mean, out.indep_sd, out.evals); fclose(f);
    f = fopen(fc_name, 'a'); fprintf(f, '%s,thetagamma,GWO,%d,%s\n', img, s, sprintf('%.6f;', out.curve)); fclose(f);
    printf('[exp9] %s seed %d: indep %.5f params %s\n', img, s, out.indep_mean, mat2str(out.params, 3)); fflush(stdout);
end
