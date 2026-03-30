%{
# table that holds backup server info
servername = "" : varchar(255)             # full  name of server
->storage.Booths                           # booth number
servertype : enum("storage","backup")      # storage or backup
-----
ts = CURRENT_TIMESTAMP : timestamp         # time when entry is made
%}

classdef Servers < dj.Manual
end