function cfg = setup_cfg()
% SETUP_CFG  Shared experimental settings for every script.
    cfg.res   = 264;          % search AND evaluation resolution (single-resolution protocol)
    cfg.N     = 16;           % population size
    cfg.T     = 25;           % iterations  -> 400 fitness evaluations per run
    cfg.nBits = 8;            % bits per channel parameter (24-bit chromosome)
    cfg.K     = 4;            % fixed search grids per fitness call (common random numbers)
    cfg.nIndep = 30;          % independent evaluation grids, never seen by any optimizer
    cfg.indepSeed = 900000;   % base seed of the independent grid set
    cfg.win   = 4;            % view-filter window (same in search and evaluation)
    cfg.range.bias  = [-80 80];
    cfg.range.gamma = [0.5 3.0];
    cfg.range.theta = [0 0.8];   % Iteration 3/4 knee position
    cfg.range.gamma4 = [0.1 3.0];   % Iteration 4: posterization guard removed (perceptual objective)
    cfg.K4 = 2;                     % search grids per evaluation, perceptual objective
    cfg.seeds = 1:12;
    here = fileparts(mfilename('fullpath'));
    cfg.imgdir = fullfile(here, '..', 'images');
    cfg.outdir = fullfile(here, '..', 'results');
    if ~exist(cfg.outdir, 'dir'), mkdir(cfg.outdir); end
end
