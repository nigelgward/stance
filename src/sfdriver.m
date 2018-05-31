% Nigel Ward, April 2018 

%% nigel/sframes/sfdriver.m

%%  used for testing readSFAnnotations,
%%  and for computing correlations and other stats

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
  %sfCorrelationsPlus(metaDataProps, presence);
  [mdq, mpq] = testPredictability(metaDataProps, presence, 'metadata');   

  pfaProps = getProsodicFeatureAverages(audir);
  %showSomeCorrelations(pfaProps, presence);
  [adq, apq] = testPredictability(pfaProps, presence, 'pros.f.avgs');   

  allProps = [metaDataProps pfaProps]; 
  [bdq, bpq] = testPredictability(allProps, presence, 'both sets');   

  fprintf('              ----deltaCorr----    -----pranuc-----\n');
  fprintf('                meta  pfa  both    meta  pfa  both\n');
  for i=1:nPredictables
    fprintf('%13s %5.2f %5.2f %5.2f   %5.2f %5.2f %5.2f\n', ...
	    sfFieldName(i), mdq(i), adq(i), bdq(i), mpq(i), apq(i), bpq(i));
  end
    fprintf('%13s %5.2f %5.2f %5.2f   %5.2f %5.2f %5.2f\n', ...
	    'AVERAGES', mean(mdq), mean(adq), mean(bdq), mean(mpq), mean(apq), mean(bpq));
end


function [dcQuality, pranucQuality] = testPredictability(props, presence, modelType)
  nPredictables = size(presence, 2);
  dcQuality = zeros(nPredictables, 1);
  pranucQuality = zeros(nPredictables, 1);
  for target=1:nPredictables
    [dcQ, pranucQ] = testLinearModel(props, presence(:,target), ... 
				   [sfFieldName(target) ' from '    modelType]);
    dcQuality(target) = dcQ;
    pranucQuality(target) = pranucQ;
  end
end


function props = getProsodicFeatureAverages(audir)
  fssfile = 'h:/nigel/midlevel/flowtest/oneOfEach.fss'; 
  featurespec = getfeaturespec(fssfile);
  [means, stds] = getFileLevelProsody(audir, featurespec);
  props = means;
  props = [means stds];  % may do overfitting, but appears not to affect performance
  fprintf('size(props) is %d, %d\n', size(props));
end

function showSomeCorrelations(props, presence)
  %% may be better to do a t-statistic and delta of the means across present/absent
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


%% modified from getAudioMetadata
function [means, stds] = getFileLevelProsody(audir, featurespec)
  filespec = sprintf('%s/*au', audir);
  aufiles = dir(filespec);
  if (size(aufiles,1) == 0)
    error('no au files in the specified directory, "%s"\n', audir);
  end

  nproperties = length(featurespec);
  nfiles = length(aufiles);
  means = zeros(nfiles, nproperties);
  stds = zeros(nfiles, nproperties);
  for filei = 1:nfiles   
    file = aufiles(filei);
    trackspec = makeTrackspec('l', file.name, [audir '/']);
    [~, monster] =  makeTrackMonster(trackspec, featurespec);
    means(filei, :) = mean(monster);
    stds(filei, :) = std(monster);
  end
end




  
