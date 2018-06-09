%% generate situation-frame predictions for a new language
%%   based on a "universal model" inferred from other languages. 
%% Nigel Ward, UTEP, June 2018

%% the larger workflow is described in Readme.sf.txt

%% see also "Lorelei July 2018 Situation-Frames Evaluation: UTEP’s Prosody-Based Approach: Plans and Performance Estimates" June 6, 2018, in lorelei/report-for-cmu.doc
%% which explains the methods used, and gives performance statistics
%% those statistics were generated using sfMultiDriver.m

function sfPredict()
    %% tiny test
    trainLangDirs = containers.Map([1], 'mini-bengali');
    testLangDirs = containers.Map([1], 'mini-english');

    %% small-scale test
    trainLangDirs = containers.Map([1], 'englishE50');
    testLangDirs = containers.Map([1], 'englishE50');
    %% new-language test 
    trainLangDirs = containers.Map([1], 'mini-english');
    testLangDirs = containers.Map([1], 'mandarinE115');
    %% real-scale test
    trainLangDirs = containers.Map(...
      {1,2,3,4,5,6}, ...
      {'zuluE93', 'thaiE90', 'tagalogE89', 'englishE50', 'bengali17', 'indonesianE91'});
    testLangDirs = containers.Map([1], 'mandarinE115');

    [~, ~, testX, ~] = buildSfSets([1], testLangDirs, false);
    %% the next line takes around 35 minutes.  Could precompute if desired.
    [~, ~, trainX, trainY] = buildSfSets(1:length(trainLangDirs), trainLangDirs, true);
    nPredictees = size(trainY,2);
    results = zeros(size(testX, 1),nPredictees);
    for predictee=1:nPredictees 
      model = fitlm(trainX, trainY(:, predictee));
      results(:, predictee) = predict(model, testX);
    end
    writeFieldLikelihoodsJson(results, testLangDirs(1));  % for partners
    writeSfJson(results, testLangDirs(1));   % for submission 
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
	ansObj = rmfield(ansObj, 'Urgent');
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

  
