folderPath = 'T:\';
d = System.IO.DirectoryInfo(folderPath);
folders = d.GetDirectories();
hiddenFolders = folders(arrayfun(@(x) x.Attributes.HasFlag(System.IO.FileAttributes.Hidden), folders));
names = arrayfun(@(x) char(x.Name), hiddenFolders, 'UniformOutput', false);
disp(names')