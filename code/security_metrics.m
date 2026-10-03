function m = security_metrics(share)
% SECURITY_METRICS  Shannon entropy (bits; ideal 1.0 for a binary share)
% and Pearson correlation of horizontally / vertically / diagonally
% adjacent pixel pairs (ideal ~0) of one binary share.
    x = double(share);
    p1 = mean(x(:)); p0 = 1 - p1;
    if p0 == 0 || p1 == 0, m.entropy = 0; else, m.entropy = -(p0*log2(p0) + p1*log2(p1)); end
    m.black_fraction = p1;
    m.corr_h = pcorr(x(:, 1:end-1), x(:, 2:end));
    m.corr_v = pcorr(x(1:end-1, :), x(2:end, :));
    m.corr_d = pcorr(x(1:end-1, 1:end-1), x(2:end, 2:end));
end
function r = pcorr(a, b)
    a = a(:) - mean(a(:)); b = b(:) - mean(b(:));
    d = sqrt(sum(a.^2) * sum(b.^2));
    if d == 0, r = 0; else, r = sum(a .* b) / d; end
end
