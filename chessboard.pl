:- [utils].	
:- [pieces].
:- [evaluator].

newdepth(_Depth, hit, NewDepth) :-
	top(X),
	X < 4,
	NewDepth = 1,!.
	
newdepth(Depth, _, NewDepth) :-
	NewDepth is Depth-1,!.	

get_best(Position, Color, Depth, Alpha, Beta) :-
	invert(Color, Op),
	generate(Move, Color, Position, New_Position, Hit),
	newdepth(Depth, Hit, New_Depth),
	new_alpha_beta(Color, Alpha, New_Alpha, Beta, New_Beta),
	evaluate(New_Position, Op, Value,_, New_Depth, New_Alpha, New_Beta),
	compare_move(Move, Value, Color),
	cutting(Value, Color, Alpha, Beta),
	!,fail.
	
new_alpha_beta(white, Alpha, New_Alpha, Beta, Beta) :-
	get_0(_,Value),
	Value > Alpha,
	New_Alpha = Value,!.
	
new_alpha_beta(black, Alpha, Alpha, Beta, New_Beta) :-
	get_0(_, Value),
	Value < Beta,
	New_Beta = Value,!.
	
new_alpha_beta(_, Alpha, Alpha, Beta, Beta).
	
compare_move(_, Value, white) :-
	get_0(_, Old),
	Old >= Value,!.
	
compare_move(_, Value, black) :-
	get_0(_, Old),
	Old =< Value,!.
	
compare_move(Move, Value, _) :-
	replace(Move, Value).

cutting(Value, white, _, Beta) :-
	Beta < Value.
cutting(Value, black, Alpha, _) :-
	Alpha > Value.

evaluate(position(half_position(_,_,_,_,_,[],_),_,_) ,_,Value, move(0,0),_,_,_) :-
	winning(black, Value),!.
	
evaluate(position(_, half_position(_,_,_,_,_,[],_),_) ,_,Value, move(0,0),_,_,_) :-
	winning(white, Value),!.
	
evaluate(position(W, B, _), Color, Value, move(0,0),0,_,_) :-
	count_halfst(W, white, X),
	count_halfst(B, black, Y),
	compensate(Color, Z),
	Value is X-Y+Z,!.
	
evaluate(Position, Color, Value, Move, Depth, Alpha, Beta) :-
	worst_value(Color, Worst),
	push(move(0,0), Worst),
	not(get_best(Position, Color, Depth, Alpha, Beta)),
	pull(Move, Value),!.
	
enter(Position, Color, Move) :-
	human(Color),
	repeat,
	read_move(Move, Color),
	(	
		check_legal(Move, Color, Position),
		nl,!
	;
		write('An Illegal Move!'),
		nl,fail
	).
	
enter(Position, Color, Move) :-	
	depth(Depth),!,
	repeat,
	worst_value(white, Alpha),
	worst_value(black, Beta),
	evaluate(Position, Color, _Value, Move, Depth, Alpha, Beta),
	write_move(Move, Color),!,
	read_move(Move, Color),
	(	
		check_legal(Move, Color, Position),
		nl,!
	;
		write('An Illegal Move!'),
		nl,fail
	).
	
play(BasicPosition, Start) :-
	asserta(board(BasicPosition, Start)),    
	nl,
	draw_board(BasicPosition),
	write('Enter moves like <f2f4.>'),nl,
	write('Enter <exit.> to quit'),nl,
	nl,
	repeat,
	retract(board(Position, Color)),         
	( 
		are_kings_alive(Position) ->
		enter(Position, Color, Move),
		make_move(Color, Position, Move, New, _),
		draw_board(New),
		invert(Color, Op),
		asserta(board(New, Op)),               
		fail
	;
		write_winner(Position),
		!, fail
	).
play(_,_).

king_alive(half_position(_,_,_,_,_,K,_)) :-
	length(K, 1).

write_winner(Position) :-
	write('GAME ENDED'), nl,
	winner(Position, Winner),
	write(Winner), write(' wins'), nl.

are_kings_alive(position(W, B, _)) :-
	king_alive(W),
	king_alive(B).

winner(position(W, _, _), white) :- king_alive(W).
winner(position(_, B, _), black) :- king_alive(B).
	
