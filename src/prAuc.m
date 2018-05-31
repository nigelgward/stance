function A = prAuc(pred, groundTruth)
  %% computes the area under the precision-recall curve
  %% pred is a scalar estimate, often in [0,1]; ground truth is 0 or 1
  %% Nigel Ward, UTEP, May 2018
  checkInputs(pred, groundTruth);
  nPredictions = length(pred);
  nPositives = sum(groundTruth);
  [sortedPred, indices] = sort(pred, 'descend');
  sortedGt = groundTruth(indices);
  nPositiveInTopN = cumsum(sortedGt);
  recallOverTopN = nPositiveInTopN / nPositives;
  precisionAtTopN = nPositiveInTopN ./ (1:nPredictions)';
  sliceWidths = [recallOverTopN ; 1] - [0 ; recallOverTopN];
  precisionExtended = [precisionAtTopN(1) ; precisionAtTopN ; precisionAtTopN(end)];
  sliceHeights = 0.5 * (precisionExtended(2:end) + precisionExtended(1:end-1));
  sliceWidths .* sliceHeights;
  A = sum(sliceWidths .* sliceHeights);
end

  
%% test cases
%%  prAuc([.9 .1 .5 .2], [1 0 1 1]) gives 1.0
%%  prAuc([.9 .2 .8], [1 1 0]) gives .79
%%  prAuc([.1 .2 .3 .4 .8 .9], [1 1 1 0 1 0]); gives .46
%%  prAuc([.1 .2 .3 .4 .7 .9], [1 1 1 0 1 0]); gives .46
%%  prAuc([.1 .2 .3 .4 .35 .9], [1 1 1 0 1 0]); gives .44
%%  if multiple preds have the same value, score depends on order

function [newPred, newGroundTruth] = checkInputs(pred, groundTruth)
  if length(pred) ~= length(groundTruth)
    error('prAuc: lengths differ: %d %d', length(pred), length(groundTruth));
  end
  if size(pred, 1) == 1
    fprintf('prAuc: converting row vectors to column vectors\n');
    newPred = pred';
    newGroundTruth = groundTruth';
  end
  if sum(groundTruth == 0) + sum(groundTruth == 1) ~= length(groundTruth)
    error('prAuc: groundTruth does not contain only 0s and 1s');
  end
  %%if (length(find(pred < 0)) > 0) || (length(find(pred > 1)) > 0)
    %%fprintf('prAuc: warning: pred contains values outside range [0,1]'\n);
  %%end
end
