function [ output ] = pyrDetails( input, detailsAmount )
%PYRDETAILS Summary of this function goes here
%   Detailed explanation goes here

pyr1 = genPyr(input,'laplace',5);
pyrOutput = {};
pyrOutput{length(pyr1)} = pyr1{length(pyr1)};
pyrOutput{length(pyr1)-1} = pyr1{length(pyr1)-1};

for pyrNum = 1 : length(pyr1)-2
    pyrOutput{pyrNum} = real(pyr1{pyrNum}.*detailsAmount);
end
output = pyrReconstruct(pyrOutput);

end

