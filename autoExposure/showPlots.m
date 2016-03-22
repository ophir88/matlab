
location = './curves/';
identity = 0:1/255:1;
brightnessLUTP = im2double(imread([location 'PositiveBrightnessCurve.png']));
brightnessLUTN = im2double(imread([location 'NegativeBrightnessCurve.png']));
brightnessLUTN = identity + (identity - brightnessLUTN);

contrastLUTP = im2double(imread([location 'PositiveContrastCurve.png']));
contrastLUTN = im2double(imread([location 'NegativeContrastCurve.png']));
contrastLUTN = identity + (identity - contrastLUTN);

highlightsLUTP = im2double(imread([location 'PositiveHighlightsCurve.png']));
highlightsLUTN = im2double(imread([location 'NegativeHighlightsCurve.png']));
highlightsLUTN = identity + (identity - highlightsLUTN);

shadowsLUTP = im2double(imread([location 'PositiveShadowsCurve.png']));
shadowsLUTN = im2double(imread([location 'NegativeShadowsCurve.png']));
shadowsLUTN = identity + (identity - shadowsLUTN);

figure;
subplot(2,2,1);
plot(brightnessLUTP);
hold on;
plot(brightnessLUTN, 'red');
hold off;
title('Brightness');
subplot(2,2,2);
plot(contrastLUTP);
hold on;
plot(contrastLUTN, 'red');
hold off;
title('Contrast');
subplot(2,2,3);
plot(highlightsLUTP);
hold on;
plot(highlightsLUTN, 'red');
hold off;
title('Highlights');
subplot(2,2,4);
plot(shadowsLUTP);
hold on;
plot(shadowsLUTN, 'red');
hold off;
title('Shadows');


