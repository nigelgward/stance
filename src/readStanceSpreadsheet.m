function [NSvals, NStags, starts, aufilebase, stancenames] = ...
	 readStanceSpreadsheet(csvfilename)
  %% Nigel Ward, Kyoto University and UTEP, 2016-2017
  
  %% file format expected: CSV
  
  %% English and Mandarin (from Speed of Sound)
  %% row 1: "Stance Annotation"
  %% row 2: informal description of audio file 
  %% row 3: URL, whose last segment determines the audio file name
  %% row 4: "segment start time", then a list of mm:ss format times
  %% row 5: informal names for the segments 
  %% rows 6-21:  stance-num-and-name, then a list of stance values 
  %%  if the first column is empty, then skip the row
  
  %% Turkish and Uzbek (from Appen)
  %% row 1: date of annotation
  %% row 2: "lorelei file ID", then the audio file name 
  %% row 3: "segment" id, can ignore
  %% row 4: "topic": informal description for each segment
  %% row 5: "segment start time": mm:ss.dd, mm:ss.dd ... 
  %% rows 6-21: same as above 

  %% thus, what we what to pull out is
  %% NSvals: rows 6-21
  %% NStags: SOS: row 5, Appen: row 4 
  %% starts: SOS: row 4, Appen: row 5 
  %% audio filename: for SOS row 3 tail of the URL; for Appen row 2, second column
  %% stancenames: all non-blank fields in first column of rows 6-21

  %% In any case, the CSV files are generated from the excel annotation files as follows:
  %% 1. open the excel file
  %% 2. go to the Developer tab (if necessary, first do: file->options->customize ribbon)
  %% 3. click "view code"
  %% 4. Copy in the macro from http://superuser.com/questions/841398/how-to-convert-excel-file-with-multiple-sheets-to-a-set-of-csv-files
  %%   saved locally as excel-to-csv-macro
  %% 5. Click Run 

  fd = fopen(csvfilename, 'r');
  longstring = fileread(csvfilename);
  fclose(fd);
  lines = strread(longstring, '%s', 'delimiter', '\n');
  
  line1fields = strread(char(lines(1)), '%s', 'delimiter', ',');
  appenFormat = isAppenFormat(line1fields{1});
			      
  if appenFormat
    lineOfStarts = 5;
    lineOfTags = 4;
    line2fields = strread(char(lines(2)), '%s', 'delimiter', ',');
    aufilebase = char(line2fields(2));
  else
    lineOfStarts = 4;
    lineOfTags = 5;
    line3fields = strread(char(lines(3)), '%s', 'delimiter', ',');
    url = char(line3fields(1));
    aufilebase = url(29:end);   % hardcoded 
  end

  starts = minsecToSec(parseTags(lines(lineOfStarts)));

  allTags = parseTags(lines(lineOfTags));  %  informal name OR situation type / out-of-domain
  if isempty(allTags)
    %% one annotator sometimes put the topic names on the starttimes line
    error(' **no tag names found; probable file format error\n');
  end  
  columns = annotatedColumns(allTags);
  NStags = allTags(columns-1);    % remove out-of-domain columns
  [NSvals, stancenames] = parseStanceVals(lines(6:21), columns);
end

%%------------------------------------------------------------------
%% for Turkish, segments that were previously classified as "Out of Domain"
%% were not annotated for stance, so skip them
function validCols = annotatedColumns(NStags)
  validColumns = zeros(1,length(NStags));
  nValid = 0 ;
  for tagnum = 1:length(NStags)
    tag = char(NStags(tagnum));
    if (length(strfind(tag, 'Out of Domain')) > 0 || ...
	length(strfind(tag, 'Domain')) > 0 || ...
	length(strfind(tag, 'Out')) > 0 || ...
	length(strfind(tag, 'domain')) > 0 || ...
	length(strfind(tag, 'out')) > 0 )
      %%fprintf('skipping column %d, with tag %s\n', column, tag);
      continue
    else
      nValid = nValid + 1;
      spreadsheetColumn = 1 + tagnum;
      validColumns(nValid) = spreadsheetColumn;
    end
  end
  validCols = validColumns(1:nValid);
end


%%------------------------------------------------------------------
function [stanceVals, stancenames] = parseStanceVals(lines, columnsWithAnnotations)
  nValidLines = 0;
  maxProperties = 14; 
  stanceVals = zeros(maxProperties,1);
  for rowi = 1:length(lines)
    row = char(lines(rowi));
    fields = strread(row, '%s', 'delimiter', ',');
    stancename = fields(1);
    if strcmp(stancename, '') % if missing, then skip the line 
      continue  
    end 

    nValidLines = nValidLines + 1;
    stancenames(nValidLines+1) = stancename;   % append it 
    for i = 1:length(columnsWithAnnotations)
      nsi = columnsWithAnnotations(i);
      %% fprintf('i=%d, nsi=%d, nValidLines=%d fields(nsi) = %s\n', i, nsi, nValidLines, char(fields(nsi)));
      val = str2num(char(fields(nsi)));
      if isempty(val)
	val = 0;
      end
      %fprintf('i=%d, nsi=%d, nValidLines=%d, val=%d\n', i, nsi, nValidLines, val);
      stanceVals(nValidLines, i) = val;
    end
  end
  %%fprintf('stancenames has length %d\n', length(stancenames));
  stancenames = stancenames(2:end);   % kludge
end

%------------------------------------------------------------------
function tags = parseTags(tagthing)
  tags = [];
  tagstring = char(tagthing);   %  if tags is a cell array, this converts it
  tagstring = killEmbeddedCommas(tagstring);
  fields = strread(tagstring, '%s', 'delimiter', ',');
  nfields = length(fields);
  for ix = 2:nfields         % skip the first field, which will be 'topic' or an empty string
    if isEmptyOrWhitespace(char(fields(ix)))  % then it's the end 
      %% fprintf('field %d is empty or whitespace; thus past the end of meaningful data\n', ix);
      lastix = ix - 1;
      tags = fields(2:lastix);
      return
     end
  end
  tags = fields(2:nfields);
end


%------------------------------------------------------------------
function present = containsAny(element, list)
   % take the substring of element from the last / to the first 
   % see  if it is a substring of any string on the list
   element;
   present = true; % stub
end

%------------------------------------------------------------------
% converts a sequence like 1:03, 1:25 to [63, 85]
function timesInSeconds = minsecToSec(stringvec)
  timesInSeconds = [];
  for nsi = 1:length(stringvec)
    timespec = char(stringvec(nsi));
    minsec = strread(timespec, '%s', 'delimiter', ':');
    timesInSeconds(end+1) = ...
		     60 * str2num(char(minsec(1))) + str2num(char(minsec(2)));
  end
end

%%------------------------------------------------------------------
function appenish = isAppenFormat(row1)
  if strfind(row1, 'Stance')
    appenish = false;
  else
    appenish = true;
  end
end

%------------------------------------------------------------------

%% to test:
%%   readSpreadsheet('testAnnotations/stance_ChevLocalNewsJuly3_L.csv', ' ');

