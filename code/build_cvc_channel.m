function [bw, S1, S2, rec, m] = build_cvc_channel(gray, design, R1, winSize)
% BUILD_CVC_CHANNEL  Sprint-2/3 pipeline for ONE colorant channel:
% tone pre-compensation -> halftone (threshold 128+bias) -> random-grid
% shares -> OR stacking -> view filter -> metrics against the ORIGINAL
% channel.
%   gray    : original colorant-density channel, [0,255]
%   design  : struct with fields .bias (default 0) and .gamma (default 1)
%   R1      : random grid for share 1 (logical, size(gray)); [] = draw new
%   winSize : view-filter window side (default 4)
    if nargin < 4 || isempty(winSize), winSize = 4; end
    if nargin < 3, R1 = []; end
    if ~isfield(design, 'bias'),  design.bias  = 0; end
    if ~isfield(design, 'gamma'), design.gamma = 1; end
    if ~isfield(design, 'theta'), design.theta = 0; end
    pre = tone_precompensate(gray, design.gamma, design.theta);
    bw  = halftone(pre, design.bias);
    [S1, S2] = random_grid_encrypt(bw, R1);
    rec = view_filter(random_grid_decrypt(S1, S2), winSize);
    m = eval_metrics(double(gray) / 255, rec, bw);
end
