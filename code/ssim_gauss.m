function s = ssim_gauss(A, B)
% SSIM_GAUSS  Standard SSIM index (Wang, Bovik, Sheikh & Simoncelli 2004):
% 11x11 Gaussian window (sigma = 1.5, applied separably), K1 = 0.01,
% K2 = 0.03, dynamic range L = 1 (inputs in [0,1]); mean SSIM over the
% 'valid' region.
    A = double(A); B = double(B);
    C1 = (0.01)^2; C2 = (0.03)^2;
    g = exp(-((-5:5)'.^2) / (2 * 1.5^2)); g = g / sum(g);
    f = @(X) conv2(conv2(X, g, 'valid'), g', 'valid');
    mu1 = f(A);  mu2 = f(B);
    s11 = f(A.*A) - mu1.^2;
    s22 = f(B.*B) - mu2.^2;
    s12 = f(A.*B) - mu1.*mu2;
    map = ((2*mu1.*mu2 + C1) .* (2*s12 + C2)) ./ ((mu1.^2 + mu2.^2 + C1) .* (s11 + s22 + C2));
    s = mean(map(:));
end
