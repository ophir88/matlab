imgs = loadImages('./photos');
%%
close all;
for i = 1 : length(imgs)
    img = imgs{i};
    [R,C,d] = size(img);
    maxSize = max(R,C);
    aspect = maxSize / 400;
    
    imgOrigin = imresize(img, 3/ aspect);
    [imageResult, imageResultNormalized originalCurve, resultingCurve, normalizedCurve] = autoCurveEnlight(img);
%     enlightMin = autoCurveEnlight(img, 1);

    figure(1);
    ax1 = subplot(2,3,1);
    imshow(imgOrigin);
    title('Original');
    ax2 =subplot(2,3,2);
    imshow(imageResult);
    title('result');
    ax3 =subplot(2,3,3);
    imshow(imageResultNormalized);
    title('result normalized weights');
    subplot(2,3,4);
    plot(originalCurve);
    title('histogram equalization curve');
    subplot(2,3,5);
    plot(resultingCurve);
    title('curve approximation');
    subplot(2,3,6);
    plot(normalizedCurve);
    title('curve normalized weights');
    linkaxes([ax1 ax2],'xy')
    input('');
end
