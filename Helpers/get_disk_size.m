% get disk size
function disk_size_tb = get_disk_size(disk_num)

    cmd = sprintf('powershell.exe "(Get-Disk -Number %d).size"', disk_num) ;
    [status,disk_size] = system(cmd) ;
    if status ~= 0
        disk_size_tb = [] ;
        fprintf('Unable to obtain volume label for disk %d\n', disk_num)
    else
        disk_size_tb = str2double(disk_size)/1E12 ;
    end
end
