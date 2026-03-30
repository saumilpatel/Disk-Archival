%{
# table that holds the current domain name
booth : tinyint                              # booth number
domain : varchar(255)                        # domain name
-----
%}

classdef CurrentDomainName < dj.Manual
end