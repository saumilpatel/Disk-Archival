function fileList = listDriveFiles(driveLetter)
% LISTDRIVEFILES Lists all files on a specified Windows drive with creation dates
%
% Excludes: Recycle Bin ($Recycle.Bin) and .DS_Store files
%
% Output:
%   fileList - Structure array with fields: 
%              name, folder, fullPath, dateModified, dateCreated, bytes, isdir

    if nargin < 1
        error('Drive letter must be specified');
    end
    
    if ischar(driveLetter)
        driveLetter = upper(driveLetter(1));
    else
        error('Drive letter must be a character');
    end
    
    rootPath = [driveLetter ':\'];
    
    if ~isfolder(rootPath)
        error('Drive %s:\ does not exist or is not accessible', driveLetter);
    end
    
    fprintf('Scanning drive %s...\n', rootPath);
    fprintf('This may take several minutes depending on the drive size...\n\n');
    
    fileList = getAllFiles(rootPath);
    
    fprintf('Scan complete! Found %d files.\n', length(fileList));
end

function allFiles = getAllFiles(dirPath)
    
    allFiles = struct('name', {}, 'folder', {}, 'fullPath', {}, ...
                      'dateModified', {}, 'dateCreated', {}, 'bytes', {}, 'isdir', {});
    
    try
        contents = dir(dirPath);
        contents = contents(~ismember({contents.name}, {'.', '..'}));
        
        for i = 1:length(contents)
            % Skip .DS_Store files
            if strcmp(contents(i).name, '.DS_Store')
                continue;
            end
            
            fullPath = fullfile(dirPath, contents(i).name);
            
            % Skip Recycle Bin folder
            if contents(i).isdir && (strcmp(contents(i).name, '$Recycle.Bin') || ...
                                     strcmp(contents(i).name, '$RECYCLE.BIN') || ...
                                     strcmp(contents(i).name, 'RECYCLER') || ...
                                     strcmp(contents(i).name, 'Recycled'))
                continue;
            end
            
            % Skip if path contains Recycle Bin (in case we're already inside it)
            if contains(fullPath, '$Recycle.Bin', 'IgnoreCase', true) || ...
               contains(fullPath, 'RECYCLER', 'IgnoreCase', true) || ...
               contains(fullPath, 'Recycled', 'IgnoreCase', true)
                continue;
            end
            
            if contents(i).isdir
                try
                    subFiles = getAllFiles(fullPath);
                    allFiles = [allFiles; subFiles]; %#ok<AGROW>
                catch ME
                end
            else
                fileInfo.name = contents(i).name;
                fileInfo.folder = contents(i).folder;
                fileInfo.fullPath = fullPath;
                fileInfo.dateModified = contents(i).date;
                fileInfo.bytes = contents(i).bytes;
                fileInfo.isdir = contents(i).isdir;
                fileInfo.dateCreated = getCreationDate(fullPath);
                
                allFiles = [allFiles; fileInfo]; %#ok<AGROW>
            end
        end
    catch ME
    end
end

function creationDate = getCreationDate(filePath)
    try
        fileInfo = System.IO.FileInfo(filePath);
        creationDateTime = fileInfo.CreationTime;
        creationDate = datetime(creationDateTime.Year, creationDateTime.Month, ...
                               creationDateTime.Day, creationDateTime.Hour, ...
                               creationDateTime.Minute, creationDateTime.Second);
        creationDate = char(creationDate);
    catch
        creationDate = 'N/A';
    end
end