change(Old, Color, From, To, New):-
	get_half(Old, Half, Color),
	exist(From, Half, Type),
	extract(Half, Type, List),
	remove(From, List, Templist),
	combine(Half, Type, [To|Templist], Newhalf),
	update_half(Old, Newhalf, Color, New).

kill(Old, Color, Field, New):- 
	get_half(Old, Half, Color),
	exist(Field, Half, Type),
	extract(Half, Type, List),
	remove(Field, List, Newlist),
	combine(Half, Type, Newlist, Newhalf),
	update_half(Old, Newhalf, Color, New).
	
extract(half_position(X,_,_,_,_,_,_), pawn, X).
extract(half_position(_,X,_,_,_,_,_), rook, X).
extract(half_position(_,_,X,_,_,_,_), knight, X).
extract(half_position(_,_,_,X,_,_,_), bishop, X).
extract(half_position(_,_,_,_,X,_,_), queen, X).
extract(half_position(_,_,_,_,_,X,_), king, X).

combine(half_position(_,B,C,D,E,F,G), pawn, N, half_position(N,B,C,D,E,F,G)).
combine(half_position(A,_,C,D,E,F,G), rook, N, half_position(A,N,C,D,E,F,G)).
combine(half_position(A,B,_,D,E,F,G), knight, N, half_position(A,B,N,D,E,F,G)).
combine(half_position(A,B,C,_,E,F,G), bishop, N, half_position(A,B,C,N,E,F,G)).
combine(half_position(A,B,C,D,_,F,G), queen, N, half_position(A,B,C,D,N,F,G)).
combine(half_position(A,B,C,D,E,_,G), king, N, half_position(A,B,C,D,E,N,G)).
	
check_00(Old, white, 15, 17, New) :-
	Old = position(half_position(_,_,_,_,_,[15],_),_,_),
	change(Old, white, 18, 16, New),!.
	
check_00(Old, white, 15, 13, New) :-
	Old = position(half_position(_,_,_,_,_,[15],_),_,_),
	change(Old, white, 11, 14, New),!.
	
check_00(Old, black, 85, 87, New) :-
	Old = position(_,half_position(_,_,_,_,_,[85],_),_),
	change(Old, black, 88, 86, New),!.
	
check_00(Old, black, 85, 83, New) :-
	Old = position(_,half_position(_,_,_,_,_,[85],_),_),
	change(Old, black, 81, 84, New),!.
	
check_00(Old,_,_,_,Old).

make_move(Color, Old, move(From, To), New, hit):-
	invert(Color, Oppo),
	kill(Old, Oppo, To, Temp),
	change(Temp, Color, From, To, New),!.
	
make_move(Color, Old, move(From, To), New, nohit):-
	check_00(Old, Color, From, To, Temp),
	change(Temp, Color, From, To, New),!.

check_legal(Move, Color, Position):-
	generate(PosMove, Color, Position, _, _),
	Move = PosMove,!.

generate(Move, Color, Old, New, Hit):-
	all_moves(Color, Old, Move),
	make_move(Color, Old, Move, New, Hit).

read_move(move(From, To), _):-
	repeat,
	% write("Your move: <"),write(Color),write("> "),
	write("Your move: "),
	read(Input),
	(
	  	Input = 'exit',
	  	halt
	;
	    name(Input,[A,B,C,D]),	% name("d2d4",[100, 50, 100, 52]) ascii:50-2,52-4,100-d
	  	str_pos([A, B], From),
	  	str_pos([C, D], To),!
	;
	  	write('Wrong format ( please enter like <a1b2.> '),nl,
	  	fail
	).

str_pos([L, C], Pos):-
	nonvar(Pos),	% Pos known
	pos_no(Row, Col, Pos),
	L is Col + 96,	% int to char
	C is Row + 48,!.
	
str_pos([L, C], Pos):-
	Col is L - 96,	% char to int
	Row is C - 48,
	pos_no(Row, Col, Pos),!.

pos_no(Row, Col, N):-
	nonvar(N),!,
	Row is N // 10,
	Col is N mod 10.
pos_no(R, C, N):-
	N  is  R*10 + C.

write_move(move(From, To), _):-
	str_pos([A, B], From),
	str_pos([C, D], To),
	name(Move, [A, B, C, D]),
	write("Best move suited for you: "),
	write(Move), nl, nl,!.
	
