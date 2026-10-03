function cost = cvc_fitness(bits, chans, cfg)
% CVC_FITNESS  Sprint-4 objective (minimized): negative mean quality over
% a FIXED set of K share-1 random grids (common random numbers). Fixing
% the grids removes the evaluation noise that made single-draw fitness
% values unreliable in the first design iteration.
%   cfg.mode ('bias'|'gamma'), cfg.nBits, cfg.lo, cfg.hi, cfg.R1search,
%   cfg.win
    vals = map_params(decode_params(bits, cfg.nBits, cfg.lo, cfg.hi), cfg.mode, cfg);
    q = evaluate_design(chans, design_from_params(vals, cfg.mode), cfg.R1search, cfg.win);
    cost = -mean(q);
end
