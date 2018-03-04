USING: 21-ng 21-ng.game io kernel math.parser roles ;
IN: 21-ng.human

SINGLETON: you
INSTANCE: you player

: read-you ( -- something )
    readln dup "q" = [ drop f ] when ;

: your-turn ( -- add )
    read-you [
        string>number dup addable? [ drop your-turn ] unless
    ] [ skip ] if* ;

M: you take-turn drop dup announcing-game? [ "you wins!" print ] [ drop your-turn ] if ;
