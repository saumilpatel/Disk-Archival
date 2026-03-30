% get disk label
function volume_label = get_disk_label(disk_num)

    cmd = sprintf('powershell.exe "Get-Disk -Number %d | Get-Partition | Get-Volume | Select-Object -ExpandProperty FileSystemLabel"', disk_num) ;
    [status,volume_label] = system(cmd) ;
    if status ~= 0
        volume_label = [] ;
        fprintf('Unable to obtain volume label for disk %d\n', disk_num)
    else
        volume_label = strtrim(volume_label) ;
    end
end
