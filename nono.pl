/* remplir_ligne(+Ligne, +Contraintes)
 * Remplit la liste Liste avec n ou b (noir or blanc) en respectant les
 * contraintes Contraintes. La liste Ligne doit être créée auparavant.
 * La liste de contraintes est une liste contenant les nombres de cases noirs
 * contigües.
 * Exemple :
 * length(L,5), remplir_ligne(L,[2,1]).
 * L = [b, n, n, b, n] ;
 * L = [n, n, b, b, n] ;
 * L = [n, n, b, n, b] ;
 * false. */
remplir_ligne([], []).
remplir_ligne([], [0]).
remplir_ligne([b|Ligne], []) :-
	remplir_ligne(Ligne, []).
remplir_ligne([b|Ligne], [0|T]) :-
	remplir_ligne(Ligne, T).
remplir_ligne([b|Ligne], [X|T]) :-
	X>0,
	length(Ligne,N),
	X=<N,
	remplir_ligne(Ligne, [X|T]).
remplir_ligne(Ligne, [X|T]) :-
	X>0,
	repeter(n, X, Liste),
	append(Liste, Reste, Ligne),
	remplir_ligne(Reste, [0|T]).

repeter(_, 0, []).
repeter(Elem, Taille, [Elem|Liste]) :-
	Taille>0,
	NewTaille is Taille-1,
	repeter(Elem, NewTaille, Liste).

creer_matrice(NLignes, NCol, Lignes, Cols) :-
	creer_lignes(NLignes, NCol, Lignes),
	transposer(Lignes, Cols).

creer_lignes(NLignes, NCol, Lignes) :-
	length(Lignes, NLignes),
	CreerNCols =.. [creer_ligne, NCol],
	maplist(CreerNCols, Lignes).

creer_ligne(NCol, Ligne) :-
	length(Ligne, NCol).

transposer([H|T], Transposee) :-
	length(H, NCols),
	repeter([], NCols, Cols),
	transposer([H|T], Cols, Transposee).

transposer([], Cols, Cols).
transposer([H|T], Cols, Res) :-
	transposer(T, Cols, Cols1),
	maplist(ajouter_debut, Cols1, H, Res).

ajouter_debut(Liste, H, [H|Liste]).

nonogramme(NLignes, NCols, ContLignes, ContCols, Lignes) :-
	creer_matrice(NLignes, NCols, Lignes, Cols),
	former_liste_contraintes(ContLignes, ContCols, Contraintes),
	appliquer_contraintes(Contraintes, Lignes, Cols).

former_liste_contraintes(ContLignes, ContCols, Contraintes) :-
	ajouter_contraintes([], ContLignes, 1,  l, Contraintes1),
	ajouter_contraintes(Contraintes1, ContCols, 1, c, Contraintes2),
	sort(2, @>=, Contraintes2, Contraintes3),
	select_first(Contraintes3, Contraintes).

ajouter_contraintes(Cont, [], _, _, Cont).
ajouter_contraintes(Contraintes, [H|T], Index, Label, [((H,Label,Index),Heuristic)|Res]) :-
	NewIndex is Index + 1,
	ajouter_contraintes(Contraintes, T, NewIndex, Label, Res),
	h(H, Heuristic).

h([], 0).
h([H|T], Valeur) :-
	h(T, V),
	Valeur is V + H + 1.

select_first([], []).
select_first([(X,_)|T], [X|Res]) :-
	select_first(T, Res).

appliquer_contraintes([], _, _).
appliquer_contraintes([(Cont,l,Index)|T], Lignes, Cols) :-
	nth1(Index, Lignes, Ligne),
	remplir_ligne(Ligne, Cont),
	appliquer_contraintes(T, Lignes, Cols).
appliquer_contraintes([(Cont,c,Index)|T], Lignes, Cols) :-
	nth1(Index, Cols, Col),
	remplir_ligne(Col, Cont),
	appliquer_contraintes(T, Lignes, Cols).

afficher_nonogramme([]).
afficher_nonogramme([Ligne|Reste]) :-
	afficher_ligne(Ligne),
	write('\n'),
	afficher_nonogramme(Reste).

afficher_ligne([]).
afficher_ligne([b|T]) :-
	write('.'),
	afficher_ligne(T).
afficher_ligne([n|T]) :-
	write('X'),
	afficher_ligne(T).

