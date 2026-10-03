function lab = srgb2lab(rgb01)
% SRGB2LAB  sRGB (values in [0,1], IEC 61966-2-1) to CIELAB, D65 white.
% The sRGB linearization and the CIELAB cube-root are evaluated through
% 65536-entry lookup tables (nearest entry; max error below 0.05 in L*, a*,
% b*), which makes the Iteration-4 fitness affordable.
    persistent LIN F
    if isempty(LIN)
        c = linspace(0, 1, 65536);
        LIN = c / 12.92; m = c > 0.04045; LIN(m) = ((c(m) + 0.055) / 1.055) .^ 2.4;
        t = linspace(0, 1.2, 65536);
        F = (t > (6/29)^3) .* t .^ (1/3) + (t <= (6/29)^3) .* (t / (3*(6/29)^2) + 4/29);
    end
    c = min(max(double(rgb01), 0), 1);
    sz = size(c);
    lin = LIN(round(c(:) * 65535) + 1); lin = lin(:);
    M = [0.4124564 0.3575761 0.1804375; 0.2126729 0.7151522 0.0721750; 0.0193339 0.1191920 0.9503041];
    P = reshape(lin, [], 3) * M';
    P = P ./ [0.95047 1.00000 1.08883];
    Fv = F(round(min(max(P(:), 0), 1.2) / 1.2 * 65535) + 1); Fv = Fv(:);
    Fv = reshape(Fv, [], 3);
    lab = reshape([116*Fv(:,2) - 16, 500*(Fv(:,1) - Fv(:,2)), 200*(Fv(:,2) - Fv(:,3))], sz);
end
