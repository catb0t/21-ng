USING: 21-ng 21-ng.game accessors formatting kernel roles io ;
IN: 21-ng.bot

ROLE-TUPLE: computer < player ;

M: computer take-turn
    swap announcing-game? [
        name>> "%s wins!\n" printf skip
    ] [
        drop 2
    ] if ;
