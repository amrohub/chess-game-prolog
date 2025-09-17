one_step(Field,Direction,Next,Color,Position):-	
	Next is Field + Direction,
	not(invalid_field(Next)),
	not(occupied(Next,Color,Position)).
	
multiple_steps(Field,Direction,Next,Color,Position):-
	one_step(Field,Direction,Next,Color,Position).
	
multiple_steps(Field,Direction,Next,Color,Position):-
	one_step(Field,Direction,FieldNew,Color,Position),
	invert(Color,Oppo),
	get_half(Position,HalfOppo,Oppo),
	not(exist(FieldNew,HalfOppo,_)),
	multiple_steps(FieldNew,Direction,Next,Color,Position).
	
get_half(position(Half,_,_),Half,white).

get_half(position(_,Half,_),Half,black).

update_half(position(_,Y,Z),Half,white,position(Half,Y,Z)).

update_half(position(X,_,Z),Half,black,position(X,Half,Z)).

occupied(Field,white,position(Stones,_,_)):- exist(Field,Stones,_).	

occupied(Field,black,position(_,Stones,_)):- exist(Field,Stones,_).	

unoccupied(Field,Position):-
	not(occupied(Field,white,Position)),
	not(occupied(Field,black,Position)),
	not(invalid_field(Field)).

% Create rooks.
pos_move(rook, 10).
pos_move(rook, -10).
pos_move(rook, 1).
pos_move(rook, -1).

% Create Bishops.
pos_move(bishop, 9).
pos_move(bishop, 11).
pos_move(bishop, -9).
pos_move(bishop, -11).

% Create Knights.
pos_move(knight, 19).
pos_move(knight, 21).
pos_move(knight, 8).
pos_move(knight, 12).
pos_move(knight, -8).
pos_move(knight, -12).
pos_move(knight, -19).
pos_move(knight, -21).

pos_move(queen,X):-
	pos_move(rook,X).
	
pos_move(queen,X):-
	pos_move(bishop,X).
	
pos_move(king,X):-
	pos_move(queen,X).
		
pawn_move(From,white,Position,To):-
	To  is  From + 9,
	occupied(To,black,Position).
	
pawn_move(From,white,Position,To):-
	To  is  From + 10,
	unoccupied(To,Position).
	
pawn_move(From,white,Position,To):-
	To  is  From + 11,
	occupied(To,black,Position).
	
pawn_move(From,white,Position,To):-
	To  is  From + 20,
	Over  is  From + 10,
	unoccupied(To,Position),
	unoccupied(Over,Position),
	Row  is  From // 10,
	Row = 2.
	
pawn_move(From,black,Position,To):-
	To  is  From - 9,
	occupied(To,white,Position).
	
pawn_move(From,black,Position,To):-
	To  is  From - 10,
	unoccupied(To,Position).
	
pawn_move(From,black,Position,To):-
	To  is  From - 11,
	occupied(To,white,Position).
	
pawn_move(From,black,Position,To):-
	To  is  From - 20,
	Over  is  From - 10,
	unoccupied(To,Position),
	unoccupied(Over,Position),
	Row  is  From // 10,
	Row = 7.

% Short castling.
castling_move(Color,Position,King,To):-
	(
		Color = white, 
		King = 15
		;
		Color = black,
		King = 85
	),
	RookNew is King+1,
	To is King+2,
	Rook is King+3,
	get_half(Position,half_position(_,Rookies,_,_,_,_,_),Color),
	member(Rook,Rookies),
	unoccupied(RookNew,Position),
	unoccupied(To,Position).

% Long castling.
castling_move(Color,Position,King,To):-
	(
		Color = white, 
		King = 15
		;
		Color = black,
		King = 85
	),
	RookNew is King-1,
	To is King-2,
	Blank is King-3,
	Rook is King-5,
	get_half(Position,half_position(_,Rookies,_,_,_,_,_),Color),
	member(Rook,Rookies),
	unoccupied(RookNew,Position),
	unoccupied(To,Position),
	unoccupied(Blank,Position).

long_move(From,Color,Typ,Position,To):-
	pos_move(Typ,Direction),
	multiple_steps(From,Direction,To,Color,Position).
	
short_move(From,Color,Typ,Position,To):-
	pos_move(Typ,Direction),
	one_step(From,Direction,To,Color,Position).

all_moves(Color,Position,move(From,To)):-
	get_half(Position,half_position(Pawn,_,_,_,_,_,_),Color),
	member(From,Pawn),		
	pawn_move(From,Color,Position,To).
	
all_moves(Color,Position,move(From,To)):-
	get_half(Position,half_position(_,Rookies,_,_,_,_,_),Color),
	member(From,Rookies), 	
	long_move(From,Color,rook,Position,To).
	
all_moves(Color,Position,move(From,To)):-
	get_half(Position,half_position(_,_,Knights,_,_,_,_),Color),
	member(From,Knights),	
	short_move(From,Color,knight,Position,To).
	
all_moves(Color,Position,move(From,To)):-
	get_half(Position,half_position(_,_,_,Bishies,_,_,_),Color),
	member(From,Bishies),	
	long_move(From,Color,bishop,Position,To).
	
all_moves(Color,Position,move(From,To)):-
	get_half(Position,half_position(_,_,_,_,Queenies,_,_),Color),
	member(From,Queenies),	
	long_move(From,Color,queen,Position,To).
	
all_moves(Color,Position,move(King,To)):-
	get_half(Position,half_position(_,_,_,_,_,[King],_),Color),
	short_move(King,Color,king,Position,To).
	
all_moves(Color,Position,move(King,To)):-
	get_half(Position,half_position(_,_,_,_,_,[King],_),Color),
	castling_move(Color,Position,King,To).

move_gen_test:-
	PawnWhite = [21,22,23,24,25,26,27,28],
	PawnBlack = [71,72,73,74,75,76,77,78],
	H1 = half_position(PawnWhite,[11,18],[12,17],[13,16],[14],[15],notmoved),
	H2 = half_position(PawnBlack,[81,88],[82,87],[83,86],[84],[85],notmoved),
	Position = position(H1,H2,0),
	all_moves(white,Position,Move),
	write(Move),nl,
	fail.