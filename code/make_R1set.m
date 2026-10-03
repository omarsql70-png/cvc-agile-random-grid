function R1set = make_R1set(sz, nDraws, baseSeed)
% MAKE_R1SET  Reproducible set of share-1 random grids for the three
% channels. Uses a private Mersenne-Twister stream (rand('twister',...))
% and restores the caller's generator state afterwards, so the optimizers'
% own random streams are never disturbed.
    saved = rand('twister');
    R1set = cell(1, nDraws);
    for r = 1:nDraws
        rand('twister', baseSeed + r);
        R1set{r} = {rand(sz) < 0.5, rand(sz) < 0.5, rand(sz) < 0.5};
    end
    rand('twister', saved);
end
