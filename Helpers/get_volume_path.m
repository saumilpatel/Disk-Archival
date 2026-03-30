% get path of a volume using its disk number
function volume_path = get_volume_path(disk_num)

cmd = sprintf('powershell "Get-Disk -Number %d | Get-Partition | Get-Volume | Where-Object DriveLetter -eq $null | Select-Object -ExpandProperty Path"', disk_num) ;
[status, volume_path] = system(cmd) ;

if status ~= 0
    fprintf('Unable to get volume path for disk %d\n', disk_num) ;
    volume_path = [] ;
else
    volume_path = strtrim(volume_path) ;
end
