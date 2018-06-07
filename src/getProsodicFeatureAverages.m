function props = getProsodicFeatureAverages(audir)
  fssfile = 'h:/nigel/midlevel/flowtest/oneOfEach.fss'; 
  featurespec = getfeaturespec(fssfile);
  [means, stds] = getFileLevelProsody(audir, featurespec);
  props = means;
  props = [means stds];  % may be overfitting
  fprintf('size(props) is %d, %d\n', size(props));
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
  % leadInLength = min(700, size(monster, 1));
  %  monster = monster(1:leadInLength,:);  
    means(filei, :) = mean(monster);
    stds(filei, :) = std(monster);
  end
end




  
