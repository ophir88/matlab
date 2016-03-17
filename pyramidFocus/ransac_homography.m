function [H, used_points] = ransac_homography(PTS1, PTS2, ...
    maxIter, doRefinement)
%RANSAC_HOMOGRAPHY calculates the homography using RANSAC

%% preprocess
if size(PTS1,1) == 2
    PTS1(3,:) = 1 ;
end
if size(PTS2,1) == 2
    PTS2(3,:) = 1 ;
end
%% calculate RANSAC score
numPoints = size(PTS1,2);
fit_points_per_iteration = 4;
for t = 1:maxIter
    % estimate homograpyh
    subset = vl_colsubset(1:numPoints, fit_points_per_iteration);
    A = [] ;
    for i = subset
        A = cat(1, A, kron(PTS1(:,i)', vl_hat(PTS2(:,i)))) ;
    end
    [U,S,V] = svd(A) ;
    H{t} = reshape(V(:,9),3,3) ;
    
    % score homography
    PTS2_ = H{t} * PTS1;
    du = PTS2_(1,:)./PTS2_(3,:) - PTS2(1,:)./PTS2(3,:);
    dv = PTS2_(2,:)./PTS2_(3,:) - PTS2(2,:)./PTS2(3,:);
    ok{t} = (du.*du + dv.*dv) < 6*6;
    score(t) = sum(ok{t});
end
% fprintf('Went through %d iterations\n',t);

[score, best] = max(score);
H = H{best};
ok = ok{best};
used_points = ok;

%% Optional refinement
function err = residual(H)
    u = H(1) * PTS1(1,ok) + H(4) * PTS1(2,ok) + H(7) ;
    v = H(2) * PTS1(1,ok) + H(5) * PTS1(2,ok) + H(8) ;
    d = H(3) * PTS1(1,ok) + H(6) * PTS1(2,ok) + 1 ;
    du = PTS2(1,ok) - u ./ d ;
    dv = PTS2(2,ok) - v ./ d ;
    err = sum(du.*du + dv.*dv) ;
end

if doRefinement
    if exist('fminsearch') == 6 || exist('fminsearch') == 2
        H = H / H(3,3) ;
        opts = optimset('Display', 'none', 'TolFun', 1e-8, 'TolX', 1e-8) ;
        H(1:8) = fminsearch(@(x) residual(x), H(1:8)', opts) ;
    else
        warning('Refinement disabled as fminsearch was not found.') ;
    end
end
%% timer
% timing = toc();
% fprintf('RANSAC Homography time is %g seconds\n', timing);

end