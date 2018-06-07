% Nigel Ward, April 2018 

%% nigel/sframes/sfdriver.m

%%  for situation frame inference 
%%  used for testing readSFAnnotations,
%%  and for computing correlations between various properties
%%  and for evaluating predictive models, in testset=trainingset evaluations

%% testing
%%   cd sframes
%%   sfdriver('audio-testdir', 'annot-testdir');
%% running on real data
%%   cd lorelei/ldc-from/englishE50  (or another dir with urgency labels)
%%   sfdriver('aufiles', 'anfiles');

function sfdriver(audir, andir)
  [presence, ~] = readSFannotations(andir);
  nPredictables = size(presence, 2);

  metaDataProps = getAudioMetadata(audir);
  sfCorrelationsPlus(metaDataProps, presence);
  [mcq, mpq] = testPredictability(metaDataProps, presence, 'metadata', andir);   

  pfaProps = getProsodicFeatureAverages(audir);
  showSomeCorrelations(pfaProps, presence);
  [acq, apq] = testPredictability(pfaProps, presence, 'pros.f.avgs', andir);   

  allProps = [metaDataProps pfaProps]; 
  [bcq, bpq] = testPredictability(allProps, presence, 'both sets', andir);   

  fprintf('              ---correlation---    -----pranuc-----\n');
  fprintf('                meta  pfa  both    meta  pfa  both\n');
  for i=1:nPredictables
    fprintf('%13s %5.2f %5.2f %5.2f   %5.2f %5.2f %5.2f\n', ...
	    sfFieldName(i), mcq(i), acq(i), bcq(i), mpq(i), apq(i), bpq(i));
  end
    fprintf('%13s %5.2f %5.2f %5.2f   %5.2f %5.2f %5.2f\n', ...
	    'AVERAGES', mean(mcq), mean(acq), mean(bcq), mean(mpq), mean(apq), mean(bpq));
end


function [corrQuality, pranucQuality] = testPredictability(props, presence, modelType, andir)
  nPredictables = size(presence, 2);
  corrQuality = zeros(nPredictables, 1);
  pranucQuality = zeros(nPredictables, 1);
  warning('off', 'stats:LinearModel:RankDefDesignMat')
  for target=1:nPredictables
    targetColumn = presence(:,target);

    [dcQ, pranucQ] = testLinearModel(props, targetColumn, ... 
				   [sfFieldName(target) ' from '    modelType]);
    corrQuality(target) = dcQ;
    pranucQuality(target) = pranucQ;

    model = fitlm(props, targetColumn);
    preds = predict(model, props);
    [wfa, wm] = findWorstPreds(preds, targetColumn);
    filespec = sprintf('%s/*txt', andir);
    files = dir(filespec);
    worstFA = files(wfa);
    worstMiss = files(wm);
    fprintf('for target %s, wfa is %d %s; wm is %d %s\n', ...
	    sfFieldName(target), wfa, worstFA.name, wm, worstMiss.name);
  end
  warning('on', 'stats:LinearModel:RankDefDesignMat')
end


%% a t-statistic might be more logical, but always comes out massively signficant
function showSomeCorrelations(props, presence, featurespec)
  fssfile = 'h:/nigel/midlevel/flowtest/oneOfEach.fss';  % risky to have this hardcoded
  featurespec = getfeaturespec(fssfile);

  corr = corrcoef(horzcat(props, presence));
  
  nPredictables = size(presence, 2);
  nfeats = length(featurespec);
  quality = zeros(nPredictables, 1);
  %% print header
  fprintf('Correlations with: ');
  for j = 1:nfeats
    fprintf('%2s     ',  featurespec(j).featname);   
  end
  for target = 1:nPredictables
    fprintf('\n%2d %12s: ', target, sfFieldName(target));
    for pfeat = 1:nfeats
      fprintf('%5.2f  ', corr(nfeats + target, pfeat))
    end
  end
  fprintf('\n');
end


