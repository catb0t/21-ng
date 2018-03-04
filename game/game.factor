USING: 21-ng 21-ng.private accessors arrays assocs classes
classes.tuple combinators combinators.short-circuit fry
hashtables kernel literals locals math sequences sequences.deep
sequences.interleaved vectors ;
IN: 21-ng.game

<PRIVATE
: >index-hashtable ( array -- hash )
    addables swap zip >hashtable ;

: play-next-time     ( game -- game )     skip >>next-time ;
: announce-next-time ( game -- game ) announce >>next-time ;
: skip-next-time     ( game -- game )     skip >>next-time ;

GENERIC: set-next-time ( game -- game' )

M: played-game     set-next-time announce-next-time ;
M: announcing-game set-next-time skip-next-time ;
M: playing-game    set-next-time ;
M: skipping-game   set-next-time ;

: inc-turn# ( player-data -- )
    [ 1 + ] change-turn# drop ;

: inc-current ( game add -- )
    '[ _ + ] change-current drop ;

: add-player-turn ( played player -- )
    turns>> push ;

: dec-player-limits ( played player -- )
    limits>> [ dup [ 1 - ] when ] change-at ;

: check-limits ( played player -- ? )
    limits>> at 0 > ;

: get-player-data ( game who -- player-data )
    [ players>> ] dip of ;

: (inc-score) ( game who add -- )
    { [ pick playing-game? ] [ addable? ] } 1&& [
        [| game who add |
            add game who get-player-data 2dup check-limits [
                ! change the player data here
                [ add-player-turn ]
                [ dec-player-limits ]
                [ nip inc-turn# ] 2tri
            ] [ 2drop ] if
        ] [
            ! change the game data here
            nip inc-current
        ] 3bi
    ] [ 3drop ] if ;

: inc-score ( game who add -- game+ )
    dup skip? [ 2drop skip-next-time ] [ pick [ (inc-score) ] dip ] if ;
PRIVATE>

: <player-data> ( who player# limits/f -- player-data )
    [ 1 V{ } clone ] dip [
        default-limits second
    ] unless* >index-hashtable player-data boa ;

: <21-game-state> ( playing-to player-datas: hashtable -- game-state )
    [ 0 play ] dip 21-game-state boa ;

: <21-game-loop> ( playing-to players: pair -- game-iter: sequence )
    [ max-turns-needed ] [ first2 ] bi* [ <repetition> ] dip <interleaved> ;
    ! [ max-turns-needed ] dip <repetition> ;

: <easy-21-game-state> ( playing-to players: assoc -- game-state )
    [ default-game-over or ] [ [| obj p# |
        obj first2 :> ( who limits )
        who dup p# 1 + limits <player-data> 2array
    ] map-index >hashtable ] bi* <21-game-state> ;

: <21-game> ( playing-to players: assoc -- game-loop game-state )
    [ <easy-21-game-state> ] [ keys <21-game-loop> ] 2bi ;

GENERIC: take-turn ( game who: player -- add )

<PRIVATE
: do-player-turn ( game who -- game+ )
    2dup [ clone ] dip take-turn inc-score set-next-time ;
PRIVATE>

! real iterators

: do-game-iteration ( game-state who -- game-state+ )
    over skipping-game? [ drop ] [ do-player-turn ] if ;

: rec-game-iteration ( game-state game-loop --  game-state+ game-loop-1 )
    { [ over skipping-game? ] [ empty? ] } 1|| [ drop f ] [
        [ first do-player-turn drop ] [ rest ] 2bi
    ] if ;

: rec-21-once ( game-state game-loop -- game-state+ game-loop-1 )
    [ f ] [ rec-game-iteration ] if-empty ; ! then you call rec-21-once again

: 21-loop ( game-state game-loop -- game-state+ )
    [ do-game-iteration ] each ;

: rec-21-loop ( game-state game-loop -- game-state+ )
    [ ] [ rec-game-iteration rec-21-loop ] if-empty ;
