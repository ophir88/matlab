function [ x ] = curveSolver( curve )
%CURVESOLVER Summary of this function goes here
%   Detailed explanation goes here
identity = 0:1/255:1;
location = './curves/';
brightnessLUT = im2double(imread([location 'PositiveBrightnessCurve.png']));
brightnessLUT = brightnessLUT - identity;
contrastLUT = im2double(imread([location 'NegativeContrastCurve.png']));
contrastLUT = contrastLUT - identity;
highlightsLUT = im2double(imread([location 'NegativeHighlightsCurve.png']));
highlightsLUT = highlightsLUT - identity;
shadowsLUT = im2double(imread([location 'PositiveShadowsCurve.png']));
shadowsLUT = shadowsLUT - identity;
fillLight = im2double(imread([location 'FillLightCurve.png']));
fillLight = fillLight - identity;


A = [contrastLUT' highlightsLUT' shadowsLUT' brightnessLUT' fillLight'];
curve = curve - identity;
AtA = transpose(A)*A;
AtB = transpose(A)*(curve - identity)';
x = (AtA+eye(5))\AtB;
% x = x - min(x);
% x = x ./ max(x);

end

