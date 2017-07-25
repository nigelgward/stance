function model = makePPM(audioDir, annotationloc, fssfile, ppmfilename)

% Nigel Ward, UTEP, June 2017
% creates a prosody-properties mapping file
% similar to Jason's getStancePCdata

% to be called directly, on the top level 
% the return value is normally for debugging only 
% if fssfile is 0, compute and save only frame-level features 

  provenance = [audioDir, ' ', annotationloc, ' ', datestr(now, 'mmmdd-HH-MM')];
  if isnumeric(fssfile) && fssfile == 0
    featurespec = 0;
    stride = 10; 
  else
    featurespec = getfeaturespec(fssfile);
    stride = 100;
  end
  prosodized = prosodizeCorpus(audioDir, annotationloc, featurespec, stride);

  [means, stddevs] = computeNormalizationParams(prosodized);
  normalized = normalizeCorpus(prosodized, means, stddevs);

  [propValues, propertyNames] = getAnnotations(annotationloc);
  fprintf('size(propValues) = %d %d\n', size(propValues));

  model = mergeInPropValues(normalized, propValues);

  algorithm = 'knn'; 

  save(ppmfilename, 'provenance', 'propertyNames', 'featurespec', ...
       'means', 'stddevs', 'model', 'algorithm');
end


%------------------------------------------------------------------
function [means, stddevs] =  computeNormalizationParams(prosodized)
  allPatches = concatenateFeatures(prosodized, 0);
  means = mean(allPatches);
  stddevs = std(allPatches);
end


%------------------------------------------------------------------
function merged = mergeInPropValues(featuresPlus, propertyValues);
  nsegments = size(featuresPlus, 1);
  fprintf('in merge: size(property values) is %d, %d\n', size(propertyValues));
  if size(propertyValues,1) ~= nsegments
    error('size mismatch between audio files and annotations');
  end
  fprintf('in merge, nsegments = %d\n', nsegments);
  for i = 1:nsegments
    featuresPlus{i}.properties = propertyValues{i}.properties;
  end
  merged = featuresPlus;
end


%------------------------------------------------------------------
%% sample call:
%%  cd nigel/ppm
%%  makePPM('testAudio', 'testAnnotations', 'src/mono4.fss', 'testPPM/smalltest-ppm.mat', 100);