draw_board(Position):-
	Position = position(H1, H2, _),
	generate_board(Board),
	place_pieces(white, H1, Board, Board1),
	place_pieces(black, H2, Board1, BoardNew),
	write_board(BoardNew).
	
write_board([R1,R2,R3,R4,R5,R6,R7,R8]):-
	write("8"), write(R8),nl,
	write("7"), write(R7),nl,
	write("6"), write(R6),nl,
	write("5"), write(R5),nl,
	write("4"), write(R4),nl,
	write("3"), write(R3),nl,
	write("2"), write(R2),nl,
	write("1"), write(R1),nl,
	write(" [-a-,-b-,-c-,-d-,-e-,-f-,-g-,-h-]"),nl,nl.
	
% Generate blank board.	
generate_board([['   ','   ','   ','   ','   ','   ','   ','   '],
				['---','---','---','---','---','---','---','---'],
				['---','---','---','---','---','---','---','---'],
				['---','---','---','---','---','---','---','---'],
				['---','---','---','---','---','---','---','---'],
				['---','---','---','---','---','---','---','---'],
				['---','---','---','---','---','---','---','---'],
				['   ','   ','   ','   ','   ','   ','   ','   ']]).
				
% Display black pieces on board.
place_pieces(black, Half, Board, BoardNew):-
	Half = half_position(Pawn, Rook, Knight, Bishop, Queen, King,_),
	place_piece(' \u265F', Pawn, Board, Board1),
	place_piece(' \u265C', Rook, Board1, Board2),
	place_piece(' \u265E', Knight, Board2, Board3),
	place_piece(' \u265D', Bishop, Board3, Board4),
	place_piece(' \u265B', Queen, Board4, Board5),
	place_piece(' \u265A', King, Board5, BoardNew),!.
	
% Display white pieces on board.
place_pieces(white, Half, Board, BoardNew):-
	Half = half_position(Pawn, Rook, Knight, Bishop, Queen, King, _),
	place_piece(' \u2659', Pawn, Board, Board1),
	place_piece(' \u2656', Rook, Board1, Board2),
	place_piece(' \u2658', Knight, Board2, Board3),
	place_piece(' \u2657', Bishop, Board3, Board4),
	place_piece(' \u2655', Queen, Board4, Board5),
	place_piece(' \u2654', King, Board5, BoardNew),!.

place_piece(_, [], Board, Board).
place_piece(Str, [Field|Fs], Board, BoardNew):-
	pos_no(Row, Col, Field),
	nth1(Row, Board, List),
	replace(List, Col, Str, ListNew),
	replace(Board, Row, ListNew, Board1),
	place_piece(Str, Fs, Board1, BoardNew).

replace([_|T], 1, X, [X|T]).
replace([H|T], I, X, [H|R]):- I > 1, NI is I-1, replace(T, NI, X, R), !.
replace(L, _, _, L).

write_info:-
write('Chess is a board game that has been played for centuries and is known as the ultimate battle of wits. It involves two armies engaging in a strategic and volatile battle on the board. As one of the oldest and most respected games in history, chess has always been a competitive arena for players looking to outsmart their opponents.'),nl,
write('Enter "play." to continue'),nl,
write('***********************************************************************************************************************************************').

who_vs_who:-
	write('Human(W) vs Human(B)           ( 1 )'),nl,
	write('Human(W) vs Human(B) With AI-based Advice ( 2 )'),nl,
	get_vs(I),
	save_color(I).

get_vs(I):-
	get(CI),	
	I is CI - 48,
	I > 0,I < 5,!.
get_vs(I):- get_vs(I).

save_color(1):- asserta(human(white)), assertz(human(black)),!.		
save_color(2):- asserta(human(white)),!.
	

initial_pos(position(H1,H2,0)):-
	PawnWhite = [21,22,23,24,25,26,27,28],
	H1 = half_position(PawnWhite, [11,18], [12,17], [13,16], [14], [15], notmoved),
	PawnBlack = [71,72,73,74,75,76,77,78],
	H2 = half_position(PawnBlack, [81,88], [82,87], [83,86], [84], [85], notmoved).

run:-
write_info.

play:-
	retractall(stack(_,_,_)),
	retractall(top(_)),
	retractall(human(_)),
	retractall(depth(_)),
	retractall(board(_,_)),

	initial_pos(Position),
	asserta(depth(2)),
	init_stack,
	who_vs_who,
	play(Position,black),	
	closechessboard.	