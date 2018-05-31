function [propPredictions, votePerPatch, patchNeighbors] = ...
	 patchwiseKNN(segmentData, modelPatchesProsody, modelPatchesProps, k)
  
  %% Nigel Ward, UTEP, June 2017
  %% see ../doc/UTEP-prosody-overview.docx and Inferring Stance from Prosody
  %% derived from Jason Carlson's regSegmentKNN.m
  
  %% segmentData is the prosody of the patches of the segment to classify 
  %% modelPatchesProsody and modelPatchesProps are the model to use in classifying
  %% k is the number of neighbors to find 

  %% propPredictions is a vector of inferred property values
  %% votePerPatch and patchNeighbors are just for tracing purposes
  
  %% reducing precision gives no speedup: digits(3); vpa(segmentData); vpa(modelPatches);

  nproperties = size(modelPatchesProps, 2);
  npatches = size(segmentData,1);
  votePerPatch = zeros(npatches, nproperties);
  
  [patchNeighbors, distances] = ...
  knnsearch(modelPatchesProsody(1:2:end,:), segmentData, 'K', k);%temporary speed hack!!!
%%     knnsearch(modelPatchesProsody, segmentData, 'K', k); 

  
  dsquared = distances .^ 2 + 0.0000000001;
    
  %% accumulate votes from all the patches
  for row = 1:npatches
  
    kDistances = dsquared(row,:);
    kIndices = patchNeighbors(row,:);
    kPropVals = modelPatchesProps(kIndices, :);  % size is k by nproperties
    
    kWeights = (1 ./ kDistances)';
    kWeightsMat = repmat(kWeights, 1, nproperties);
    
    % weighted average = sum(value_i * weight_i) / sum(weight_i) for all i
    vals = kPropVals .* kWeightsMat;
    summedEvidence = sum(vals,1); % summed evidence from all k of the neighbors
    % normalize to compensate for local sparsity/density
    patchVotes = summedEvidence ./ (sum(kWeights, 1));
    votePerPatch(row,:) = patchVotes;
  end
  %% for each property, the segment-level prediction is the average of
  %% the patch predictions
  propPredictions = mean(votePerPatch);
end

%% testing:
%% patchwiseKNN([1,1; 2,2; 3,3], [1,1; 2,2.1; 3,3; 4,4; 5,5], [1;1;1;0;0],2)
%%  should return 1
%% patchwiseKNN([1,1; 2,2; 3,3], [1,1; 2,2.1; 3,3; 4,4; 5,5], [0;0;0;1;1],2)
%%  should return 0 
%% patchwiseKNN([4.1,4;5.1,4], [1,1; 2,2.1; 3,3; 4,4; 5,5], [0;0;0;1;1],2)
%%  should return 1
%% patchwiseKNN([4.1,4;5.1,4], [1,1; 2,2.1; 3,3; 4,4; 5,5], [0;0;0;1;.6],2)
%%  should return ~.9

