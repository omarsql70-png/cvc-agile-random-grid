function designs = design_from_params(vals, mode)
% DESIGN_FROM_PARAMS  Turn decoded values into per-channel designs.
%   'bias'       : Iteration 1 - vals(1:3) are threshold offsets b_c
%   'gamma'      : Iteration 2 - vals(1:3) are tone exponents gamma_c
%   'thetagamma' : Iteration 3 - vals(1:3) = theta_c, vals(4:6) = gamma_c
%   'knee4'      : Iteration 4 - same curve, wider gamma range, perceptual objective
%   'analytic'   : closed-form inverse, theta_c = 0.5, gamma_c = 1 (vals ignored)
    designs = struct('bias', {0, 0, 0}, 'gamma', {1, 1, 1}, 'theta', {0, 0, 0});
    for k = 1:3
        switch mode
            case 'bias',       designs(k).bias  = vals(k);
            case 'gamma',      designs(k).gamma = vals(k);
            case {'thetagamma', 'knee4'}, designs(k).theta = vals(k); designs(k).gamma = vals(k + 3);
            case 'analytic',   designs(k).theta = 0.5;
            otherwise, error('unknown mode %s', mode);
        end
    end
end
