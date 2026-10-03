% EXP5_FINAL_BUILD  Final shares, reconstructions, metric tables and
% security analysis for Baboon. The reported Iteration-1 and Iteration-2
% designs are those of the pre-specified seed 1 run in exp2 (not the best
% seed). All security statistics are computed on the very shares that are
% displayed and used for the reported metrics.
pkg load image
cfg = setup_cfg();
od = cfg.outdir; imd = fullfile(od, 'images'); if ~exist(imd, 'dir'), mkdir(imd); end
[chans, rgb] = load_secret('baboon', cfg.res);
names = {'C', 'M', 'Y'};
R1i = make_R1set([cfg.res cfg.res], cfg.nIndep, cfg.indepSeed);
Rshow = make_R1set([cfg.res cfg.res], 1, 424242);   % the displayed share set

% --- designs ---------------------------------------------------------
T = csv2cell_simple(fullfile(od, 'exp2_runs.csv'));
pick = @(mode) cellfun(@str2double, T(strcmp(T(:,2), mode) & strcmp(T(:,4), '1'), 5:7));
D.baseline = design_from_params([0 0 0], 'bias');
D.iter1    = design_from_params(pick('bias'), 'bias');
D.iter2    = design_from_params(pick('gamma'), 'gamma');
D.analytic = design_from_params([], 'analytic');
T9 = csv2cell_simple(fullfile(od, 'exp9_runs.csv'));
D.iter3    = design_from_params(cellfun(@str2double, T9(strcmp(T9(:,1), 'baboon') & strcmp(T9(:,4), '1'), 5:10)), 'thetagamma');
labels = {'baseline', 'iter1', 'iter2', 'analytic', 'iter3'};

imwrite(rgb, fullfile(imd, 'secret_original.png'));
fm = fopen(fullfile(od, 'exp5_metrics.csv'), 'w');
fprintf(fm, 'design,channel,param_bias,param_theta,param_gamma,psnr_shown,ssim_shown,contrast_shown,psnr_mean,psnr_sd,ssim_mean,ssim_sd,contrast_mean,contrast_sd\n');
fq = fopen(fullfile(od, 'exp5_overall.csv'), 'w');
fprintf(fq, 'design,q_shown,q_mean,q_sd,rgb_psnr_shown,ssim_avg_shown,contrast_avg_shown,ink_fraction_halftone\n');
for L = labels
    d = D.(L{1});
    [q, det] = evaluate_design(chans, d, R1i, cfg.win);
    recStack = zeros(cfg.res, cfg.res, 3); s1 = recStack; s2 = recStack; ms = [];
    inkf = 0;
    for k = 1:3
        [bw, S1, S2, rec, m] = build_cvc_channel(chans{k}, d(k), Rshow{1}{k}, cfg.win);
        ms = [ms, m]; recStack(:,:,k) = rec; s1(:,:,k) = S1; s2(:,:,k) = S2; inkf = inkf + mean(bw(:)) / 3;
        fprintf(fm, '%s,%s,%.4f,%.4f,%.4f,%.3f,%.4f,%.4f,%.3f,%.3f,%.4f,%.4f,%.4f,%.4f\n', L{1}, names{k}, d(k).bias, d(k).theta, d(k).gamma, ...
            m.psnr, m.ssim, m.contrast, mean(det.psnr(:,k)), std(det.psnr(:,k)), mean(det.ssim(:,k)), std(det.ssim(:,k)), ...
            mean(det.contrast(:,k)), std(det.contrast(:,k)));
        imwrite(bw, fullfile(imd, sprintf('halftone_%s_%s.png', L{1}, names{k})));
        if strcmp(L{1}, 'iter3')
            imwrite(~S1, fullfile(imd, sprintf('share1_%s.png', names{k})));
            imwrite(~S2, fullfile(imd, sprintf('share2_%s.png', names{k})));
            SH.(names{k}) = struct('S1', S1, 'S2', S2, 'bw', bw);
        end
    end
    recRGB = uint8(255 * (1 - recStack));
    imwrite(recRGB, fullfile(imd, sprintf('reconstructed_%s.png', L{1})));
    if strcmp(L{1}, 'iter3')
        imwrite(uint8(255 * (1 - s1)), fullfile(imd, 'share1_color.png'));
        imwrite(uint8(255 * (1 - s2)), fullfile(imd, 'share2_color.png'));
    end
    e = double(rgb) / 255 - double(recRGB) / 255;
    fprintf(fq, '%s,%.5f,%.5f,%.5f,%.3f,%.4f,%.4f,%.4f\n', L{1}, quality_score(ms), mean(q), std(q), ...
        10 * log10(1 / mean(e(:).^2)), mean([ms.ssim]), mean([ms.contrast]), inkf);
