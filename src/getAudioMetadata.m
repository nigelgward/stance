%% Nigel Ward, UTEP, June 2018
%% audir is a flat director of au files with names like CHN_EVAL_001_001.au
%% returns a matrix where rows are audio files
%%  and the columns are broadcast ID, log(segmentID), and log(filesize)
  
function data = getAudioMetadata(audir)
  filespec = sprintf('%s/*au', audir);
  aufiles = dir(filespec);
  if (size(aufiles,1) == 0)
    error('no au files in the specified directory, "%s"\n', audir);
  end
  nfiles = length(aufiles);
  nproperties = 3;  
  data = zeros(nfiles, nproperties);
  for filei = 1:nfiles   
    file = aufiles(filei);
    filesize = file.bytes;
    if file.name(10) == '_'   % then the prefix has one more _ than expected
      broadcastID = str2num(file.name(11:13)); % a three-digit number like 001
      locInBroadcast = str2num(file.name(15:17)); % a three-digit number like 001
    else
      broadcastID = str2num(file.name(10:12)) % a three-digit number like 001
      locInBroadcast = str2num(file.name(14:16)) % a three-digit number like 001
    end 
    data(filei, 1) = broadcastID;    % has little or no value
    data(filei, 2) = log(locInBroadcast);  % using log seems usually slightly better
    data(filei, 3) = log(filesize);    % using log better for urgency+, for English
  end
end

