USING: accessors arrays assocs classes classes.tuple hashtables
kernel literals math sequences sequences.deep strings vectors roles ;
IN: 21-ng

CONSTANT: addables { 1 2 }
CONSTANT: default-limits { { 3 4 } { 4 3 } }
<< CONSTANT: default-game-over 21 >>

SINGLETONS: play announce skip ;
MIXIN: next,
INSTANCE: play next,
INSTANCE: announce next,
INSTANCE: skip next,

MIXIN: player
INSTANCE: f player

TUPLE: player-data
    { who     player initial: T{ default-player } read-only }
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

PREDICATE: real-assoc < assoc
    [ f ] [ [ pair? ] all? ] if-empty ;

<PRIVATE
: (unique-clone) ( what -- new )
    [ class-of ] keep
    tuple-slots [ dup hashtable? [ >alist ] when ] map
    [ clone ] deep-map [ clone ] map
    [ dup real-assoc? [ >hashtable ] when ] map
    swap prefix >tuple ;

M: 21-game-state clone (unique-clone) ;

M: player-data clone (unique-clone) ;
: max-turns-needed ( n -- x )
    default-game-over or 2 /i 1 + ;
PRIVATE>

