function [ output ] = enlightCurveLUT( img, x )
%ENLIGHTCURVELUT Summary of this function goes here
%   Detailed explanation goes here

curves = loadImages('./curves');
identity = 0:1/255:1;
output = interp1(identity, lutSlider(curves{1},x(1)),img , 'nearest');
for i = 2 : length(curves)
    output = interp1(identity, lutSlider(curves{i},x(i)), output, 'nearest');
end
end





function lutOut = lutSlider(lut, slider)
%LUT-SLIDER Given tonal 1D lut, computes intermediate manipulation.
% slider 1 - lut,
% slider 0 - identity,
% slider (0,1) - intermediate manipulation.

x = (1:length(lut))./length(lut);
scale = lut./x;
id = ones(size(lut));
lutOut = x .* ((1-slider)*id + (slider)*scale);

end