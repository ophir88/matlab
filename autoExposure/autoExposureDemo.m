imgs = loadImages('./photos');
%%
close all;
for i = 1 : length(imgs)
    img = imgs{i};
    [R,C,d] = size(img);
    maxSize = max(R,C);
    aspect = maxSize / 400;
    
    imgOrigin = imresize(img, 3/ aspect);
    [imageResult, originalCurve, resultingCurve] = autoCurveEnlight(img);
%     enlightMin = autoCurveEnlight(img, 1);

    figure(1);
    ax1 = subplot(2,2,1);
    imshow(imgOrigin);
    title('Original');
    ax2 =subplot(2,2,2);
    imshow(imageResult);
    title('result');
    subplot(2,2,3);
    plot(originalCurve);
    title('histogram equalization curve');
    subplot(2,2,4);
    plot(resultingCurve);
    title('curve approximation');
    linkaxes([ax1 ax2],'xy')
    input('');
end
