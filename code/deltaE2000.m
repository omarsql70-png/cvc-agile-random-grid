function dE = deltaE2000(lab1, lab2)
% DELTAE2000  CIEDE2000 colour difference (Sharma, Wu & Dalal 2005),
% kL = kC = kH = 1. Inputs: N x 3 (or h x w x 3) CIELAB arrays.
    a = reshape(double(lab1), [], 3); b = reshape(double(lab2), [], 3);
    L1 = a(:,1); a1 = a(:,2); b1 = a(:,3); L2 = b(:,1); a2 = b(:,2); b2 = b(:,3);
    C1 = hypot(a1, b1); C2 = hypot(a2, b2); Cm = (C1 + C2) / 2;
    p7 = @(x) (x.*x).*(x.*x).*(x.*x).*x;
    G = 0.5 * (1 - sqrt(p7(Cm) ./ (p7(Cm) + 25^7)));
    a1p = (1 + G) .* a1; a2p = (1 + G) .* a2;
    C1p = hypot(a1p, b1); C2p = hypot(a2p, b2);
    h1p = mod(atan2(b1, a1p) * 180/pi, 360); h2p = mod(atan2(b2, a2p) * 180/pi, 360);
    dLp = L2 - L1; dCp = C2p - C1p;
    dhp = h2p - h1p; dhp(dhp > 180) -= 360; dhp(dhp < -180) += 360; dhp(C1p .* C2p == 0) = 0;
    dHp = 2 * sqrt(C1p .* C2p) .* sind(dhp / 2);
    Lpm = (L1 + L2) / 2; Cpm = (C1p + C2p) / 2;
    hpm = h1p + h2p;
    k = abs(h1p - h2p) > 180 & C1p .* C2p ~= 0;
    lo = k & hpm < 360; hi = k & hpm >= 360;
    hpm(lo) += 360; hpm(hi) -= 360;                           % then halve
    hpm = hpm / 2; z = C1p .* C2p == 0; hpm(z) = h1p(z) + h2p(z);
    T = 1 - 0.17*cosd(hpm - 30) + 0.24*cosd(2*hpm) + 0.32*cosd(3*hpm + 6) - 0.20*cosd(4*hpm - 63);
    dTh = 30 * exp(-((hpm - 275) / 25).^2);
    RC = 2 * sqrt(p7(Cpm) ./ (p7(Cpm) + 25^7));
    SL = 1 + 0.015 * (Lpm - 50).^2 ./ sqrt(20 + (Lpm - 50).^2);
    SC = 1 + 0.045 * Cpm; SH = 1 + 0.015 * Cpm .* T; RT = -sind(2 * dTh) .* RC;
    dE = sqrt((dLp ./ SL).^2 + (dCp ./ SC).^2 + (dHp ./ SH).^2 + RT .* (dCp ./ SC) .* (dHp ./ SH));
end
