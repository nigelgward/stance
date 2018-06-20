%% evaluate situation-frame predictive models' performance
%%   on heldout languages, i.e., those  not in the training data
%% Nigel Ward, UTEP, June 2018
%% aiming to discover
%% 1. which prosody-based model is best
%% 2. how well we perform on all tasks, in order to tell our partners
%%   both for the metadata-only predictors and the plus-prosody-summary-stats predictors
%%  a. a table of auc or pranuc values, averaged across all languages
%%  b. for gravity, a table of ditto, for each language 
%% This is for 6 languages, 17 predictees, 3 models

function sfMultiDriver()
 
  langNames = containers.Map({1,2}, {'mini-english', 'englishE50'}); % for small testing
  %% best-case-testing; matches results of sfdriver
  langNames = containers.Map({1,2}, {'zuluE93', 'mini-english'}); 
  langNames = containers.Map({1,2}, {'englishE50', 'bengali17'}); % for small testing
  langNames = containers.Map({1,2}, {'bengali17', 'bengali17'});
  langNames = containers.Map({1,2}, {'indonesianE91', 'indonesianE91'}); 
  langNames = containers.Map({1,2}, {'mini-english', 'mini-english'}); % for tiny testing
  langNames = containers.Map({1,2}, {'englishE50', 'englishE50'});
  langNames = containers.Map({1,2}, {'mini-english', 'mini-bengali'}); % for tiny testing
  langNames = containers.Map(...
      {1,2,3,4,5,6}, ...
      {'zuluE93', 'thaiE90', 'tagalogE89', 'englishE50', 'bengali17', 'indonesianE91'});

  nlanguages = length(langNames);

  for heldout = 1:nlanguages
    fprintf('sfMultiDriver: predicting for %s\n', langNames(heldout));

    languageNums = 1:nlanguages;
    trainingLangIDs = languageNums;
    trainingLangIDs(heldout) = [];
    fprintf('building sets for training\n');
    [trainX1, trainX2, trainX3, trainY] = buildSfSets(trainingLangIDs, langNames, true);
    fprintf('building sets for test\n');
    [testX1, testX2, testX3, testY] = buildSfSets(heldout, langNames, true);

    filename = ['saved-' langNames(heldout)]
    X = testX3;
    Y = testY;
    save(filename, 'X', 'Y');

    [trainX4, testX4, trainY4, testY4] = eightyTwentySameLang(trainX3, trainY);

    keepers = featuresToKeep(size(trainX3,2));     % pruning
    trainX3 = trainX3(:,keepers);
    testX3  = testX3(:,keepers);
    %%featureSelection(trainX3, trainY, testX3, testY);

    nPredictees = size(trainY,2);
    for predictee=1:nPredictees 

      %% Model 1 is metadata
      warning('off', 'stats:LinearModel:RankDefDesignMat');  % useful for preliminary test on tiny datasets
      model1 = fitlm(trainX1, trainY(:,predictee));
      preds1 = predict(model1, testX1);
      [~, pranuc, ~] = niceStats(preds1, testY(:,predictee), ...
				 [langNames(heldout) ' ' sfFieldName(predictee)]);
      pranucs1(heldout, predictee) = pranuc;
            
      %% Model 2 is metadata + prosodic feature averages
      model2 = fitlm(trainX2, trainY(:,predictee));
      preds2 = predict(model2, testX2);
      [~, pranuc, ~] = niceStats(preds2, testY(:,predictee), ...
				 [langNames(heldout) ' ' sfFieldName(predictee)]);
      pranucs2(heldout, predictee) = pranuc;

      %% Model 3 is metadata + prosodic feature averages and standard deviations 
      model3 = fitlm(trainX3, trainY(:,predictee));
      preds3 = predict(model3, testX3);
      [~, pranuc, ~] = niceStats(preds3, testY(:,predictee), ...
				 [langNames(heldout) ' ' sfFieldName(predictee)]);
      pranucs3(heldout, predictee) = pranuc;

      %% Model 4 is ditto, but trained on the first 80%, tested on last 20%, for comparison to Dita's
      model4 = fitlm(trainX4, trainY4(:,predictee));
      preds4 = predict(model4, testX4);
      [~, pranuc4, ~] = niceStats(preds4, testY4(:,predictee), ...
				 [langNames(heldout) ' ' sfFieldName(predictee)]);
      pranucs4(heldout, predictee) = pranuc4;

      warning('on', 'stats:LinearModel:RankDefDesignMat');  
    end
  end

  fprintf('leave-one-out average across %d languages:\n', nlanguages);
  fprintf(' avg auc with:  metadata, ditto+pfmeans, ditto + pfstds, ditto 80-20 same lang\n');
  for fieldID = 1:nPredictees
    fprintf('   %13s    %.2f  %.2f  %.2f  %.2f\n', ...
	    sfFieldName(fieldID), mean(pranucs1(:,fieldID)), ...
	    mean(pranucs2(:,fieldID)), mean(pranucs3(:,fieldID)), ...
	    nonNanMean(pranucs4(:,fieldID)));
  end

  fprintf('   %13s    %.3f  %.3f  %.3f  %.3f \n', 'AVERAGES', ...
	  mean(mean(pranucs1)), mean(mean(pranucs2)), mean(mean(pranucs3)), ...
	  nonNanMean(pranucs4));

  fprintf('average performance per language, using meta, ditto+pfmeans, ditto+pfstds, 80-20\n');
  for lang = 1:nlanguages
    fprintf('%13s %.3f  %.3f  %.3f  %.3f\n', ...
	    langNames(lang), mean(pranucs1(lang, :)), mean(pranucs2(lang, :)), mean(pranucs3(lang, :)), nonNanMean(pranucs4(lang,:)));
  end
  
  fprintf('\nPerformance on predicting gravity\n');
  for lang = 1:nlanguages
    fprintf('%13s %.2f  %.2f  %.2f %.2f \n', langNames(lang), pranucs1(lang, 6), ...
	    pranucs2(lang, 6), pranucs3(lang, 6), pranucs4(lang,6));
  end
  fprintf('     AVERAGES  %.3f  %.3f  %.3f  %.3f\n', mean(pranucs1(:, 6)), ...
	  mean(pranucs2(:, 6)), mean(pranucs3(lang, 6)), nonNanMean(pranucs4(:,6)));
