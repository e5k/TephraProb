%
% tableCell = HTMLTABLETOCELL(htmlFileName,tables)
% one table in html file "htmlFileName" is read into tableCell, as
% identified by variable "tables"
% 
% tableCell is a cell array of strings. In case of numerical values, run
% sscanf afterwards. To automatically download html, use wget.exe which can
% be downloaded separately (no affiliation with author.)
%
% tables determines how to identify the table in question:
% 1) tables.idTableBy.plaintextPreceedingTable - 
%       - identify the table by a string to search for which proceeds the table
% 2) tables.idTableBy.plaintextInFirstTD
%       - identify the table by a string in the upper left colum and row of table.
% 3) tables.idTableBy.from_tr_with_plaintext
%       - 3 is for rare cases of poorly written html code where table
%       entries are missing. in that case just look for the row that
%       starts with text and load everthing that follows
%
% 
%
%
%   Written By:         Steinar M. Elgsæter
%   Last Updated:       06.02.2012
%
% This program is distributed in the hope that it will be useful,
% but WITHOUT ANY WARRANTY; without even the implied warranty of
% MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. 
%
%

function tableCell  = htmlTableToCell(htmlFileName, tables)

  tableCell         = {};
  fileString        = file2string(htmlFileName);

  % if the table is identified by the plain text that superseeds it.
  idTableBy         = fieldnames(tables.idTableBy);
  % ************************ case 1 ******************************
  if strcmp(idTableBy{1},'plaintextPreceedingTable')
    str             = tables.idTableBy.plaintextPreceedingTable;
    pos             = strfind(fileString,str);
    if isempty(pos)
      disp(sprintf('string %s not found in %s, table not loaded',str,htmlFileName));
      %
      dataFound = 'no';
      return;
    end%if
    tablePosBegin     = strfind(lower(fileString),'<table');
    tablePosEnd       = strfind(lower(fileString),'</table>');
    tableBeginNr      = 1;
    tableEndNr        = 1;
    while pos>tablePosBegin(tableBeginNr)
      tableBeginNr      = tableBeginNr+1;
    end%while
    while tablePosEnd(tableEndNr)<tablePosBegin(tableBeginNr)
      tableEndNr      = tableEndNr+1;
    end%while    
    res_tablePosBegin = tablePosBegin(tableBeginNr);
    res_tablePosEnd   = tablePosEnd(tableEndNr);
  % ************************ case 2 ******************************
  elseif strcmp(idTableBy{1},'plaintextInFirstTD')
    str               =  tables.idTableBy.plaintextInFirstTD;
    pos               = strfind(fileString,str);
    if isempty(pos)
        disp(sprintf('string %s not found in %s, Table nr %i not loaded',...
                  str,htmlFileName));
        dataFound     = 'no';
        return;%continue;
    end%if
    tablePosBegin       = strfind(lower(fileString),'<table');
    tablePosEnd         = strfind(lower(fileString),'</table>');
    if isempty(tablePosBegin)||isempty(tablePosEnd)
      disp(sprintf('string <table> not found in %s, Table nr %i not loaded',...
        str,htmlFileName));
      %dataFound   = 'no';
      return;%continue;
    end
    tableBeginNr        = 1;
    tableEndNr          = 1;
    while pos > tablePosBegin(tableBeginNr) 
        tableBeginNr = tableBeginNr + 1;
        if tableBeginNr == numel(tablePosBegin)
            break;
        end
    end%while
    tableBeginNr        = tableBeginNr-1;
    while tablePosEnd(tableEndNr) < tablePosBegin(tableBeginNr)
      tableEndNr        = tableEndNr + 1;
    end%while   
    res_tablePosBegin   = tablePosBegin(tableBeginNr);
    res_tablePosEnd     = tablePosEnd(tableEndNr);
  % ************************ case 3 ******************************
  elseif  strcmp(idTableBy{1},'from_tr_with_plaintext')
        str             = tables.idTableBy.from_tr_with_plaintext;
        pos             = strfind(fileString,str);
        if isempty(pos)
            disp(sprintf('string %s not found in %s, Table not loaded',...
                  str,htmlFileName));
            dataFound   = 'no';
            return;%continue;
        end%if
        %find first <tr prior to Pos
        trPos           = strfind(lower(fileString(1:pos)) ,'<tr');
         % find first '/table' after pos
        tableEnds       = strfind(lower(fileString(pos:size(fileString,2))) ,'</table>');
        %
        res_tablePosBegin = trPos(size(trPos,2));
        res_tablePosEnd   = tableEnds(1);

  end%if
 
  % load the table into a cell array
  tablestring           = fileString(res_tablePosBegin:res_tablePosEnd);
  tableCell             = loadTableToCellArray( tablestring  ); 

%    **********************************************************************
%   
%   
%
%
%                       SUBFUNCTIONS 
%
%
%
%
%    **********************************************************************
 

% 
%
%
%
% note: some arrays are on the from
%<tr><td></td> </tr>
% while others are one the form
%<tr><td>  </td> <th></th><th></th><th></th> </tr>
% while yet others are on the form:
% <tr><td></td></tr><td></td></tr><td></td></tr><td></td></tr>
%   -this mode is called "TableOddMode"
function  tableCell     = loadTableToCellArray(tablestring)
rowStartPos             = strfind(lower(tablestring),'<tr');
rowEndPos               = strfind(lower(tablestring),'</tr');
tableCell               = {};
isTableOddMode          = 0;

