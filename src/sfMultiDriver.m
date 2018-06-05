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
 
  langNames = containers.Map({1,2}, {'englishE50', 'bengali17'}); % for small testing
  langNames = containers.Map({1,2}, {'mini-english', 'englishE50'}); % for small testing
  %% for best-case-testing; should match results of sfdriver
  langNames = containers.Map({1,2}, {'mini-english', 'mini-bengali'}); % for tiny testing
  langNames = containers.Map({1,2}, {'mini-english', 'mini-english'}); 
  langNames = containers.Map({1,2}, {'englishE50', 'englishE50'}); 
  langNames = containers.Map(...
      {1,2,3,4,5,6}, ...
      {'zuluE93', 'thaiE90', 'tagalogE89', 'englishE50', 'bengali17', 'indonesianE91'});

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

    nPredictees = size(trainY,2);
    for predictee=1:nPredictees 

      %% Model 1 is metadata
      warning('off', 'stats:LinearModel:RankDefDesignMat');  % useful for preliminary test on tiny datasets
      model1 = fitlm(trainX1, trainY(:,predictee));
      preds1 = predict(model1, testX1);
      [~, pranuc, ~] = niceStats(preds1, trainY(:,predictee), ...
				 [langNames(heldout) ' ' sfFieldName(predictee)]);
      pranucs1(heldout, predictee) = pranuc;
            
      %% Model 2 is metada + prosodic feature averages
      model2 = fitlm(trainX2, trainY(:,predictee));
      warning('on', 'stats:LinearModel:RankDefDesignMat');  
      preds2 = predict(model2, testX2);
      [~, pranuc, ~] = niceStats(preds2, trainY(:,predictee), ...
				 [langNames(heldout) ' ' sfFieldName(predictee)]);
      pranucs2(heldout, predictee) = pranuc;

      %% Model 3 is metada + prosodic feature averages and standard deviations 
      model3 = fitlm(trainX3, trainY(:,predictee));
      warning('on', 'stats:LinearModel:RankDefDesignMat');  
      preds3 = predict(model3, testX3);
      [~, pranuc, ~] = niceStats(preds3, trainY(:,predictee), ...
				 [langNames(heldout) ' ' sfFieldName(predictee)]);
      pranucs3(heldout, predictee) = pranuc;
    end
  end

  fprintf('leave-one-out average across %d languages:\n', nlanguages);
  fprintf(' avg pranucs with:  metadata, ditto+pfmeans, ditto + pfstds\n');
  for fieldID = 1:nPredictees
    fprintf('   %13s    %.2f  %.2f  %.2f\n', ...
	    sfFieldName(fieldID), mean(pranucs1(:,fieldID)), mean(pranucs2(:,fieldID)), mean(pranucs3(:,fieldID)));
  end
  fprintf('   %13s    %.2f  %.2f  %.2f \n', 'AVERAGES', ...
	  mean(mean(pranucs1)), mean(mean(pranucs2)), mean(mean(pranucs3)));

  fprintf('\nPerformance on  predicting gravity\n');
  for lang = 1:nlanguages
    fprintf('%10s %.2f  %.2f  %.2f\n', langNames(lang), pranucs1(lang, 6), pranucs2(lang, 6), pranucs3(lang, 6));
  end
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


%% cache for future reuse, to prevent heavy, repetetive computation and file i/o
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

  
