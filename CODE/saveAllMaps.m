function saveAllMaps

F = findobj('Type', 'Figure');
for iF = 1:length(F)
    if ~strcmp(F(iF).Name, 'TephraProb')
        print(F(iF), '-dpdf', [F(iF).Name(1:end-4), '.pdf']),
        close(F(iF));
    end
end