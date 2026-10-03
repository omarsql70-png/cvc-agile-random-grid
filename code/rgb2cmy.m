function [C, M, Y] = rgb2cmy(rgb)
% RGB2CMY  Decompose an RGB image into its Cyan, Magenta, Yellow
% subtractive-color separations (Hou, 2003), each returned as a
% continuous-tone double matrix in [0,255].
    rgb = double(rgb);
    C = 255 - rgb(:,:,1);
    M = 255 - rgb(:,:,2);
    Y = 255 - rgb(:,:,3);
end
