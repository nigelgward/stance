%% generate situation-frame predictions for a new language
%%   based on a "universal model" inferred from other languages. 
%% Nigel Ward, UTEP, June 2018

%% the larger workflow is described in Readme.sf.txt

%% see also "Lorelei July 2018 Situation-Frames Evaluation:
%%   UTEP’s Prosody-Based Approach: Plans and Performance Estimates" June 6, 2018,
%%   in lorelei/report-for-cmu.doc
%% which explains the methods used, and gives performance statistics
%% those statistics were generated using sfMultiDriver.m

%% if showResults is true, then read the testset annotations and evaluate performance
%% if false, then just write the results

function sfPredict(showResults)
  addpath('h:/nigel/lorelei/uyghur-sftype-december/jsonlab-1.2');
  %% small-scale test
  %% new-language test 
  trainLangDirs = containers.Map([1], 'mini-english');
  testLangDirs = containers.Map([1], 'mandarinE115');
  %% real-scale test
  %% tiny test
  trainLangDirs = containers.Map([1], 'mini-english');
  testLangDirs = containers.Map([1], 'mini-bengali');
  
  trainLangDirs = containers.Map([1], 'englishE50');
  testLangDirs = containers.Map([1], 'englishE50');
  trainLangDirs = containers.Map(...
	  {1,2,3,4,5,6}, ...
	  {'zuluE93', 'thaiE90', 'tagalogE89', 'englishE50', 'bengali17', 'indonesianE91'});
  testLangDirs = containers.Map([1], '../sinhala0');  % IL10
    
  [~, ~, testX, testY] = buildSfSets([1], testLangDirs, showResults);
  trainingDataFile = 'h:/nigel/stance/src/sfTraining.mat';  %.mat 
  if exist(trainingDataFile, 'file') == 2
    fprintf('using cached %s\n', trainingDataFile);
    load(trainingDataFile);
    
  else
    [~, ~, trainX, trainY] = buildSfSets(1:length(trainLangDirs), trainLangDirs, true);
    provenance = 'xxxx';
      save([trainingDataFile '-new'], 'trainX', 'trainY', 'provenance');
      %% to activate for subsequent use:  cp sfTraining.mat.new sfTraining.mat
    end   

    nPredictees = size(trainY,2);
    results = zeros(size(testX, 1),nPredictees);

    for predictee = 1:nPredictees
      if predictee == 3 || predictee == 6  % urgency or gravity 
	olacsSubset = 1 + [1 3 4 6 7 8 9 11 14 15 16 19 21 23 24 25 28]; % useful for urgency
	subTrainX = trainX(:, olacsSubset);
	subTestX = testX(:, olacsSubset);
      else
	subTrainX = trainX;
	subTestX = testX;
      end
      model = fitlm(subTrainX, trainY(:, predictee));
      columnResults = predict(model, subTestX);
      results(:, predictee) = columnResults;
      if showResults
	[~, auc, ~] = niceStats(columnResults, testY(:,predictee), sfFieldName(predictee));
	fprintf('for predictee: %s auc is %.2f\n', sfFieldName(predictee), auc );
	%%	for j = 1:size(columnResults, 1)
	%%	  fprintf('file%02d: %.2f %.2f\n', j, columnResults(j), testY(j,predictee));
	%%	end
      end
    end

    writeSuspectedUrgent(results, testLangDirs(1));
    writeFieldLikelihoodsJson(results, testLangDirs(1));  % for partners
    writeSfJson(results, testLangDirs(1));   % for submission 
end


%% these will be a priority for labelers
function writeSuspectedUrgent(results, testLangDir)
  filenames = aufilenames(['h:/nigel/lorelei/ldc-from/' testLangDir '/aufiles']);
  urgencyScores = results(:,3)';
  [~, indices] = sort(results(:,3), 'descend');
  writeMostUrgent(urgencyScores(indices), filenames(indices), testLangDir, 50);
  writeMostUrgent(urgencyScores(indices), filenames(indices), testLangDir, 250);
end


