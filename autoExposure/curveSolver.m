function [ curveSet, weights ] = curveSolver( curve, method )
%CURVESOLVER Summary of this function goes here
%   Detailed explanation goes here
identity = 0:1/255:1;
location = './curves/';
brightnessLUTP = im2double(imread([location 'PositiveBrightnessCurve.png']));
brightnessLUTP = brightnessLUTP - identity;
% brightnessLUTN = im2double(imread([location 'NegativeBrightnessCurve.png']));
% brightnessLUTN = brightnessLUTN - identity;
contrastLUTP = im2double(imread([location 'PositiveContrastCurve.png']));
contrastLUTP = contrastLUTP - identity;
% contrastLUTN = im2double(imread([location 'NegativeContrastCurve.png']));
% contrastLUTN = contrastLUTN - identity;
highlightsLUTP = im2double(imread([location 'PositiveHighlightsCurve.png']));
highlightsLUTP = highlightsLUTP - identity;
% highlightsLUTN = im2double(imread([location 'NegativeHighlightsCurve.png']));
% highlightsLUTN = highlightsLUTN - identity;
shadowsLUTP = im2double(imread([location 'PositiveShadowsCurve.png']));
shadowsLUTP = shadowsLUTP - identity;
% shadowsLUTN = im2double(imread([location 'NegativeShadowsCurve.png']));
% shadowsLUTN = shadowsLUTN - identity;
fillLight = im2double(imread([location 'FillLightCurve.png']));
fillLight = fillLight - identity;

sets = {};
sets{1} = [contrastLUTP' -brightnessLUTP' shadowsLUTP' -highlightsLUTP' fillLight'];
sets{2} = [-contrastLUTP' brightnessLUTP' shadowsLUTP' -highlightsLUTP' fillLight'];
% sets{3} = [contrastLUTP' shadowsLUTP'];
sets{3} = [contrastLUTP' -shadowsLUTP' highlightsLUTP'];
% sets{5} = [contrastLUTP' shadowsLUTP' highlightsLUTN'];
error = 1000;
curveSet = 0;
weights = 0;
setChosen = 0;
for i = 1 : 3
    A = sets{i};
    [r,c] = size(A);
    AtA = transpose(A)*A;
    AtB = transpose(A)*(curve - identity)';
    x = (AtA+eye(c)*2)\AtB;
    newError = norm(applyCurves(A, x) - curve, 2);
    if(newError < error)
        error = newError;
        curveSet = sets{i};
        weights = x;
        setChosen = i;
    end
end
% if (method == 1)
%     if (setChosen == 1)
%         if(weights(1) < 0 )
%             curveSet(:, 1) = contrastLUTN';
%             weights(1) = abs(weights(1));
%         end
%         if(weights(2) < 0 )
%             curveSet(:, 2) = brightnessLUTP';
%             weights(2) = abs(weights(2));
%         end
%         if(weights(3) < 0 )
%             curveSet(:, 3) = shadowsLUTN';
%             weights(3) = abs(weights(3));
%         end
%         if(weights(4) < 0 )
%             curveSet(:, 4) = highlightsLUTP';
%             weights(4) = abs(weights(4));
%         end
%         if(weights(5) < 0 )
%             weights(5) = 0;
%         end
%     elseif (setChosen == 2)
%         if(weights(1) < 0 )
%             curveSet(:, 1) = contrastLUTP';
%             weights(1) = abs(weights(1));
%         end
%         if(weights(2) < 0 )
%             curveSet(:, 2) = brightnessLUTN';
%             weights(2) = abs(weights(2));
%         end
%         if(weights(3) < 0 )
%             curveSet(:, 3) = shadowsLUTN';
%             weights(3) = abs(weights(3));
%         end
%         if(weights(4) < 0 )
%             curveSet(:, 4) = highlightsLUTP';
%             weights(4) = abs(weights(4));
%         end
%         if(weights(5) < 0 )
%             weights(5) = 0;
%         end
%     else
%         if(weights(1) < 0 )
%             curveSet(:, 1) = contrastLUTN';
%             weights(1) = abs(weights(1));
%         end
%         if(weights(2) < 0 )
%             curveSet(:, 2) = shadowsLUTP';
%             weights(2) = abs(weights(2));
%         end
%         if(weights(3) < 0 )
%             curveSet(:, 3) = highlightsLUTN';
%             weights(3) = abs(weights(3));
%         end
%     end
% end
setChosen
end

