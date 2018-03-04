USING: 21-ng 21-ng.game kernel roles io ;
IN: 21-ng.bot

SINGLETON: computer 
INSTANCE: computer player

M: computer take-turn drop dup announcing-game? [ "computer wins!" print ] [ drop 2 ] if ;
