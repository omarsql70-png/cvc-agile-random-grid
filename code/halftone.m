function bw = halftone(gray, bias)
% HALFTONE  Floyd-Steinberg error diffusion with threshold 128+bias.
% Uses the compiled fs_halftone_mex (bit-identical to floyd_steinberg.m,
% ~2000x faster) when available, otherwise the reference .m version.
    if nargin < 2, bias = 0; end
    if exist('fs_halftone_mex', 'file') == 3
        bw = fs_halftone_mex(double(gray), bias);
    else
        bw = floyd_steinberg(double(gray), bias);
    end
end
