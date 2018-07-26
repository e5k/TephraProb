function saveAllMaps(varargin)

lst = {'pdf','eps','png'};
if nargin == 1 && nnz(strcmp(lst, varargin{1})) == 1
    frmt = lst{strcmp(lst, varargin{1})};
elseif nargin == 0
    frmt = 'pdf';
else
    errordlg('Wrong type of figure format')
    return
end

F = findobj('Type', 'Figure');
for iF = 1:length(F)
    if ~strcmp(F(iF).Name, 'TephraProb')
        print(F(iF), ['-d', frmt], fullfile(F(iF).UserData.pth, 'FIG/MAPS', [F(iF).UserData.name, '_', F(iF).UserData.md, '_', F(iF).UserData.fl, '.', frmt]))
        close(F(iF));
    end
end