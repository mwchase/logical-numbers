% There's no module declaration yet
% because I want to avoid functional
% changes for as long as I can.

/** <module> Arbitary-precision integers

This module provides predicates to create
and manipulate term-based representations
of integers.

@author Max Chase
@license MIT
*/

:- use_module(library(plunit)).

%! int(++Number:int, -LogicalNumber)
% Unify LogicalNumber with the term
% value equivalent to Number.

int(0,+) :- !.
int(-1,-) :- !.
int(Number1,[Digit|Tail]) :-
    divmod(Number1,2,Number2,Digit)
    , int(Number2,Tail)
.

:- begin_tests(int_doc).

    %! test(pos)
    % A positive number is encoded as a
    % little-endian sequence of bits,
    % which ends with [1|+].

    test(pos) :- int(10, X), X == [0,1,0,1|+].

    %! test(neg)
    % A negative number besides -1 is
    % encoded as a little-endian
    % sequence of bits, which ends with
    % [0|-].

    test(neg) :- int(-7, X), X == [1, 0, 0|-].

:- end_tests(int_doc).

lsb_r(+,0).
lsb_r(-,1).

lsb_l([1|+],1,+).
lsb_l([0|-],0,-).
lsb_l([H|T],H,T) :- T = [_|_].

lsb(A,B,A) :- lsb_r(A,B).
lsb(A,B,C) :- lsb_l(A,B,C).

%! inc(?ToIncrement, ?Incremented)
% Incremented is the term value one more
% than ToIncrement. This predicate can
% also decrement.

inc(-,+).
inc(+,[1|+]).
inc([0|-],-).
inc([0,Digit|Tail],[1,Digit|Tail]).
inc([1|Tail1],[0|Tail2]) :-
    inc(Tail1,Tail2)
.

:- begin_tests(inc_doc).

    %! test(round_trip)
    % As long as there's a ground term,
    % inc works right.

    test(round_trip) :-
        int(5, Value)
        , inc(Value, Six)
        , inc(Five, Six)
        , Five == Value
    .

:- end_tests(inc_doc).

flipD(0,1).
flipD(1,0).

invert(-,+).
invert(+,-).
invert([Digit1|Tail1],[Digit2|Tail2]) :-
    flipD(Digit1,Digit2)
    , invert(Tail1, Tail2)
.

minus(Left,Right) :-
    invert(Left,Inverted)
    , inc(Inverted,Right)
.

full_adder(0,0,0,0,0).
full_adder(0,0,1,0,1).
full_adder(0,1,0,0,1).
full_adder(0,1,1,1,0).
full_adder(1,0,0,0,1).
full_adder(1,0,1,1,0).
full_adder(1,1,0,1,0).
full_adder(1,1,1,1,1).

digit_check(0,_,+).
digit_check(1,Number,Number).

%! add(+Augend, +Addend, -Sum)
%! add(+Subtrahend, -Difference, +Minuend)
%! add(-Difference, +Subtrahend, +Minuend)
% Given two ground terms, find their sum
% or difference.

add(NumberL,NumberR,Sum) :-
    add(0,NumberL,NumberR,Sum)
    , !
.

add(0,+,+,+).
add(1,+,+,[1|+]).
add(0,-,+,-).
add(1,-,+,+).
add(0,+,-,-).
add(1,+,-,+).
add(0,-,-,[0|-]).
add(1,-,-,-).
add(Carry1,NumberL1,NumberR1,Sum1) :-
    lsb_r(NumberL1,DigitL)
    , lsb_l(NumberR1,DigitR,NumberR2)
    , lsb(Sum1,DigitS,Sum2)
    , full_adder(Carry1,DigitL,DigitR,Carry2,DigitS)
    , add(Carry2,NumberL1,NumberR2,Sum2)
.
add(Carry1,NumberL1,NumberR1,Sum1) :-
    lsb_l(NumberL1,DigitL,NumberL2)
    , lsb_r(NumberR1,DigitR)
    , lsb(Sum1,DigitS,Sum2)
    , full_adder(Carry1,DigitL,DigitR,Carry2,DigitS)
    , add(Carry2,NumberL2,NumberR1,Sum2)
.
add(Carry1,NumberL1,NumberR1,Sum1) :-
    lsb_l(NumberL1,DigitL,NumberL2)
    , lsb_l(NumberR1,DigitR,NumberR2)
    , lsb(Sum1,DigitS,Sum2)
    , full_adder(Carry1,DigitL,DigitR,Carry2,DigitS)
    , add(Carry2,NumberL2,NumberR2,Sum2)
.

%! multiply(+Multiplier, +Multiplicand, -Product)
% Given factors, find the product.
% It would be nice if this worked the
% other way around, but currently it
% mostly doesn't.

multiply(Left,Right,Product) :-
    multiply(Left,Right,+,Product)
.

multiply(+,_,Acc,Acc).
multiply(-,Right,Acc,Product) :-
    add(Right,Product,Acc)
.
multiply(Left1,Right1,Acc1,Product) :-
    lsb_l(Left1,Digit,Left2)
    , lsb(Right2,0,Right1)
    , digit_check(Digit,Right1,Inc)
    , add(Acc1,Inc,Acc2)
    , multiply(Left2,Right2,Acc2,Product)
.

%! le(+LessThanOrEqual, +GreaterThanOrEqual)
% Succeed if the first argument is less
% than or equal to the second.

le(Low,High) :- le(true,Low,High).

le(Result,Equal,Equal,Result).
le(_,0,1,true).
le(_,1,0,false).

le(_,-,+).
le(true,+,+).
le(true,-,-).
le(Result1,Low1,High1) :-
    lsb_r(Low1,Digit1)
    , lsb_l(High1,Digit2,High2)
    , le(Result1,Digit1,Digit2,Result2)
    , le(Result2,Low1,High2)
.
le(Result1,Low1,High1) :-
    lsb_l(Low1,Digit1,Low2)
    , lsb_r(High1,Digit2)
    , le(Result1,Digit1,Digit2,Result2)
    , le(Result2,Low2,High1)
.
le(Result1,Low1,High1) :-
    lsb_l(Low1,Digit1,Low2)
    , lsb_l(High1,Digit2,High2)
    , le(Result1,Digit1,Digit2,Result2)
    , le(Result2,Low2,High2)
.

%! range(+Start:End, -Value)
% Unify Value with the integer terms in
% the range [Start, End), if any, in
% ascending order.

range(Start:End,_) :- le(End,Start), !, fail.
range(Start:_,Start).
range(Start1:End,Value) :-
    inc(Start1,Start2)
    , range(Start2:End,Value)
.

%! sign(+Number, -Sign)
% Map negative numbers to -1, zero to 0,
% and positive numbers to 1.

sign(+,+).
sign(-,-).
sign([1|+],[1|+]).
sign([0|Tail],Sign) :- sign(Tail,Sign).
sign([1|Tail],Sign) :- Tail = [_|_], sign(Tail,Sign).
