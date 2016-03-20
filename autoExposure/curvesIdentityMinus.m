% location = './curves/';
% 
% identity = im2double(imread([location 'IdentityCurve.png']));
% 
% brightnessLUTPos = im2double(imread([location 'PositiveBrightnessCurve.png']));
% imwrite(brightnessLUTPos - identity,'PositiveBrightnessCurveI.png')
% 
% brightnessLUT = im2double(imread([location 'NegativeBrightnessCurve.png']));
% imwrite(brightnessLUT - identity,'NegativeBrightnessCurveI.png')
% 
% contrastLUTPos = im2double(imread([location 'PositiveContrastCurve.png']));
% imwrite(contrastLUTPos - identity,'PositiveContrastCurveI.png')
% 
% contrastLUT = im2double(imread([location 'NegativeContrastCurve.png']));
% imwrite(contrastLUT - identity,'NegativeContrastCurveI.png')
% 
% highlightsLUTPos = im2double(imread([location 'PositiveHighlightsCurve.png']));
% imwrite(highlightsLUTPos - identity,'PositiveHighlightsCurveI.png')
% 
% highlightsLUT = im2double(imread([location 'NegativeHighlightsCurve.png']));
% imwrite(highlightsLUT - identity,'NegativeHighlightsCurveI.png')
% 
% shadowsLUTPos = im2double(imread([location 'PositiveShadowsCurve.png']));
% imwrite(shadowsLUTPos - identity,'PositiveShadowsCurveI.png')
% 
% shadowsLUT = im2double(imread([location 'NegativeShadowsCurve.png']));
% imwrite(shadowsLUT - identity,'NegativeShadowsCurveI.png')
% 
% fillLight = im2double(imread([location 'FillLightCurve.png']));
% imwrite(fillLight - identity,'FillLightCurveI.png')
% 
imgs = loadImages('./curvesI');
's';