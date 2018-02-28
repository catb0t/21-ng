USING: accessors arrays assocs classes classes.tuple combinators
combinators.short-circuit fry sequences.interleaved literals hashtables kernel
locals math sequences sequences.deep vectors ;
IN: 21-ng.game

CONSTANT: addables { 1 2 }
CONSTANT: known-inputs { "1" "2" "q" f }
CONSTANT: default-limits { { 3 4 } { 4 3 } }
CONSTANT: default-game-over 21

<PRIVATE
SINGLETONS: play announce skip ;
MIXIN: next,
INSTANCE: play next,
INSTANCE: announce next,
INSTANCE: skip next,

MIXIN: player
INSTANCE: f player
PRIVATE>

TUPLE: player-data
    { who     player initial: f read-only }
    { player# fixnum initial: 0 read-only }
    { turn#   fixnum initial: 1 }
    ! pointer slots
    { turns   vector initial: V{ } read-only }
    { limits  hashtable initial: H{ { 1 f } { 2 f } } read-only } ;

TUPLE: 21-game-state
    { playing-to  integer initial: $[ default-game-over ] read-only  }
    { current     integer initial: 0 }
    { next-time   next,   initial: play }
    ! pointer slot
    { players     hashtable initial: H{ } read-only } ;

PREDICATE: playing-game < 21-game-state
    next-time>> play? ;

PREDICATE: announcing-game < 21-game-state
    next-time>> announce? ;

PREDICATE: skipping-game < 21-game-state
    next-time>> skip? ;

PREDICATE: played-game < 21-game-state
    [ current>> ] [ playing-to>> ] bi >= ;

PREDICATE: addable < fixnum
    addables member? ;

PREDICATE: known-input < object
    known-inputs member? ;

PREDICATE: real-assoc < assoc
    [ f ] [ [ pair? ] all? ] if-empty ;

<PRIVATE
: (unique-clone) ( what -- new )
    [ class-of ] keep
    tuple-slots [ dup hashtable? [ >alist ] when ] map
    [ clone ] deep-map [ clone ] map
    [ dup real-assoc? [ >hashtable ] when ] map
    swap prefix >tuple ;

M: 21-game-state clone
    (unique-clone) ;

M: player-data clone
    (unique-clone) ;

: max-turns-needed ( n -- x )
    2 /i 1 + ;

: >index-hashtable ( array -- hash )
    addables swap zip >hashtable ;

: ?rest ( seq -- seq/f )
    [ f ] [ rest ] if-empty ;

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

: (inc-score) ( game who add -- )
    dup addable? [
        [| game who add |
            add game players>> who of
            ! change the player data here
            [ add-player-turn ]
            [ dec-player-limits ]
            [ nip inc-turn# ] 2tri
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
    [ [ default-game-over ] unless* ] [ [| obj p# |
        obj first2 :> ( who limits )
        who dup p# 1 + limits <player-data> 2array
    ] map-index >hashtable ] bi* <21-game-state> ;

: <21-game> ( playing-to players: assoc -- game-loop game-state )
    [ <easy-21-game-state> ] [ keys <21-game-loop> ] 2bi ;

GENERIC: take-turn ( game who: player -- add )

: do-player-turn ( game who -- game+ )
    2dup [ clone ] dip take-turn inc-score set-next-time ;

: do-game-iteration ( game-state who -- game-state )
    over skipping-game? [ drop ] [ do-player-turn ] if ;

: 21-loop ( game-state game-loop -- game-state )
    [ do-game-iteration ] each ;
