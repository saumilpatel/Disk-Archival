% replace a drive in the jbod and then update the replacement table in
% enigma_storage schema
% Then, next, change the serial number in disks table manually using a
% mysql client (e.g. sequel pro on mac)

old_disk_ser_num = input('What is the old disk serial number [e.g. JCX01Z4A in single quotes] ? ') ;
new_disk_ser_num = input('What is the new disk serial number [e.g. JCX01Z4A in single quotes] ? ') ;

if ~isempty(old_disk_ser_num) && ~isempty(new_disk_ser_num)
    dp = jbod.DrivePool(0, 0) ; % parameters are unused but needed to instantoate the object
    dp.add_replacement_disk_to_db(old_disk_ser_num, new_disk_ser_num)
    clear dp ;
else
    fprintf('Unable to update the database, both disk serial numbers have to be non empty\n')
end