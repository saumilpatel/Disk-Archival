% add a server to database of storage servers
function addServer

tp = [] ;
done = false ;

while ~done
    tp.servername = input('Server Name [e.g. at-backupb1.stanford.edu in quotes] : ') ;

    cbuf = sprintf('Server name is %s, continue adding [0=Y/1=n] ? ', tp.servername) ;

    r = input(cbuf) ;

    if isempty(r) || r == 0
        insert(enigma_storage.Servers,tp) ;
        r = input('Add another server [0=Y/1=n] ? ') ;
        if r == 1
            done = true ;
        end
    end
end