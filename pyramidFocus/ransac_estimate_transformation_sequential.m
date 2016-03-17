function [projectionMatrices, featureData] = ...
  ransac_estimate_transformation_sequential(featureData, projectionType, refIndex)
% sift_estimate_transformation(images)
% registering images using SIFT and RANSAC and fusing them
% first image in array is used as reference

if ~exist('projectionType','var')
    projectionType='homography';
end

Nimages=size(featureData,1);
projectionMatrices=cell(Nimages,1);

%% Pair Matching
tic
for j=1:Nimages-1
    [featureData{j}.matches, featureData{j}.scores] = ...
        vl_ubcmatch(featureData{j+1}.descriptor,featureData{j}.descriptor);
    % remove pairs with scores (square euclidean distances) above median
    if length(featureData{j}.scores)>1e2
        index = featureData{j}.scores <= median(featureData{j}.scores);
        featureData{j}.scores = featureData{j}.scores(index);
        featureData{j}.matches = featureData{j}.matches(:,index);
    end
end
%time
fprintf('%s: VL Feature Matching: %g seconds\n',mfilename,toc())

%% RANSAC estimation of projection
tic
maxIter = 100;
if strcmpi(projectionType,'homography')
  %use my own ransac implementation
  doRefinement = true;
  for j=1:Nimages-1
    X1 = featureData{j+1}.feature(1:2,featureData{j}.matches(1,:));
    X2 = featureData{j}.feature(1:2,featureData{j}.matches(2,:));
    [projectionMatrices{j}, featureData{j}.used_features_binary] = ...
      ransac_homography(X1, X2, maxIter, doRefinement);
  end
  fprintf('%s: (VL) RANSAC Homography: %g seconds\n',mfilename,toc())
else
  %use IAT ransac
  for j=1:Nimages-1
    X1 = featureData{j+1}.feature(1:2,featureData{j}.matches(1,:));
    X2 = featureData{j}.feature(1:2,featureData{j}.matches(2,:));
    [featureData{j}.used_features_index, projectionMatrices{j}]=...
      iat_ransac(iat_homogeneous_coords(X1),iat_homogeneous_coords(X2),...
      projectionType,'maxIter', maxIter, 'tol',.05, 'maxInvalidCount', 10);
  end
  fprintf('%s: IAT RANSAC %s: %g seconds\n',mfilename,projectionType, toc())
end
projectionMatrices{Nimages} = eye(size(projectionMatrices{1}));

%% Compose projection matrices
projectionMatricesCopy = projectionMatrices;
for j=refIndex-2:-1:1
  projectionMatrices{j} = projectionMatrices{j}*projectionMatrices{j+1};
end
for j=refIndex+1:Nimages
  projectionMatrices{j} = projectionMatricesCopy{j-1}\projectionMatrices{j-1};
end
projectionMatrices{refIndex} = eye(size(projectionMatrices{1}));
  
end