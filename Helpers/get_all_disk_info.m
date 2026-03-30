function [status, output] = get_all_disk_info()

    % command to get disk and slot information
    cmd = 'powershell.exe "Get-WmiObject -Query ''Select * from Win32_DiskDrive''| Select-Object DeviceID, SCSIBus, SCSILogicalUnit, SCSITargetId, SCSIPort, SerialNumber"' ;

    [status,output] = system(cmd) ;
end