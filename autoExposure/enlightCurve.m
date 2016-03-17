function  result  = enlightCurve(x, a )
%ENLIGHTCURVES Summary of this function goes here
%   Detailed explanation goes here
location = './curves/';
identity = 0:1/255:1;

% Brightness:
% if x(1) >= 0
%     brightnessLUT = im2double(imread([location 'PositiveBrightnessCurve.png']));
% else
%     brightnessLUT = im2double(imread([location 'NegativeBrightnessCurve.png']));
% end
% y2 = interp1(identity, lutSlider(brightnessLUT,abs(x(1))), a, 'linear');

% Contrast:
% if x(1) >= 0
%     contrastLUT = im2double(imread([location 'PositiveContrastCurve.png']));
% else
contrastLUT = im2double(imread([location 'NegativeContrastCurve.png']));
% end
% y = interp1(identity, lutSlider(contrastLUT,abs(x(1))), a, 'linear');

% Highlights:
% if x(3) >= 0
%     highlightsLUT = im2double(imread([location 'PositiveHighlightsCurve.png']));
% else
    highlightsLUT = im2double(imread([location 'NegativeHighlightsCurve.png']));
% end
% y = interp1(identity, lutSlider(highlightsLUT,abs(x(2))), y, 'linear');

% Shadows:
% if x(4) >= 0
shadowsLUT = im2double(imread([location 'PositiveShadowsCurve.png']));
% else
%     shadowsLUT = im2double(imread([location 'NegativeShadowsCurve.png']));
% end
% result = interp1(identity, lutSlider(shadowsLUT,abs(x(3))), y, 'linear');

result = identity  + lutSlider(contrastLUT-identity,x(1))+ lutSlider(highlightsLUT-identity,x(2))+ lutSlider(shadowsLUT-identity,x(3));
% FillLight:
% fillLight = im2double(imread([location 'FillLightCurve.png']));
% result = interp1(identity, lutSlider(fillLight,abs(x(5))), y, 'linear');

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