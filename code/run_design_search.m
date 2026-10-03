function out = run_design_search(chans, mode, optName, seed, cfg)
% RUN_DESIGN_SEARCH  One Sprint-4 search run + independent Sprint-3 check.
%   chans   : {C, M, Y} at evaluation resolution
%   mode    : 'bias' (Iteration 1) or 'gamma' (Iteration 2)
%   optName : 'GWO' | 'BDA' | 'HHO' | 'RS'
%   seed    : run seed (optimizer stream and search-grid set)
%   cfg     : .N .T .nBits .K .win .R1indep  (+ .range.bias / .range.gamma)
%   out     : struct with best parameters, search score (on the K fixed
%             search grids) and independent score (on cfg.R1indep, which
%             the optimizer never sees)
    rand('twister', seed); randn('twister', seed);
    sz = size(chans{1});
    fc.mode = mode; fc.nBits = cfg.nBits; fc.win = cfg.win;
    if any(strcmp(mode, {'thetagamma', 'knee4'})), rg = [0 1]; else, rg = cfg.range.(mode); end
    fc.lo = rg(1); fc.hi = rg(2); fc.range = cfg.range;
    fc.R1search = make_R1set(sz, cfg.K, 100000 * seed);
    if strcmp(mode, 'knee4')
        cost = @(bits) -mean(evaluate_design_perceptual(chans, cfg.labS, ...
            design_from_params(map_params(decode_params(bits, fc.nBits, fc.lo, fc.hi), mode, fc), mode), fc.R1search, fc.win));
    else
        cost = @(bits) cvc_fitness(bits, chans, fc);
    end
    nVar = (3 + 3 * any(strcmp(mode, {'thetagamma', 'knee4'}))) * cfg.nBits;
    switch optName
        case 'GWO', [bp, bs, curve, ne] = BGWO1D(cfg.N, cfg.T, nVar, cost);
        case 'BDA', [bp, bs, curve, ne] = BDA1D(cfg.N, cfg.T, nVar, cost);
        case 'HHO', [bp, bs, curve, ne] = BHHO1D(cfg.N, cfg.T, nVar, cost, false, cfg.N * cfg.T);
        case 'RS',  [bp, bs, curve, ne] = BRS1D(cfg.N, cfg.T, nVar, cost);
        otherwise, error('unknown optimizer');
    end
    out.params = map_params(decode_params(bp', cfg.nBits, fc.lo, fc.hi), mode, fc);
    out.search_score = -bs;
    out.curve = -curve;
    out.evals = ne;
    dsg = design_from_params(out.params, mode);
    qi = evaluate_design(chans, dsg, cfg.R1indep, cfg.win);
    if isfield(cfg, 'labS')
        [qp, dp] = evaluate_design_perceptual(chans, cfg.labS, dsg, cfg.R1indep, cfg.win);
        out.indep_qp = mean(qp); out.indep_dE = mean(dp.dE); out.indep_ssimL = mean(dp.ssimL);
    end
    out.indep_scores = qi;
    out.indep_mean = mean(qi);
    out.indep_sd = std(qi);
end
