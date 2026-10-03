function [mi, G, p] = binary_mi(a, b)
% BINARY_MI  Mutual information (bits) between two binary images, with
% the G-test of independence (G = 2 N ln2 * MI, chi-square, 1 dof).
    a = logical(a(:)); b = logical(b(:)); N = numel(a);
    P = [mean(~a & ~b), mean(~a & b); mean(a & ~b), mean(a & b)];
    pa = sum(P, 2); pb = sum(P, 1);
    mi = 0;
    for i = 1:2, for j = 1:2
        if P(i,j) > 0, mi = mi + P(i,j) * log2(P(i,j) / (pa(i) * pb(j))); end
    end, end
    G = 2 * N * log(2) * mi;
    p = 1 - gammainc(G / 2, 0.5);    % chi-square(1) upper tail
end
