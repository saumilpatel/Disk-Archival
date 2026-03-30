function [status,output] = format_disk(disk_num, volume_label)
    drive_letter = 'T' ;
    cmd = sprintf('(echo select disk %d & echo clean & echo create partition primary & echo format fs=ntfs label=%s quick & echo assign letter=%s) | diskpart', disk_num, volume_label, drive_letter); 
    [status, output] = system(cmd) ;
    if status ~= 0
        fprintf('Error formatting disk %d\n', disk_num)
    else
        [status, output] = remove_drive_letter(drive_letter)
        if status == 0
            fprintf('Formatted disk %d, volume %s sucessfully\n', disk_num, volume_label)
        end
    end

end
