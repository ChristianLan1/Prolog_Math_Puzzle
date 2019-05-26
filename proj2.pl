:- use_module(library(clpfd)).
% Author: Xinjie Lan <xinjiel2@student.unimelb.edu.au> 910030
% Purpose: Solve maths puzzle which is a square grid of squares, 
%          each to be filled in with a single digit from 1 to 9.

% The Maths Puzzle has three constraints:
%    1 Each row and each column contains no repeated digits
%    2 All squares on the diagonal line from upper left to 
%      lower right contain the same value;
%    3 the heading of reach row and column (leftmost square 
%      in a row and topmost square in a column) holds either
%      the sum or the product of all the digits in that row or column
% When the puzzle is originally posed, most or all of the squares 
% will be empty, with the headings filled in. The goal of the puzzle 
% is to fill in all the squares according to the rules. A proper maths 
% puzzle will have at most one solution.






% This puzzle_solution/1 can be organized in four parts:
%    1. Ensure the puzzle is valid(Constraint 1 & 2) by checking 
%       1) Same length of each row
%       2) Check diagonal contains same elements
%       3) Contains distinct digits for each row except headings
%    2. Calculate constraint 3
%    3. Get columns and do the same thing as rows
%    4. Check filled squares solution 
puzzle_solution(Puzzle) :- 
    Puzzle = [[FirstH|_FirstT]|_PuzzleT],
    maplist(same_length(Puzzle),Puzzle),
    getOtherRows(Puzzle,NewPuzzle),
    getDiagonal(NewPuzzle,0,[FirstH|OhterTail]),
    checkDiagonalSame(OhterTail),

    checkRow(NewPuzzle),
    checkRowVal(NewPuzzle),

    transpose(Puzzle,Columns),
    getOtherRows(Columns,NewPuzzleC),
    checkRow(NewPuzzleC),
    checkRowVal(NewPuzzleC),

    groundRows(Puzzle).



% This predicate smilar as using maplist to filter out first row, 
% but this predicate is used at higher level and 
% to avoid changing the original Puzzle lists
getOtherRows([_H|ListsTail],RemainingRows) :-
    RemainingRows = ListsTail.

% This checkRow/1 gets all the rows except the first row
% Then pass these rows to predicate checkRowNum/1
checkRow([Row|Tails]) :-
    maplist(takeTail,[Row|Tails],New3),
    checkRowNum(New3).

% This predicate is used in maplist to filter out the first row   
takeTail([_L|MapListTail],MapListTail).

% This checkRowNum/1 recursively indicates rows are in the domain
% and to indicate they are distinct
checkRowNum([]).
checkRowNum([Row|Tails]) :-
    Row ins 1..9,
    checkRowNum(Tails),
    all_distinct(Row).



% This predicate/3 is used to get all the elements on the diagonal
% This is how it works:
%    Recursively gets nth element from nth list.
%    Using X as the "gloval variable" to count.
%    '#+' is used to bind count variable to incremental numbers.
%    Append these elements in a List called InitList.
% The first element of the first list which is 
% the left-top corner element is defined in the first place of the 
% appended list. 
getDiagonal([],_,[_]).
getDiagonal([FirstRow|OtherRow],InitVal,InitList) :-
    X #= InitVal+1,
    getDiagonal(OtherRow,X,NewList),
    nth0(X,FirstRow,DiaEle),
    append(NewList,[DiaEle],InitList).
    
% This predicate/2 is used for maplist
% Succeed if the current element is same as the head of the list
checkSame([ListHead|_ListTail],ListHead).

% This predicate/1 is to apply checkSame to every element of the list. 
checkDiagonalSame(OhterTail) :-
    maplist(checkSame(OhterTail),OhterTail).


    
% checkRowVal/1 takes Puzzle and recursively checks the arithmetic
% results one row after another by pattern matching.
% The pattern match has two cases:
%   1. If the sum of the row elements equals to head element.
%   2. If the product of the row elements equals to head element.
checkRowVal([]).
checkRowVal([RowHead|RowElements]) :-
    checkRowSum(RowHead),
    checkRowVal(RowElements).
checkRowVal([RowHead|RowElements]) :-
    checkRowProduct(RowHead),
    checkRowVal(RowElements).

% This checkRowSum/1 checks calls checkSum/3 to calculate Sum
% Succeed if the calculated sum equals to the Head element of the row. 
checkRowSum([]).
checkRowSum([FirstEleRow|FirstRowTail]) :-
    checkSum(FirstRowTail,0,Sum),
    Sum = FirstEleRow.
    
% This checkSum/3 calculates arithmetic sum of the elements of the list.
% This predicate used clpfd library and recursively passes
% the current summation value to the next calculation
checkSum([],Sum,Sum).
checkSum([EleH|EleT],X,Sum) :-
    Sum1 #= X + EleH,
    checkSum(EleT,Sum1,Sum).

% Similar to checkRowSum, but this predicate 
% checks product for each row.
checkRowProduct([]).
checkRowProduct([PH|PT]) :-
    checkProduct(PT,1,Product),
    Product = PH.

% Similar to checkSum, this predicate calculates product for each row  
checkProduct([],Product,Product).
checkProduct([RowH|RowT],Y,Product) :-
    Product1 #= RowH * Y,
    checkProduct(RowT,Product1,Product).



% This groudRows/1 takes a lists of list as Puzzle then 
% remove the heading row and pass the rest of rows to ground element. 
groundRows([_RowHead|RowTail]):-
    groundT(RowTail).

% This groundT/1 recursively checks if the current row is grounded.
% If not, bond the variables of the row using label.
groundT([]).
groundT([[RowFirstEle|RowOtherElements]|Tails1]) :-
    (ground([RowFirstEle|RowOtherElements]) ->
    groundT(Tails1)
    ;
    label([RowFirstEle|RowOtherElements]),
    groundT(Tails1)).

