function bw = floyd_steinberg(gray, bias)
% FLOYD_STEINBERG  Reference implementation of error-diffusion halftoning
% (Floyd & Steinberg, 1976) with a threshold of 128 + bias.
%   gray : colorant-density channel in [0,255] (high value = more ink)
%   bw   : logical matrix, true = black (ink) dot
% NOTE (Sprint-3 finding of this study): because error diffusion carries
% every quantization error forward, the long-run dot density equals the
% mean input density for ANY threshold inside (0,255). The bias therefore
% re-arranges dot positions but barely changes tone (see exp1_*).
    [h, w] = size(gray);
    img = double(gray);
    bw  = false(h, w);
    thresh = 128 + bias;
    for i = 1:h
        for j = 1:w
            old = img(i, j);
            newval = (old >= thresh) * 255;
            bw(i, j) = (newval == 255);
            err = old - newval;
            if j + 1 <= w,              img(i, j+1)   = img(i, j+1)   + err*7/16; end
            if i + 1 <= h && j - 1 >= 1, img(i+1, j-1) = img(i+1, j-1) + err*3/16; end
            if i + 1 <= h,              img(i+1, j)   = img(i+1, j)   + err*5/16; end
            if i + 1 <= h && j + 1 <= w, img(i+1, j+1) = img(i+1, j+1) + err*1/16; end
        end
    end
end
