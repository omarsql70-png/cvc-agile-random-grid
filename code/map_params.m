function vals = map_params(u, mode, cfg)
% MAP_PARAMS  Decoded chromosome values in [0,1] -> real design parameters.
%   'thetagamma' (Iteration 3): theta in cfg.range.theta, gamma in cfg.range.gamma
%   'knee4'      (Iteration 4): theta in cfg.range.theta, gamma in cfg.range.gamma4
%   other modes: values are already decoded to their real range.
    if any(strcmp(mode, {'thetagamma', 'knee4'}))
        t = cfg.range.theta;
        if strcmp(mode, 'knee4'), g = cfg.range.gamma4; else, g = cfg.range.gamma; end
        vals = [t(1) + u(1:3) * (t(2) - t(1)), g(1) + u(4:6) * (g(2) - g(1))];
    else
        vals = u;
    end
end
