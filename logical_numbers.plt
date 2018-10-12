:- begin_tests(logical_numbers).

:- include(logical_numbers).

test(double_by_adding) :-
    int(2, Two)
    , int(5, Value)
    , add(Value, Value, Added)
    , multiply(Two, Value, Multiplied)
    , Added == Multiplied
.

:- end_tests(logical_numbers).
