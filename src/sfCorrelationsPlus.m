%% correlationsAndTests, in sframes, called by sfdriver.m and sfxlangDriver.m
%% Nigel Ward, UTEP, May 2018

%% prints frequences of  occurances of various values for SF properties
%% and some correlations among them
%% and correlations with some simple predictive properties

function sfCorrelationsPlus(props, presence)
  nfiles = size(presence, 1);
  nfields = size(presence, 2);

  randomGuesses = rand(nfiles, nfields);    
  evaluatePredictions(randomGuesses, presence);

  fprintf('correlations with  broadcast number\n');
  showCorrelations(props(:,1), presence);
  fprintf('correlations with log segment ID\n');
  showCorrelations(props(:,2), presence);
  fprintf('correlations with log duration of segment\n');
  showCorrelations(props(:,3), presence);

  urgencyVec = presence(:,3);
  testLinearModel(props, urgencyVec, 'predicting urgency from broadast, loc & len');
  gravityVec = presence(:,1) & presence(:,2) & presence(:,3);
  testLinearModel(props, gravityVec, 'predicting gravity from broadcast, loc & len');
end

		  
function showCorrelations(predictiveVar, actual)
  predvec = predictiveVar ./ max(predictiveVar);
  preds = repmat(predvec, 1, size(actual, 2));
  evaluatePredictions(preds, actual);
end


%% proper eval should be done by running NIST's script, but
%% that involves hassle, so here is some fast and and easy eval
function evaluatePredictions(guesses, actual)
  for i = 1:size(guesses, 2)
    p = guesses(:,i);
    a = actual(:,i);
    corr = corrcoef(horzcat(p,a));
    fprintf(' field %2d: %5.2f  %s \n', i, corr(1,2), sfFieldName(i));
    %% scatter(a,p);
    %% input('show next graph');
  end
  
  %% evaluate them also with AUC
end   

