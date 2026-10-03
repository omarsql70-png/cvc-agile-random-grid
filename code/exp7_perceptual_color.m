% EXP7_PERCEPTUAL_COLOR  Colour-appearance check of the designs: mean
% CIEDE2000 difference, mean lightness error and chroma ratio between the
% secret and the perceived reconstruction (30 independent grids), for the
% baseline and the seed-1 designs of both iterations on all four images.
pkg load image
cfg = setup_cfg();
R1i = make_R1set([cfg.res cfg.res], cfg.nIndep, cfg.indepSeed);
T2 = csv2cell_simple(fullfile(cfg.outdir, 'exp2_runs.csv'));
T4 = csv2cell_simple(fullfile(cfg.outdir, 'exp4_runs.csv'));
T = [T2; T4];
fid = fopen(fullfile(cfg.outdir, 'exp7_color.csv'), 'w');
fprintf(fid, 'image,design,dE00_mean,dE00_sd,abs_dL_mean,signed_dL_mean,chroma_ratio_mean,chroma_ratio_vivid,chroma_ratio_dull,ssim_lum_mean\n');
for img = {'baboon', 'astronaut', 'coffee', 'chelsea'}
    [chans, rgb] = load_secret(img{1}, cfg.res);
    sec01 = double(rgb) / 255; labS = srgb2lab(sec01);
    CSm = hypot(labS(:,:,2), labS(:,:,3)); CS = mean(CSm(:)); vivid = CSm > 40;   % vivid = secret chroma above 40
    pick = @(mode) cellfun(@str2double, T(strcmp(T(:,1), img{1}) & strcmp(T(:,2), mode) & strcmp(T(:,4), '1'), 5:7));
    D = {design_from_params([0 0 0], 'bias'), design_from_params(pick('bias'), 'bias'), design_from_params(pick('gamma'), 'gamma')};
    L = {'baseline', 'iter1', 'iter2'};
    for d = 1:3
        de = zeros(1, cfg.nIndep); adl = de; sdl = de; cr = de; sl = de; cv = de; cd = de;
        for r = 1:cfg.nIndep
            rec = reconstruct_rgb(chans, D{d}, R1i{r}, cfg.win); labR = srgb2lab(rec);
            e = deltaE2000(labS, labR); de(r) = mean(e);
            dl = labR(:,:,1) - labS(:,:,1); adl(r) = mean(abs(dl(:))); sdl(r) = mean(dl(:));
            CR = hypot(labR(:,:,2), labR(:,:,3)); cr(r) = mean(CR(:)) / CS;
            cv(r) = mean(CR(vivid)) / mean(CSm(vivid)); cd(r) = mean(CR(~vivid)) / mean(CSm(~vivid));
            sl(r) = ssim_gauss(labS(:,:,1) / 100, labR(:,:,1) / 100);
        end
        fprintf(fid, '%s,%s,%.3f,%.3f,%.3f,%.3f,%.4f,%.4f,%.4f,%.4f\n', img{1}, L{d}, mean(de), std(de), mean(adl), mean(sdl), mean(cr), mean(cv), mean(cd), mean(sl));
        printf('%s %s dE00=%.2f |dL|=%.2f dL=%+.2f chroma=%.3f ssimL=%.4f\n', img{1}, L{d}, mean(de), mean(adl), mean(sdl), mean(cr), mean(sl)); fflush(stdout);
    end
end
fclose(fid);
