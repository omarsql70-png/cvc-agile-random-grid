function [chans, rgb] = load_secret(name, res)
% LOAD_SECRET  Read a test image, drop alpha, center-crop it to a square,
% resize to res x res and
% return its C, M, Y colorant-density channels.
    cfg = setup_cfg();
    rgb = imread(fullfile(cfg.imgdir, [name '.png']));
    if size(rgb, 3) == 4, rgb = rgb(:, :, 1:3); end
    [h, w, ~] = size(rgb); s = min(h, w); y0 = floor((h - s) / 2); x0 = floor((w - s) / 2);
    rgb = rgb(y0+1:y0+s, x0+1:x0+s, :);
    rgb = imresize(rgb, [res res]);
    [C, M, Y] = rgb2cmy(rgb);
    chans = {C, M, Y};
end
