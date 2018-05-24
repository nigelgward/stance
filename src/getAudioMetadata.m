  
function data = getAudioMetadata(audir)
  filespec = sprintf('%s/*au', audir);
  aufiles = dir(filespec);
  if (size(aufiles,1) == 0)
    error('no au files in the specified directory, "%s"\n', filespec);
  end
  nfiles = length(aufiles);
  nproperties = 2;  % for now, just file length and loc in broadcast
  data = zeros(nfiles, nproperties);
  for filei = 1:nfiles   
    file = aufiles(filei);
    filesize = file.bytes;
    broadcastID = str2num(file.name(10:12)); % a three-digit number like 001
    locInBroadcast = str2num(file.name(14:16)); % a three-digit number like 001
    data(filei, 1) = broadcastID;  
    data(filei, 2) = log(locInBroadcast);  % using log seems usually slightly better
    data(filei, 3) = log(filesize);    % using log better for urgency+, for English
  end
end

