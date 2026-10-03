function bits = encode_params(vals, nBitsPerParam, lo, hi)
% ENCODE_PARAMS  Inverse of decode_params (nearest representable value).
    maxInt = 2 ^ nBitsPerParam - 1;
    bits = [];
    for k = 1:numel(vals)
        q = round((vals(k) - lo) / (hi - lo) * maxInt);
        q = min(max(q, 0), maxInt);
        bits = [bits, double(dec2bin(q, nBitsPerParam) - '0')];
    end
end
