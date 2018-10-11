int(0,+) :- !.
int(-1,-) :- !.
int(N1,[X|I]) :-
    divmod(N1,2,N2,X)
    , int(N2,I)
.

lsb_r(+,0).
lsb_r(-,1).

lsb_l([1|+],1,+).
lsb_l([0|-],0,-).
lsb_l([H|T],H,T) :- T = [_|_].

lsb(A,B,A) :- lsb_r(A,B).
lsb(A,B,C) :- lsb_l(A,B,C).

inc(-,+).
inc(+,[1|+]).
inc([0|-],-).
inc([0,D|T],[1,D|T]).
inc([1|T1],[0|T2]) :-
    inc(T1,T2)
.

flipD(0,1).
flipD(1,0).

invert(-,+).
invert(+,-).
invert([H1|T1],[H2|T2]) :-
    flipD(H1,H2)
    , invert(T1, T2)
.

minus(P,M) :-
    invert(P,I)
    , inc(I,M)
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
digit_check(1,N,N).

add(N1,N2,S) :-
    add(0,N1,N2,S)
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
add(C1,I1,I2,I3) :-
    lsb_r(I1,D1)
    , lsb_l(I2,D2,I4)
    , lsb(I3,D3,I5)
    , full_adder(C1,D1,D2,C2,D3)
    , add(C2,I1,I4,I5)
.
add(C1,I1,I2,I3) :-
    lsb_l(I1,D1,I4)
    , lsb_r(I2,D2)
    , lsb(I3,D3,I5)
    , full_adder(C1,D1,D2,C2,D3)
    , add(C2,I4,I2,I5)
.
add(C1,I1,I2,I3) :-
    lsb_l(I1,D1,I4)
    , lsb_l(I2,D2,I5)
    , lsb(I3,D3,I6)
    , full_adder(C1,D1,D2,C2,D3)
    , add(C2,I4,I5,I6)
.

multiply(+,_,Acc,Acc).
multiply(-,A,Acc,R) :-
    add(A,R,Acc)
.
multiply(A1,B1,Acc1,R) :-
    lsb_l(A1,D,A2)
    , lsb(B2,0,B1)
    , digit_check(D,B1,Inc)
    , add(Acc1,Inc,Acc2)
    , multiply(A2,B2,Acc2,R)
.

multiply(A,B,R) :-
    multiply(A,B,+,R)
.

le(Bool,X,X,Bool).
le(_,0,1,true).
le(_,1,0,false).

le(_,-,+).
le(true,+,+).
le(true,-,-).
le(A1,I1,I2) :-
    lsb_r(I1,D1)
    , lsb_l(I2,D2,I3)
    , le(A1,D1,D2,A2)
    , le(A2,I1,I3)
.
le(A1,I1,I2) :-
    lsb_l(I1,D1,I3)
    , lsb_r(I2,D2)
    , le(A1,D1,D2,A2)
    , le(A2,I3,I2)
.
le(A1,I1,I2) :-
    lsb_l(I1,D1,I3)
    , lsb_l(I2,D2,I4)
    , le(A1,D1,D2,A2)
    , le(A2,I3,I4)
.
le(A,B) :- le(true,A,B).

range(A:B,_) :- le(B,A), !, fail.
range(A:_,A).
range(A:B,I) :- inc(A,A2), range(A2:B,I).

sign(+,+).
sign(-,-).
sign([1|+],[1|+]).
sign([0|I],S) :- sign(I,S).
sign([1|I],S) :- I = [_|_], sign(I,S).
