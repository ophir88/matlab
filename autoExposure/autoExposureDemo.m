imgs = loadImages('./photos');
%%
close all;
for i = 1 : length(imgs)
    img = imgs{i};
    [R,C,d] = size(img);
    maxSize = max(R,C);
    aspect = maxSize / 400;
    
    imgOrigin = imresize(img, 3/ aspect);
    enlightAlgebra = autoCurveEnlight(img, 0);
    enlightMin = autoCurveEnlight(img, 1);
%     imgResultQuick = autoExpose2(img);
    
%     imgResult = autoExpos(img);
    figure;
    ax1 = subplot(1,3,1);
    imshow(imgOrigin);
    title('Original');
    ax2 =subplot(1,3,2);
    imshow(enlightAlgebra);
    title('enlight algebra');
    ax3 =subplot(1,3,3);
    imshow(enlightMin);
    title('enlight min');
    linkaxes([ax1 ax2],'xy')
end
