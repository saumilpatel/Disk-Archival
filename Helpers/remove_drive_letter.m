function [status,output] = remove_drive_letter(letter)

    cmd = sprintf('(echo select volume "%s" & echo remove letter=%s) | diskpart', letter, letter) ;
    [status, output] = system(cmd) ;
    if status ~= 0
        fprintf('Error removing drive letter %s\n', letter) ;
    end
end