end

 
function result = nonNanMean(matrix)
  reshaped = reshape(matrix, 1, []);
  nonNan = reshaped(~isnan(reshaped));
  result = mean(nonNan);
end


function [trainX4, testX4, trainY4, testY4] = eightyTwentySameLang(trainX3, trainY);
  nstories = size(trainX3, 1);
  splitpoint = floor(nstories * 0.80);
  trainX4 = trainX3(1:splitpoint,:);
  testX4  = trainX3(splitpoint:end,:);
  trainY4 = trainY(1:splitpoint,:);
  testY4 = trainY(splitpoint:end, :);
end 


function featureSelection(trainAllX, trainAllY, testAllX, testAllY)
  urgency = 3;
  nfeats = size(trainAllX,2);
  for leaveOut = 1:nfeats       % one by one, remove a feature
    trainSubsetIndices = 1:nfeats;
    trainSubsetIndices(leaveOut) = [];
    trainX = trainAllX(:,trainSubsetIndices);
    testX = testAllX(:,trainSubsetIndices);
    trainY = trainAllY(:, urgency);
    testY = testAllY(:, urgency);
    model = fitlm(trainX, trainY);
    preds = predict(model, testX);
    [~, auc, ~] = niceStats(preds, testY, ' ');
    fprintf('for urgency, leaving out %s, auc is %.2f\n', ...
	    featurespec(leaveOut).featname, auc);
  end
end



function keepers = featuresToKeep(nfeatures)
  if nfeatures ~= 29
    error('unexpected number of features');
  end
  %% avoiding feature 1 (broadcast id)
  %% and those which are grossly inconsistent in correlation direction
  %%  for urgency across languages
  keepers = [2 3   7 8   10   13 14     18 19 20 21   25  28 29];
end
