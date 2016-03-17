imgs = loadImages('./photos');
%%
close all;
for i = 1 : length(imgs)
    img = imgs{i};
    [R,C,d] = size(img);
    maxSize = max(R,C);
    aspect = maxSize / 400;
    
    imgOrigin = imresize(img, 3/ aspect);
    imHistResult = autoCurveEnlight(img);
%     imgResultQuick = autoExpose2(img);
    
%     imgResult = autoExpos(img);
    figure;
    ax1 = subplot(1,2,1);
    imshow(imgOrigin);
    title('Original');
%     ax2 =subplot(2,2,3);
%     imshow(imgResult);
%     title('Result');
%     ax3 =subplot(2,2,2);
%     imshow(imHistResult);
%     title('hist equalization');
    ax2 =subplot(1,2,2);
    imshow((imgOrigin.*0.5 + imHistResult.*0.5));
    title('blended');
    linkaxes([ax1 ax2],'xy')
end
