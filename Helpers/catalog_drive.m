% catalog a drive pool's drive
% status is 0 if no error
function status = catalog_drive(booth, drive_num, partition_num)

drive_letter = 'K' ;
[status, ~] = assign_drive_letter(drive_num, partition_num, drive_letter) ;

if status == 0
    try
        filelist = listDriveFiles(drive_letter) ;
    
        if ~isempty(filelist)
            tp.booth = booth ;
            tp.disk_id = drive_num ;
            tp = fetch(storage.Volumes & tp) ;
            for ii = 1 : length(filelist)
                tp.filename = filelist(ii).fullPath ;
                tp.created =  filelist(ii).dateCreated ;
                tp.modified =  filelist(ii).dateModified ;
                tp.size =  filelist(ii).bytes ;
                if count(storage.Files & tp) == 0
                    try
                        insert(storage.Files, tp) ;
                    catch
                        fprintf('File %s on drive num %d cannot be inserted\n', filelist(ii).fullPath, drive_num)
                    end
                end
            end
        else
            fprintf('No files on disk %d\n', drive_num) ;
        end
    catch
    end
    remove_drive_letter(drive_letter) ;
else
    fprintf('Unable to mount drive number %d and partion number %d as drive letter %s\n', drive_num, partition_num, drive_letter)
end
