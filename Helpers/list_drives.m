function [status, output] = list_drives()

    cmd = 'powershell.exe "Get-WmiObject -Query ''SELECT * FROM Win32_DiskDrive'' | Select-Object DeviceID, SCSIPort, SCSITargetId, SCSILogicalUnit"' ;
    [status, output] = system(cmd) ;

end