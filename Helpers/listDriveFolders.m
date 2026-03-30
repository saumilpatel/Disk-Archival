function folderList = listDriveFolders(driveLetter)
% LISTDRIVEFOLDERS Lists all folders on a specified Windows drive with sizes
%
% Excludes: Recycle Bin, System Volume Information, and .DS_Store
%
% Syntax:
%   folderList = listDriveFolders(driveLetter)
%
% Input:
%   driveLetter - Single character representing the drive letter (e.g., 'C', 'D')
%
% Output:
%   folderList - Structure array with fields: 
%                name, parentFolder, fullPath, dateModified, dateCreated, sizeBytes
%
% Example:
%   folders = listDriveFolders('C');
%   folders = listDriveFolders('D');

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
    
    fprintf('Scanning drive %s for folders...\n', rootPath);
    fprintf('This may take several minutes depending on the drive size...\n\n');
    
    folderList = getAllFolders(rootPath);
    
    fprintf('Scan complete! Found %d folders.\n', length(folderList));
end

function allFolders = getAllFolders(dirPath)
    
    allFolders = struct('name', {}, 'parentFolder', {}, 'fullPath', {}, ...
                        'dateModified', {}, 'dateCreated', {}, 'sizeBytes', {});
    
    try
        contents = dir(dirPath);
        contents = contents(~ismember({contents.name}, {'.', '..'}));
        
        for i = 1:length(contents)
            % Skip .DS_Store
            if strcmp(contents(i).name, '.DS_Store')
                continue;
            end
            
            % Only process directories
            if ~contents(i).isdir
                continue;
            end
            
            % Skip Recycle Bin folders
            if strcmp(contents(i).name, '$Recycle.Bin') || ...
               strcmp(contents(i).name, '$RECYCLE.BIN') || ...
               strcmp(contents(i).name, 'RECYCLER') || ...
               strcmp(contents(i).name, 'Recycled')
                continue;
            end
            
            % Skip System Volume Information folder
            if strcmp(contents(i).name, 'System Volume Information')
                continue;
            end
            
            fullPath = fullfile(dirPath, contents(i).name);
            
            % Skip if path contains excluded folders
            if contains(fullPath, '$Recycle.Bin', 'IgnoreCase', true) || ...
               contains(fullPath, 'RECYCLER', 'IgnoreCase', true) || ...
               contains(fullPath, 'Recycled', 'IgnoreCase', true) || ...
               contains(fullPath, 'System Volume Information', 'IgnoreCase', true)
                continue;
            end
            
            % Add this folder to the list
            folderInfo.name = contents(i).name;
            folderInfo.parentFolder = contents(i).folder;
            folderInfo.fullPath = fullPath;
            folderInfo.dateModified = contents(i).date;
            folderInfo.dateCreated = getCreationDate(fullPath);
            
            % Calculate folder size
            fprintf('Calculating size for: %s\n', fullPath);
            folderInfo.sizeBytes = getFolderSize(fullPath);
            
            allFolders = [allFolders; folderInfo]; %#ok<AGROW>
            
            % Recurse into this folder to find subfolders
            try
                subFolders = getAllFolders(fullPath);
                allFolders = [allFolders; subFolders]; %#ok<AGROW>
            catch ME
                % Skip directories we don't have permission to access
            end
        end
    catch ME
        % Handle any errors
    end
end

function creationDate = getCreationDate(folderPath)
    try
        % Use .NET System.IO.DirectoryInfo for folders
        dirInfo = System.IO.DirectoryInfo(folderPath);
        creationDateTime = dirInfo.CreationTime;
        creationDate = datetime(creationDateTime.Year, creationDateTime.Month, ...
                               creationDateTime.Day, creationDateTime.Hour, ...
                               creationDateTime.Minute, creationDateTime.Second);
        creationDate = char(creationDate);
    catch
        creationDate = 'N/A';
    end
end

function totalSize = getFolderSize(folderPath)
% Calculate the total size of all files in a folder (including subfolders)
    
    totalSize = 0;
    
    try
        % Get all contents
        contents = dir(folderPath);
        contents = contents(~ismember({contents.name}, {'.', '..'}));
        
        for i = 1:length(contents)
            % Skip .DS_Store
            if strcmp(contents(i).name, '.DS_Store')
                continue;
            end
            
            fullPath = fullfile(folderPath, contents(i).name);
            
            % Skip excluded folders
            if contains(fullPath, '$Recycle.Bin', 'IgnoreCase', true) || ...
               contains(fullPath, 'RECYCLER', 'IgnoreCase', true) || ...
               contains(fullPath, 'Recycled', 'IgnoreCase', true) || ...
               contains(fullPath, 'System Volume Information', 'IgnoreCase', true)
                continue;
            end
            
            if contents(i).isdir
                % Recursively get size of subdirectory
                try
                    totalSize = totalSize + getFolderSize(fullPath);
                catch
                    % Skip inaccessible folders
                end
            else
                % Add file size
                totalSize = totalSize + contents(i).bytes;
            end
        end
    catch
        % Handle errors (permission denied, etc.)
    end
end