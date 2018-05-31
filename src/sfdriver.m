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

%   testMetadata(audir, presence);   % temporarily commented out
  testProsodicFeatureAverages(audir, presence)
end


function testMetadata(audir, presence)
  props = getAudioMetadata(audir);  
  sfCorrelationsPlus(props, presence);
end 

function testProsodicFeatureAverages(audir, presence)
  %%fssfile = 'h:/nigel/midlevel/flowtest/dummy.fss';
  fssfile = 'h:/nigel/midlevel/flowtest/oneOfEach.fss'; 
  featurespec = getfeaturespec(fssfile);
  props2 = getFileLevelProsody(audir, featurespec);
  %% may be better to do a t-statistic and delta of the means across present/absent
  corr = corrcoef(horzcat(props2, presence));
  
  nPredictables = size(presence, 2);
  nfeats = length(featurespec);
  %% print header
  fprintf('Correlations with: ');
  for j = 1:nfeats
    fprintf('%2s     ',  featurespec(j).featname);   
  end
  for target = 1:nPredictables
    fprintf('\n%2d %12s: ', target, sfFieldName(target));
    for pfeat = 1:nfeats
      fprintf('%5.2f  ', corr(nfeats + target, pfeat))
%      fprintf('target %d, nfeats+pfeat %d\n', nfeats + target, pfeat);      
    end
  end
  fprintf('\n');
  for target=1:nPredictables
    testLinearModel(props2, presence(:,target), sfFieldName(target));
  end
end


%% patterned on getAudioMetadata
function means = getFileLevelProsody(audir, featurespec)
  filespec = sprintf('%s/*au', audir);
  aufiles = dir(filespec);
  if (size(aufiles,1) == 0)
    error('no au files in the specified directory, "%s"\n', audir);
  end

  nproperties = length(featurespec);
  nfiles = length(aufiles);
  means = zeros(nfiles, nproperties);
  for filei = 1:nfiles   
    file = aufiles(filei);
    trackspec = makeTrackspec('l', file.name, [audir '/']);
    [~, monster] =  makeTrackMonster(trackspec, featurespec);
    means(filei, :) = mean(monster);
  end
  means
end




  