end
fclose(fm); fclose(fq);

% --- security on the displayed Iteration-3 shares --------------------
fs = fopen(fullfile(od, 'exp5_security.csv'), 'w');
fprintf(fs, 'channel,share,entropy,black_fraction,corr_h,corr_v,corr_d,cc_vs_secret_channel,mi_vs_halftone_bits,gtest_p\n');
for k = 1:3
    for sname = {'S1', 'S2'}
        S = SH.(names{k}).(sname{1});
        sm = security_metrics(S);
        a = double(S(:)) - mean(S(:)); b = chans{k}(:) - mean(chans{k}(:));
        cc = sum(a .* b) / sqrt(sum(a.^2) * sum(b.^2));
        [mi, ~, p] = binary_mi(S, SH.(names{k}).bw);
        fprintf(fs, '%s,%s,%.5f,%.4f,%.4f,%.4f,%.4f,%.4f,%.2e,%.3f\n', names{k}, sname{1}, sm.entropy, sm.black_fraction, ...
            sm.corr_h, sm.corr_v, sm.corr_d, cc, mi, p);
    end
end
% the two shares jointly reveal the halftone exactly (sanity check of correctness)
for k = 1:3
    [mi, ~, ~] = binary_mi(xor(SH.(names{k}).S1, SH.(names{k}).S2), SH.(names{k}).bw);
    fprintf(fs, '%s,S1xorS2,,,,,,,%.4f,\n', names{k}, mi);
end
fclose(fs);

% --- R1-reuse leakage: two secrets shared with the SAME share-1 grid --
[chB, ~] = load_secret('astronaut', cfg.res);
bwA = halftone(tone_precompensate(chans{1}, D.iter3(1).gamma, D.iter3(1).theta), 0);
bwB = halftone(tone_precompensate(chB{1},  D.iter3(1).gamma, D.iter3(1).theta), 0);
[~, S2a] = random_grid_encrypt(bwA, Rshow{1}{1});
[~, S2b] = random_grid_encrypt(bwB, Rshow{1}{1});        % reused grid
[~, S2c] = random_grid_encrypt(bwB, R1i{1}{1});          % fresh grid
leakReuse = xor(S2a, S2b); leakFresh = xor(S2a, S2c);
imwrite(~leakReuse, fullfile(imd, 'r1_reuse_leak.png'));
imwrite(~leakFresh, fullfile(imd, 'r1_fresh_noleak.png'));
fr = fopen(fullfile(od, 'exp5_r1_reuse.csv'), 'w');
fprintf(fr, 'case,agreement_with_bwA_xor_bwB,mi_bits\n');
ref = xor(bwA, bwB);
[mi1] = binary_mi(leakReuse, ref); [mi2] = binary_mi(leakFresh, ref);
fprintf(fr, 'reused_R1,%.4f,%.4f\nfresh_R1,%.4f,%.6f\n', mean(leakReuse(:) == ref(:)), mi1, mean(leakFresh(:) == ref(:)), mi2);
fclose(fr);

% --- forged-share (cheating) test on the Cyan channel -----------------
% Adversary holds genuine S1 only and forges S2' to impose a target mask.
S1 = SH.C.S1; tgt = false(cfg.res); tgt(90:175, 60:205) = true;  % target region
forgeBlack = false(cfg.res); forgeBlack(tgt) = true;               % ink where black wanted
stackB = S1 | forgeBlack;
forgeWhite = true(cfg.res);  forgeWhite(tgt) = false;              % no ink where white wanted
stackW = S1 | forgeWhite;
fc = fopen(fullfile(od, 'exp5_cheating.csv'), 'w');
fprintf(fc, 'attack,success_rate_in_target\n');
fprintf(fc, 'force_black,%.4f\nforce_white,%.4f\n', mean(stackB(tgt)), mean(~stackW(tgt)));
fclose(fc);
imwrite(~stackW, fullfile(imd, 'cheat_force_white.png'));
printf('exp5 done\n');
