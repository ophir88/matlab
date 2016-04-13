lowImgs = loadImages('./photos/low');
regImgs = loadImages('./photos/reg');

%%

numOfImgs = length(lowImgs)+length(regImgs);
Y = [ones(length(lowImgs), 1).*-1 ; ones(length(regImgs), 1)]

lowDsts = darkHistogram(lowImgs);
regDsts = darkHistogram(regImgs);

%%
X = zeros(3,numOfImgs);
for i = 1 : numOfImgs
    
    if(i > length(lowImgs))
        %         histogram = reshape(regHistograms{i -length(lowImgs)}, 600,1);
        %         histogram = [histogram(1:200,1) ; histogram(401:500,1)];
        X(:,i) =  regDsts(i -length(lowImgs),:)';
    else
        %          histogram = reshape(lowHistograms{i}, 600,1);
        %          histogram = [histogram(1:200,1) ; histogram(401:500,1)];
        %         X(:,i) =  histogram;
        X(:,i) =  lowDsts(i,:)';
        
    end
end
's';
%%
lambda = 0.01 ; % Regularization parameter
maxIter = 1000 ; % Maximum number of iterations
[w b info] = vl_svmtrain(X, Y, lambda, 'MaxNumIterations', maxIter);

%% test
lowImgsT = loadImages('./photos/test/low');
regImgsT = loadImages('./photos/test/reg');

%%

% ones(length(lowImgsT), 1).*-1
numOfImgsT = length(lowImgsT)+length(regImgsT)
YT = [ones(length(lowImgsT), 1).*-1 ; ones(length(regImgsT), 1)]
YTResult = [zeros(length(numOfImgsT), 1)];

%%
lowDstsT = darkHistogram(lowImgsT);
regDstsT = darkHistogram(regImgsT);
%%
for i = 1 : numOfImgsT
    value = 0;
    if(i > length(lowImgsT))
%         figure(1); imshow(regImgsT{i -length(lowImgsT)});
% 
%         histogram =  reshape(regHistogramsT{i -length(lowImgsT)}, 600,1);
%         histogram = [histogram(1:200,1) ; histogram(401:500,1)];
        value =  regDstsT(i -length(lowImgsT),:)';

    else
%         figure(1); imshow(lowImgsT{i});
%        histogram =  reshape(lowHistogramsT{i}, 600,1);
%        histogram = [histogram(1:200,1) ; histogram(401:500,1)];
        value =  lowDstsT(i,:)';

    end
    result = value.*w
            input('');

    result = sum(result)
            input('');

    if(result > 0)
        result = -1
    else
        result = 1
    end
    YTResultT(i,1) = result;
%         input('');

end

%%
figure;
for i = 1 : numOfImgs
    if(i > length(lowImgs))
        %         histogram = reshape(regHistograms{i -length(lowImgs)}, 600,1);
        %         histogram = [histogram(1:200,1) ; histogram(401:500,1)];
        Xvalues =  regDsts(i -length(lowImgs),:)';
        plot(1, Xvalues(1,1)*Xvalues(2,1)/(Xvalues(3,1)),'b*'); 
                hold on
%             input('');

    else
        %          histogram = reshape(lowHistograms{i}, 600,1);
        %          histogram = [histogram(1:200,1) ; histogram(401:500,1)];
        %         X(:,i) =  histogram;
        Xvalues =  lowDsts(i,:)';
        plot(1, Xvalues(1,1)*Xvalues(2,1)/Xvalues(3,1),'r*'); 
        hold on
%             input('');

    end
    
end
for i = 1 : numOfImgsT
    if(i > length(lowImgsT))
        %         histogram = reshape(regHistograms{i -length(lowImgs)}, 600,1);
        %         histogram = [histogram(1:200,1) ; histogram(401:500,1)];
        Xvalues =  regDstsT(i -length(lowImgsT),:)';
        plot(1, Xvalues(1,1)*Xvalues(2,1)/Xvalues(3,1),'b*'); 
                hold on
%             input('');

    else
        %          histogram = reshape(lowHistograms{i}, 600,1);
        %          histogram = [histogram(1:200,1) ; histogram(401:500,1)];
        %         X(:,i) =  histogram;
        Xvalues =  lowDstsT(i,:)';
        plot(1, Xvalues(1,1)*Xvalues(2,1)/Xvalues(3,1),'r*'); 
        hold on
%             input('');

    end
    
end
hold off