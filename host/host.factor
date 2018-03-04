USING: 21-ng 21-ng.game accessors calendar
concurrency.semaphores kernel json.writer io io.encodings.utf8 io.servers io.sockets
prettyprint namespaces ;
IN: 21-ng.host

SINGLETONS: player1 player2 ;
INSTANCE: player1 player
INSTANCE: player2 player

SYMBOL: serving-request
f serving-request set-global

: do-handle ( server -- )
    t serving-request set-global
    drop readln print
    f serving-request set-global ;


TUPLE: 21-game-server < threaded-server ;
M: 21-game-server handle-client*
    serving-request get-global t? [ drop ] [ drop  ] if ;

: <simple-21-server> ( -- server )
    utf8 21-game-server new-threaded-server
    f 4440 <inet> >>insecure
    1 >>max-connections
    15 minutes >>timeout ;
