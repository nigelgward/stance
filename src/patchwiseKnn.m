function [propPredictions, votePerPatch, patchNeighbors] = ...
	 patchwiseKNN(segmentData, modelPatchesProsody, modelPatchesProps, k)
  
  %% Nigel Ward, UTEP, June 2017
  %% see ../doc/UTEP-prosody-overview.docx and Inferring Stance from Prosody
  %% derived from Jason's regSegmentKNN.m
  %% - changed variable names and comments to be clearer
  %% - changed it to run faster using vpa (???)
  
  %% segmentData is the prosody of the patches of the segment to classify 
  %% modelPatchesProsody and modelPatchesProps are the model to use in classifying
  %% k is the number of neighbors to find 

  %% propPredictions is the output that matters
  %% votePerPatch and patchNeighbors are just for tracing purposes
  
%tic
%digits(3);
%vpa(segmentData);
%vpa(modelPatchesProsody); 
%% for English corpus: 
%%  when digits = 6, vpa takes 8-10 minutes, knn takes 3 seconds, unchanged
%%  when digits = 3, vpa takes 10 minutes, knn takes .7 seconds vs .4 sec
%toc 

  nproperties = size(modelPatchesProps, 2);
  npatches = size(segmentData,1);
  votePerPatch = zeros(npatches, nproperties);
  
  [patchNeighbors, distances] = ...
    knnsearch(modelPatchesProsody, segmentData, 'K', k);
  
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

