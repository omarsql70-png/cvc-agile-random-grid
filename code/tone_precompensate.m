function out = tone_precompensate(gray, gamma, theta)
% TONE_PRECOMPENSATE  Per-channel tone curve applied to a colorant-density
% channel BEFORE halftoning.
%   out = 255 * max(0, (x - theta) / (1 - theta))^gamma,   x = gray/255
% theta = 0 gives the power law of design Iteration 2; theta = 0.5 with
% gamma = 1 gives the closed-form inverse d' = max(0, 2d - 1) of the
% (1 + d)/2 density compression of OR-stacked random grids (Iteration 3).
    if nargin < 3, theta = 0; end
    x = max(double(gray), 0) / 255;
    y = max(0, (x - theta) / (1 - theta));
    out = 255 * y .^ gamma;
end
