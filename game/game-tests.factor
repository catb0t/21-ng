USING: 21-ng.game.private accessors assocs kernel tools.test ;
IN: 21-ng.game

{ t } [ f player? ] unit-test
{ f } [ tuple player? ] unit-test

{ t } [ 1 addable? ] unit-test
{ t } [ 2 addable? ] unit-test
{ f } [ "q" addable? ] unit-test
{ f } [ f addable? ] unit-test
{ t } [ "q" known-input? ] unit-test
{ t } [ f known-input? ] unit-test

{ 6 } [ 11 max-turns-needed ] unit-test
{ 11 } [ 21 max-turns-needed ] unit-test
{ 21 } [ 41 max-turns-needed ] unit-test

{ f } [ V{ } real-assoc? ] unit-test
{ f } [ { } real-assoc? ] unit-test
{ t } [ { { 1 2 } } real-assoc? ] unit-test
{ t } [ { { 1 2 } { 5 "g " } } real-assoc? ] unit-test
{ f } [ { 1 } real-assoc? ] unit-test
{ f } [ { f } real-assoc? ] unit-test

{ H{ { 1 2 } { 2 3 } } } [ { 2 3 } >index-hashtable ] unit-test
<PRIVATE SINGLETONS: you computer ;
INSTANCE: you player
INSTANCE: computer player PRIVATE>
{ 2 2 } [
    you 1 f <player-data> dup [ inc-turn# ] keep [ turn#>> ] bi@
] unit-test
{ 1 2 } [
    you 1 f <player-data> dup clone [ inc-turn# ] keep [ turn#>> ] bi@
] unit-test

{ 1 1 } [
    f { { you f } { computer f } } <easy-21-game-state>
    dup [ 1 inc-current ] keep [ current>> ] bi@
] unit-test

{ 0 1 } [
    f { { you f } { computer f } } <easy-21-game-state>
    dup clone [ 1 inc-current ] keep [ current>> ] bi@
] unit-test

{ V{ 1 } V{ 1 } } [
    you 1 f <player-data> dup [ 1 swap add-player-turn ] keep [ turns>> ] bi@
] unit-test
{ V{ } V{ 1 } } [
    you 1 f <player-data> dup clone [ 1 swap add-player-turn ] keep [ turns>> ] bi@
] unit-test

{ H{ { 1 4 } { 2 2 } } H{ { 1 4 } { 2 2 } } } [
    you 1 f <player-data> dup [ 2 swap dec-player-limits ] keep [ limits>> ] bi@
] unit-test
{ H{ { 1 4 } { 2 3 } } H{ { 1 4 } { 2 2 } } } [
    you 1 f <player-data> dup clone [ 2 swap dec-player-limits ] keep [ limits>> ] bi@
] unit-test

{ V{ 2 } H{ { 1 4 } { 2 2 } } 2 2 V{ 2 } H{ { 1 4 } { 2 2 } } 2 2 } [
    f { { you f } { computer f } } <easy-21-game-state> dup [ you 2 (inc-score) ] keep [
        [ players>> you of [ turns>> ] [ limits>> ] [ turn#>> ] tri ]
        [ current>> ] bi
    ] bi@
] unit-test

{ V{ } H{ { 1 4 } { 2 3 } } 1 0 V{ 2 } H{ { 1 4 } { 2 2 } } 2 2 } [
    f { { you f } { computer f } } <easy-21-game-state> dup clone [ you 2 (inc-score) ] keep [
        [ players>> you of [ turns>> ] [ limits>> ] [ turn#>> ] tri ]
        [ current>> ] bi
    ] bi@
] unit-test
