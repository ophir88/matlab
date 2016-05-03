function data = sift_estimate_transformation(images, merge_indexes)
% SIFT_MERGE registering images using SIFT and RANSAC and fusing them
% merge_indexes is used to select the images to include in the fusion.
% If it is a scalar N - the first N images in the set will be included, 
% first one being used as the reference.
% If it is a vector of indexes, the first index will be used as a
% reference.

%% preprocess
N_images = length(images);
if ~exist('merge_indexes','var')
    merge_indexes=1:N_images;
elseif isscalar(merge_indexes)
    merge_indexes=1:min(merge_indexes,N_images);
else
    assert(max(merge_indexes)<=N_images)
    merge_indexes = unique(merge_indexes); % to avoid duplicates
end
%initialize data struct
N_images = length(merge_indexes);
data=cell(N_images,1);
for i=1:N_images
    %copy image
    data{i}.im=images{merge_indexes(i)};
    % make single and gray
    if size(data{i}.im,3) > 1
        data{i}.imgray=rgb2gray(im2single(data{i}.im));
    else
        data{i}.imgray=im2single(data{i}.im);
    end
    data{i}.isReference = false;
end
% mark reference image
data{1}.isReference = true;

%% Feature extraction
tic
for i=1:N_images
    [data{i}.feature, data{i}.descriptor] = vl_sift(data{i}.imgray,'PeakThresh',1e-2,'FirstOctave',1,'Magnif',2);
end
fprintf('%s: VL SIFT Feature Extraction: %g seconds\n',mfilename,toc())

%% Pair Matching
tic
assert(data{1}.isReference)
for i=2:N_images
    [data{i}.matches, data{i}.scores] = ...
        vl_ubcmatch(data{1}.descriptor,data{i}.descriptor);
end
fprintf('%s: VL Feature Matching: %g seconds\n',mfilename,toc())

%% RANSAC with homography model
% tic
% maxIter = 100;
% doRefinement = true;
% for i=2:N_images
%     X1 = data{1}.feature(1:2,data{i}.matches(1,:));
%     X2 = data{i}.feature(1:2,data{i}.matches(2,:));
%     [data{i}.H, data{i}.used_features_binary] = ...
%         ransac_homography(X1, X2, maxIter, doRefinement);
% end
% fprintf('%s: (VL) RANSAC Homography: %g seconds\n',mfilename,toc())

%% IAT_RANSAC 
tic
transform = 'homography'; % it can be approximated by euclidean as well
maxIter = 200;
for i=2:N_images
    X1 = data{1}.feature(1:2,data{i}.matches(1,:));
    X2 = data{i}.feature(1:2,data{i}.matches(2,:));
    [data{i}.used_features_index, data{i}.T]=...
        iat_ransac(iat_homogeneous_coords(X1),iat_homogeneous_coords(X2),...
        transform,'maxIter', maxIter, 'tol',.05, 'maxInvalidCount', 10);
end
fprintf('%s: IAT RANSAC Homography: %g seconds\n',mfilename,toc())

%% --------------------------------------------------------------------
%                                                         Show matches
% --------------------------------------------------------------------

% dh1 = max(size(im2,1)-size(im1,1),0) ;
% dh2 = max(size(im1,1)-size(im2,1),0) ;
% 
% figure, subplot(2,1,1) ;
% imagesc([padarray(im1,dh1,'post') padarray(im2,dh2,'post')]) ;
% o = size(im1,2) ;
% line([f1(1,matches(1,:));f2(1,matches(2,:))+o], ...
%      [f1(2,matches(1,:));f2(2,matches(2,:))]) ;
% title(fprintf('%d tentative matches', numMatches)) ;
% axis image off ;
% 
% subplot(2,1,2) ;
% imagesc([padarray(im1,dh1,'post') padarray(im2,dh2,'post')]) ;
% o = size(im1,2) ;
% line([f1(1,matches(1,ok));f2(1,matches(2,ok))+o], ...
%      [f1(2,matches(1,ok));f2(2,matches(2,ok))]) ;
% title(fprintf('%d (%.2f%%) inliner matches out of %d', ...
%               sum(ok), ...
%               100*sum(ok)/numMatches, ...
%               numMatches)) ;
% axis image off ;
% 
% drawnow ;

end