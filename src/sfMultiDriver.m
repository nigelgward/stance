%% evaluate situation-frame predictive models' performance
%%   on heldout languages, i.e., those  not in the training data
%% Nigel Ward, UTEP, June 2018
%% aiming to discover
%% 1. which prosody-based model is best
%% 2. how well we perform on all tasks, in order to tell our partners
%%   both for the metadata-only predictors and the plus-prosody-summary-stats predictors
%%  a. a table of pranuc values, averaged across all languages
%%  b. for gravity, a table of ditto, for each language 
%% This is for 6 languages, 17 predictees, 3 models

function sfMultiDriver()
 
  langNames = containers.Map({1,2}, {'mini-english', 'englishE50'}); % for small testing
  %% best-case-testing; matches results of sfdriver
  langNames = containers.Map({1,2}, {'englishE50', 'englishE50'}); 
  langNames = containers.Map({1,2}, {'zuluE93', 'mini-english'}); 
  langNames = containers.Map({1,2}, {'mini-english', 'mini-english'}); % for tiny testing
  langNames = containers.Map(...
      {1,2,3,4,5,6}, ...
      {'zuluE93', 'thaiE90', 'tagalogE89', 'englishE50', 'bengali17', 'indonesianE91'});

  langNames = containers.Map({1,2}, {'englishE50', 'bengali17'}); % for small testing
  langNames = containers.Map({1,2}, {'mini-english', 'mini-bengali'}); % for tiny testing

  nlanguages = length(langNames);

  for heldout = 1:nlanguages
    fprintf('sfMultiDriver: predicting for %s\n', langNames(heldout));

    languageNums = 1:nlanguages;
    trainingLanguages = languageNums;
    trainingLanguages(heldout) = [];
    fprintf('building sets for training\n');
    [trainX1, trainX2, trainX3, trainY] = buildSets(trainingLanguages, langNames);
    fprintf('building sets for test\n');
    [testX1, testX2, testX3, testY] = buildSets(heldout, langNames);
    [trainX4, testX4, trainY4, testY4] = eightyTwentySameLang(trainX3, trainY);

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

      %% Model 4 is ditto, but trained on the first 80%, tested on last 20%
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
    p4 = pranucs4(:,fieldID)
    p4noNaN = p4(~isnan(p4))
    fprintf('   %13s    %.2f  %.2f  %.2f  %.2f\n', ...
	    sfFieldName(fieldID), mean(pranucs1(:,fieldID)), mean(pranucs2(:,fieldID)), mean(pranucs3(:,fieldID)), mean(p4noNaN));
  end

  p4 = reshape(pranucs4, 1, [])
  p4noNaN = p4(~isnan(p4))
  fprintf('   %13s    %.3f  %.3f  %.3f  %.3f \n', 'AVERAGES', ...
	  mean(mean(pranucs1)), mean(mean(pranucs2)), mean(mean(pranucs3)), mean(p4noNaN));

  fprintf('average performance per language, using meta, ditto+pfmeans, ditto+pfstds, 80-20\n');
  for lang = 1:nlanguages
    p4 = pranucs4(lang, :)
    p4noNaN = p4(~isnan(p4))
    fprintf('%13s %.3f  %.3f  %.3f  %.3f\n', ...
	    langNames(lang), mean(pranucs1(lang, :)), mean(pranucs2(lang, :)), mean(pranucs3(lang, :)), mean(p4noNaN));
  end
  
  fprintf('\nPerformance on predicting gravity\n');
  for lang = 1:nlanguages
    p4g = (pranucs4(lang,6))
    p4gnoNaN = p4g(~isnan(p4g))
    fprintf('%13s %.2f  %.2f  %.2f\n', langNames(lang), pranucs1(lang, 6), pranucs2(lang, 6), pranucs3(lang, 6));
  end
  fprintf('     AVERAGES  %.3f  %.3f  %.3f  %.3f\n', mean(pranucs1(:, 6)), mean(pranucs2(:, 6)), mean(pranucs3(lang, 6)), mean(p4gnoNaN));
end


function[setX1, setX2, setX3, setY] =  buildSets(trainingLangIDs, langNames)
  naudios = 3;     % likely min number of audios
  setX1 = zeros(naudios, 3);    % 3 predictors
  setX2 = zeros(naudios, 16);   % 3+13 predictors
  setX3 = zeros(naudios, 29);   % 3+13*2 predictors
  setY = zeros(naudios, 17);    % 17 predictees
  instancesSoFar = 0;
  for i=1:length(trainingLangIDs)
    lang = trainingLangIDs(i);
    fprintf('   buildSets: now processing %s\n', langNames(lang));
    audir = ['h:/nigel/lorelei/ldc-from/' langNames(lang) '/aufiles'];
    andir = ['h:/nigel/lorelei/ldc-from/' langNames(lang) '/anfiles'];
    thisLangX1 = getAudioMetadata(audir);   
    
%%    thisLangX2 = getProsodicFeatureAverages(audir);
    pfAvgsStds = findPFaverages(audir);
    thisLangX2 = [thisLangX1 pfAvgsStds(:,1:13)]; 

    thisLangX3 = [thisLangX1 pfAvgsStds];
    thisLangY = readSFannotations(andir);
    instancesForLang = size(thisLangX1,1);
    setX1(instancesSoFar+1:instancesSoFar+instancesForLang,:) = thisLangX1;
    setX2(instancesSoFar+1:instancesSoFar+instancesForLang,:) = thisLangX2;
    setX3(instancesSoFar+1:instancesSoFar+instancesForLang,:) = thisLangX3;
    setY(instancesSoFar+1:instancesSoFar+instancesForLang,:) = thisLangY;
    instancesSoFar = instancesSoFar+instancesForLang;
  end
end


%% cache for future reuse, to prevent heavy, repetitive computation and file i/o
function pfa = findPFaverages(audir)
  persistent PFAcache;
  persistent nEntries;

  if length(PFAcache) == 0  % first call so initialize the cache
    nEntries = 0;
    PFAcache = struct('dir', {}, 'values', {});
  end

  for i = 1:nEntries
    entry = PFAcache(i);
    if strcmp(audir, entry.dir)
      pfa = entry.values;
      return
    end
  end

  pfa = getProsodicFeatureAverages(audir);
  nEntries = nEntries + 1;
  PFAcache(nEntries).values = pfa;
  PFAcache(nEntries).dir = audir;
end


function [trainX4, testX4, trainY4, testY4] = eightyTwentySameLang(trainX3, trainY);
  nstories = size(trainX3, 1);
  splitpoint = floor(nstories * 0.80);
  trainX4 = trainX3(1:splitpoint,:);
  testX4  = trainX3(splitpoint:end,:);
  trainY4 = trainY(1:splitpoint,:);
  testY4 = trainY(splitpoint:end, :);
end 
