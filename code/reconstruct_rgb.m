function rgb01 = reconstruct_rgb(chans, designs, R1draw, winSize)
% RECONSTRUCT_RGB  Perceived color reconstruction (view-filtered OR stack
% of the C, M, Y shares) as an sRGB image in [0,1]: R = 1 - ink_C, etc.
    rgb01 = zeros([size(chans{1}) 3]);
    for k = 1:3
        [~, ~, ~, rec] = build_cvc_channel(chans{k}, designs(k), R1draw{k}, winSize);
        rgb01(:, :, k) = 1 - rec;
    end
end
