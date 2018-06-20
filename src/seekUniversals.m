% Nigel Ward, June 2018 

%% nigel/stance/src/seekUniversals.m 

%% across the 6 lorelei languages, which features *consistently*
%%  correlate with each of the features?
%% this will be useful for feature selection, since such features
%%  are more likely to be useful for a new langauge
%% and also useful for discussion in a paper on possible universals
%%  or at least "Cross-Language Prosodic Indicators of Situation Urgency and Status"

%% run this from h:/nigel/lorelei/ldc-from

function seekUniversals()

  langNames = containers.Map(   {1,2},    {'mini-english', 'mini-english'});
  langNames = containers.Map(   {1},    {'englishE50'});
  langNames = containers.Map(   {1},    {'thaiE90'});
  langNames = containers.Map(...
      {1,2,3,4,5,6}, ...
      {'zuluE93', 'thaiE90', 'tagalogE89', 'englishE50', 'bengali17', 'indonesianE91'});

  nLangs = length(langNames);
  correlations = cell(nLangs, 1);

  for lang = 1:nLangs
    langDir = langNames(lang);
    correlations{lang} = sfdriver([langDir '/aufiles'], [langDir '/anfiles']);
  end

  for predictee=1:17
    fprintf('for predictee %.2d (%s)\n', predictee,  sfFieldName(predictee));
    for predictor=1:26
      fprintf('      predictor %.2d (%s): ', predictor, predictorName(predictor));
      for lang=1:nLangs
	correl = correlations{lang};
	fprintf(' %5.2f', correl(predictor, predictee));
      end
      fprintf('\n');
    end
    fprintf('\n');
  end
end


function string = predictorName(index)
  persistent featurespec;

  if length(featurespec) == 0
    featurespec = getfeaturespec('h:/nigel/midlevel/flowtest/oneOfEachTuned.fss');  % hardcoded, yuck
    alreadyRead = 1;
  end
  
  nfeats = length(featurespec);
  if index <= nfeats
    featureInfo = featurespec(index);
    string = sprintf('avg-%s-%3dms', featureInfo.featname, featureInfo.duration);
  else
    featureInfo = featurespec(index-nfeats);
    string = sprintf('std-%s-%3dms', featureInfo.featname, featureInfo.duration);
  end
end