function writeMostUrgent(scores, filenames, testLangDir, num)
  filename = ['h:/nigel/lorelei/ldc-from/' testLangDir '/' sprintf('top%d.txt', num)];
  fd = fopen(filename, 'w');
  fprintf(fd, 'top %d suspected urgent\n', num);
  for i = 1:min(num, length(scores))
    fprintf(fd, ' %5.2f %s\n', scores(i), filenames{i});
  end
  fclose(fd);
end


function writeSfJson(results, testLangDir)
  %% prepare to pick out which situation frames to output
  ndocs = size(results, 1);
  ntypes = 11;
  gravityOverlay = repmat(results(:,6), 1, ntypes);
  relevanceOverlay = repmat(results(:,5), 1, ntypes);
  typeEstimates = results(:, 7:17);
  hotness = gravityOverlay .* relevanceOverlay .* typeEstimates;
  sortedHotness = sort(reshape(hotness, 1, []));
  avgTypesMentioned = 1.4;
  avgFractionInDomain = 0.57;
  %% nothing depends on this being even-approximately accurate
  numberToOutput = min(1000, floor(ndocs * avgFractionInDomain * avgTypesMentioned * 1.5));

  threshold = sortedHotness(end - numberToOutput);

  %% build the list of SFs to output 
  filenames = aufilenames(['h:/nigel/lorelei/ldc-from/' testLangDir '/aufiles']);
  [~, typeStdNames] = sfNamings();
  answerObjects = cell(1, numberToOutput);   % allocate storage 
  acounter = 1;

  for doc = 1:size(results,1)
    for type = 1:ntypes
      if hotness(doc, type) < threshold
	continue
      end
      filename = filenames(doc);
      ansObj.Status = 'current';
      ansObj.DocumentID = filename{1};
      ansObj.Type = typeStdNames(type);
      ansObj.Place_KB_ID = '';
      ansObj.Confidence = hotness(doc, type);
      ansObj.Resolution = 'insufficient';
      ansObj.Urgent = true;
      if type >= 9  % it's not a need type, so we can't write these fields 
	ansObj = rmfield(ansObj, 'Resolution');
      end
      ansObj.Justification_ID = 'dummyValue';
      answerObjects{acounter} = ansObj;
      acounter = acounter + 1;  
    end
  end 
  
  savejson('', answerObjects, struct('FileName','submittable.json', ...
				     'ParseLogical', 1, 'FloatFormat', '%.3g'));
end



function writeFieldLikelihoodsJson(results, testLangDir)
  filenames = aufilenames(['h:/nigel/lorelei/ldc-from/' testLangDir '/aufiles']);
  [~, typeStdNames] = sfNamings();
  answerObjects = cell(1, size(results, 1));   % allocate storage 
  acounter = 1;

  for doc = 1:size(results, 1)    
    ansObj.DocumentID = filenames(doc);
    ansObj.Current = results(doc, 1);
    ansObj.Insufficient = results(doc, 2);
    ansObj.Urgent = results(doc, 3);
    ansObj.Place_Mentioned = results(doc,4);
    ansObj.Relevant = results(doc, 5);
    ansObj.Grave = results(doc, 6);
    for type = 1:11
      ansObj.(typeStdNames(type)) = results(doc, 6+type);
    end
    
    answerObjects{acounter} = ansObj;
    acounter = acounter + 1;
  end
  savejson('', answerObjects, struct('FileName','fieldLikelihoods.json', ...
				     'FloatFormat', '%.3g'));
end



function filenames = aufilenames(audir)
  filespec = sprintf('%s/*au', audir);
  aufiles = dir(filespec);
  if (size(aufiles,1) == 0)
    error('no au files in the specified directory, "%s"\n', audir);
  end 
  filenames = cell(1, length(aufiles));   % allocate storage 
  for i = 1:length(aufiles);
    struct = aufiles(i);
    filenames{i} = struct.name;
  end
end

  
%% because the other properties are not labled if indomain==0,
%% it could be advantageous to remove such files from the training set
%% when predicting urgency etc... but in practice, turns out not to be 
function [slimX, slimY] = onlyInDomain(X, Y)
  inDomainIndices = find(Y(:,5)==1);
  slimX = X(inDomainIndices,:);  
  slimY = Y(inDomainIndices,:);
end

