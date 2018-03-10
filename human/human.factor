USING: 21-ng 21-ng.game accessors formatting io kernel math.parser roles locals ;
IN: 21-ng.human

CONSTANT: your-prompt "Add 1 or 2? "

ROLE-TUPLE: you < player ;
: read-you ( -- something )
    readln dup "q" = [ drop f ] when ;

:: your-turn ( you -- add )
    your-prompt write
    read-you [
        string>number dup addable? [ drop you your-turn ] unless
        dup you name>> swap "\t<%s> says: %s\n" printf
    ] [ skip ] if* ;

M: you take-turn
    swap announcing-game? [
        name>> "%s wins!\n" printf skip
    ] [
        your-turn
    ] if ;