% error detection
if size(rowStartPos,2)~=size(rowEndPos,2)
  if size(rowStartPos,2)==1 && size(rowEndPos,2)>1
    isTableOddMode      = 1;
  else
    rowStartPos
    rowEndPos
    error('loadTableToCellArray error')
  end%if
end
for k                   = 1:1:size(rowStartPos,2)
  if(rowStartPos(k)>rowEndPos(k))
    error('loadTableToCellArray error');
  end%if
end%if
% nb! 
numRows                 = size(rowEndPos,2);
for curRow              = 1:1:numRows
  if isTableOddMode  == 0
    rowString     = tablestring(...
      rowStartPos(curRow):rowEndPos(curRow));
  else
    if curRow ==1;
      rowStart    = rowStartPos(curRow);
    else
      rowStart    = rowEnd;
    end
    rowEnd        = rowEndPos(curRow);
    rowString     = tablestring(rowStart:rowEnd);
  end%if
      
  colStartPosTD     = strfind(lower(rowString),'<td');
  colEndPosTD       = strfind(lower(rowString),'/td');
  colStartPosTH     = strfind(lower(rowString),'<th');
  colEndPosTH       = strfind(lower(rowString),'/th');
  colStartPos       = sort([colStartPosTD colStartPosTH]);
  colEndPos         = sort([colEndPosTD colEndPosTH]);  
  
  % error detection
  if size(colStartPos,2)~=size(colEndPos,2)
      colStartPos
      colEndPos
      error('loadTableToCellArray error');
  end%if
  for k         = 1:1:size(colStartPos,2)
    if(colStartPos(k)>colEndPos(k))
      error('loadTableToCellArray error');
    end%if
  end%if
  numCols           = size(colEndPos,2);
  for curCol        = 1:1:numCols
    colString       = rowString(colStartPos(curCol):colEndPos(curCol));
    tableCell{curRow,curCol}  = getPlainFromTDString(colString);
    clear colString;
  end%for
 
  clear rowString;
  clear colStartPos;
  clear colEndPos;
end%for

% finds all text between <TD> and </TD> or between <TH> and </TH> which is not separated by <>,
% such as a span or font command
function     outstring      = getPlainFromTDString(...
  string)
outstring           ='';
curletter           = 1;
openbracket         = '<';
closedbracket       = '>';
isinsidebracket     = 0;
curoutletter          = 1;
for curletter         = 1:1:size(string,2)
  isopenbracket       = strcmp(openbracket,string(curletter));
  isclosedbracket     = strcmp(closedbracket,string(curletter));
  if isopenbracket 
    isinsidebracket   = 1;
  elseif isclosedbracket
    isinsidebracket   = 0;
  end
  if isinsidebracket ==0 && isclosedbracket == 0
    outstring(curoutletter) = string(curletter);
    curoutletter      = curoutletter+1;
  end
end

% remove trailing blanks
outstring             = deblank(outstring);
% make sure that æ,ø,å,ö and ä are handled properly!!
outstring = strRemoveHTMLspecialChars(outstring);

function outstring = strRemoveHTMLspecialChars(instring)

instring             = strrep(instring,'&aelig;','æ' );
instring             = strrep(instring,'&oslash;','ø' );
instring             = strrep(instring,'&aring;','å' );
instring             = strrep(instring,'&ouml;','ö' );
instring             = strrep(instring,'&auml;','ä' );
instring             = strrep(instring,'&Aelig;','Æ' );
instring             = strrep(instring,'&Oslash;','Ø' );
instring             = strrep(instring,'&Aring;','Å' );
instring             = strrep(instring,'&Ouml;','Ö' );
instring             = strrep(instring,'&Auml;','Ä' );

outstring             = instring;

function fileString = file2string(filename,varargin)  

warning('off','MATLAB:nonIntegerTruncatedInConversionToChar');

  fid                 = fopen(filename);
  if fid==-1
    disp( sprintf( 'file2String could not load:%s',filename ) );
      fileString        = '';
    return;
  end
  fileString          = '';
  linestring          = '';
  EOFreached          = 0;
  
  % first,just load the entire table into a string.
  fseek(fid,0,1);%go to EOF
  EOFpos              = ftell(fid);
  fseek(fid,0,-1);%go to BOF
%  counter             = 1;
  while EOFreached ==0
      if ~isempty(varargin)
        linestring        = fgets(fid);
      else
        linestring        = fgetl(fid);
      end
      
    if linestring == -1
      EOFreached      = 1;
    end
    %fileString    = strcat(fileString,linestring);
    beginid         = size(fileString,2)+1;
    endid           = size(fileString,2)+size(linestring,2);
    
     fileString(beginid:endid) = linestring;
    %if ~isempty(varargin)
     %   disp('osdfasdf');
    %    fileString = strcat(fileString,sprintf('\r\n'));
   % end
    clear linestring;
  end%while
  fclose(fid);
  