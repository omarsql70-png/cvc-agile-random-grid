function out = view_filter(stacked, winSize)
% VIEW_FILTER  Local box average that models the eye integrating the
% stacked binary pattern at viewing distance. Border-normalized, so edge
% pixels are averaged over the in-image part of the window only (no
% zero-padding artefact).
    v = ones(winSize, 1);
    box = @(X) conv2(conv2(X, v, 'same'), v', 'same');
    out = box(double(stacked)) ./ box(ones(size(stacked)));
end
