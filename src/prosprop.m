function [propvals, baseline] = prosprop(audioDir, segInfoDir, ppmfile, stride, flags)
	   
  %% Nigel Ward and Ivan Gris, UTEP, June 2017
  %% see ../doc/UTEP-prosody-overview.docx

  %% audioDir is the name of a directory containing au files
  %% segInfoDir is the directory containing info on the segments of the au files
  %% ppmfile is a prosody-property-mapping file
  %% stride is when chosing patches, how many milliseconds between them
  %% flags is a string of single-character codes
  
  [writeJson, leaveOneOut, ufStances] = parseTheFlags(flags);

  fprintf(' loading ppm file %s\n', ppmfile);
  load(ppmfile, 'provenance', 'propertyNames', 'featurespec', ...
       'means', 'stddevs', 'model', 'algorithm');
  
  fprintf(' processing ''%s'' with respect to %s (%s)\n', ...
	audioDir, ppmfile, provenance);
  testProsodized = prosodizeCorpus(audioDir, segInfoDir, featurespec, 100);
  testNormalized = normalizeCorpus(testProsodized, means, stddevs);

  [patchFeatures, patchProperties] = prepForKnn(model, 0, true);
  baseline = mean(patchProperties);  % means over training data
  
  nproperties = length(propertyNames);
  nsegments = length(testNormalized);
  propvals = zeros(nsegments, nproperties);
  
  fprintf(' patchwiseKnn on segment: \n');
  for i = 1:nsegments
    progressBar(i);

    segmentData = testNormalized{i}.features;
    if leaveOneOut
      [patchFeatures, patchProperties] = prepForKnn(model, i, false);
    end
    propvals(i,:) = patchwiseKnn(segmentData, patchFeatures, patchProperties, 3);
    %%    [propvals(i,:), votes] = patchwiseKnn(segmentData, patchFeatures, patchProperties, 3);
    %%debug output
    %% if i == 1
    %%  [largest, index] = max(votes(:,1))
    %%  end
  end
  fprintf('\n');

  saveResults(propvals, propertyNames, writeJson);
end
  

%%----------------------------------------------------------------------------
%% show status to show that the computation is still progressing
function progressBar(i)
  fprintf(' %3d', i);
  if mod(i, 20) == 0
    fprintf('\n');
  end
end


%----------------------------------------------------------------------------
function saveResults(propvals, propertyNames, jsonFlag)

% !!! important for NIST competition!!!  normalizedEstimates = newNormalize(allEstimates);

  filePrefix = 'props';
  outdir = 'outputs';
  outfilebase = sprintf('%s/%s%s', outdir, filePrefix, datestr(now, 'mmmdd-HH-MM'));
  save([outfilebase '.mat'], 'propvals');
  if jsonFlag
       fprintf('not implemented\n');  % use writeResultsAsJason in december.m
  end
end


%----------------------------------------------------------------------------
function [writeJson, leaveOneOut, ufStances] = parseTheFlags(flags)
  writeJson = false;
  leaveOneOut = false;
  ufStances = false; 
  if strfind(flags, 'j')
     writeJson = true;
     end
  if strfind(flags, 'l')
    leaveOneOut = true;
  end
  ufstances = false; 
  if strfind(flags, 'u')
    ufStances = true;
  end
end
	      
      
%----------------------------------------------------------------------------
%% testing
% matlab
% addpath h:/nigel/midlevel/src/
% addpath h:/nigel/lorelei/uteppp/src
% cd h:/nigel/ppm
% prosprop('testAudio', 'testAnnotations', 'testPPM/smalltest-ppm.mat', '');
