function vals = decode_params(bits, nBitsPerParam, lo, hi)
% DECODE_PARAMS  Map a flat binary chromosome onto real-valued design
% parameters (one per CMY channel), MSB first, linearly scaled to [lo,hi].
%   vals = decode_params(bits, nBitsPerParam, lo, hi)
%   bits : 0/1 vector of length 3*nBitsPerParam (C, M, Y groups in order)
%   vals : 1x3 vector of decoded parameters (halftone bias or tone gamma)
    bits = round(bits(:))';
    nParams = numel(bits) / nBitsPerParam;
    vals = zeros(1, nParams);
    maxInt = 2 ^ nBitsPerParam - 1;
    w = 2 .^ (nBitsPerParam-1:-1:0);
    for k = 1:nParams
        chunk = bits((k-1)*nBitsPerParam + 1 : k*nBitsPerParam);
        vals(k) = lo + (sum(chunk .* w) / maxInt) * (hi - lo);
    end
end
