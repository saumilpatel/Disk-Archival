%{
# jbod unit details
-> storage.Servers
unit_id : int                      # some identifier of the jbod unit attached to sas port
unit_sernum : varchar(255)         # serial number of the jbod unit
-----
scsi_port : int                    # sas port number
num_slots : int                    # number of slots in the unit
ts = CURRENT_TIMESTAMP : timestamp # tuple insertion time
%}

classdef Units < dj.Manual
end