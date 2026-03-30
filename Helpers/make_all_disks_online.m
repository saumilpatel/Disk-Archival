function [initstatus, initoutput, onlinestatus, onlineoutput] = make_all_disks_online()

%   initialize
    cmd = 'powershell.exe "Get-Disk | Where-Object PartitionStyle -Eq ''RAW'' | Initialize-Disk -PartitionStyle GPT"' ;

    [initstatus, initoutput] = system(cmd) ;

    cmd = 'powershell.exe "Get-Disk | Where-Object IsOffline -Eq $true | Set-Disk -IsOffline $false -IsReadOnly $false"' ;

    [onlinestatus, onlineoutput] = system(cmd) ;

end