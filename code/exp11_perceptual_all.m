% EXP11_PERCEPTUAL_ALL  CIEDE2000 / lightness / chroma / SSIM(L*) for the
% baseline and the seed-1 designs of every iteration, plus the closed-form
% inverse, on all four images (30 independent grids). Resumable.
pkg load image
cfg = setup_cfg();
R1i = make_R1set([cfg.res cfg.res], cfg.nIndep, cfg.indepSeed);
T = [csv2cell_simple(fullfile(cfg.outdir, 'exp2_runs.csv')); csv2cell_simple(fullfile(cfg.outdir, 'exp4_runs.csv'))];
T9 = csv2cell_simple(fullfile(cfg.outdir, 'exp9_runs.csv'));
fn = fullfile(cfg.outdir, 'exp11_color.csv');
if ~exist(fn, 'file')
    f = fopen(fn, 'w'); fprintf(f, 'image,design,dE00_mean,dE00_sd,abs_dL_mean,signed_dL_mean,chroma_ratio_vivid,chroma_ratio_dull,ssim_lum_mean\n'); fclose(f);
end
L = {'baseline', 'iter1', 'iter2', 'analytic', 'iter3'};
for img = {'baboon', 'astronaut', 'coffee', 'chelsea'}
    [chans, rgb] = load_secret(img{1}, cfg.res);
    labS = srgb2lab(double(rgb) / 255); CSm = hypot(labS(:,:,2), labS(:,:,3)); viv = CSm > 40;
    pick = @(mode) cellfun(@str2double, T(strcmp(T(:,1), img{1}) & strcmp(T(:,2), mode) & strcmp(T(:,4), '1'), 5:7));
    p3 = cellfun(@str2double, T9(strcmp(T9(:,1), img{1}) & strcmp(T9(:,4), '1'), 5:10));
    D = {design_from_params([0 0 0], 'bias'), design_from_params(pick('bias'), 'bias'), design_from_params(pick('gamma'), 'gamma'), ...
         design_from_params([], 'analytic'), design_from_params(p3, 'thetagamma')};
    for d = 1:5
        if ~isempty(strfind(fileread(fn), sprintf('%s,%s,', img{1}, L{d}))), continue; end
        de = zeros(1, cfg.nIndep); adl = de; sdl = de; cv = de; cd = de; sl = de;
        for r = 1:cfg.nIndep
            labR = srgb2lab(reconstruct_rgb(chans, D{d}, R1i{r}, cfg.win));
            de(r) = mean(deltaE2000(labS, labR)); dl = labR(:,:,1) - labS(:,:,1); adl(r) = mean(abs(dl(:))); sdl(r) = mean(dl(:));
            CR = hypot(labR(:,:,2), labR(:,:,3)); cv(r) = mean(CR(viv)) / mean(CSm(viv)); cd(r) = mean(CR(~viv)) / mean(CSm(~viv));
            sl(r) = ssim_gauss(labS(:,:,1) / 100, labR(:,:,1) / 100);
        end
        f = fopen(fn, 'a');
        fprintf(f, '%s,%s,%.3f,%.3f,%.3f,%.3f,%.4f,%.4f,%.4f\n', img{1}, L{d}, mean(de), std(de), mean(adl), mean(sdl), mean(cv), mean(cd), mean(sl)); fclose(f);
        printf('%s %s dE=%.2f\n', img{1}, L{d}, mean(de)); fflush(stdout);
    end
end
