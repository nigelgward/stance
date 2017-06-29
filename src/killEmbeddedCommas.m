
%% I parse using commas as separators,
%% but that's a problem if there's a field like "terrorism, elections"
%% so this function kills the commas

function cleaned = killEmbeddedCommas(string)
  insideString = false;
  for i = 1:length(string)
    if insideString == true && string(i) == '"'
      insideString = false;
      continue
    end
    if insideString == false && string(i) == '"'
      insideString = true;
      continue
    end
    if insideString == true && string(i) == ','
      string(i) = ' ';
      continue
    end
  end
  cleaned = string;
end

      
	  
	  
