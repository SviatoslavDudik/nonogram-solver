/* remplir_ligne(+Ligne, +Contraintes)
 * Remplit la liste Liste avec n ou b (noir or blanc) en respectant les
 * contraintes Contraintes. La liste Ligne doit être créée auparavant.
 * La liste de contraintes est une liste contenant les nombres de cases noires
 * contigües.
 *
 * Exemple :
 * ?- length(L,5), remplir_ligne(L,[2,1]).
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

/* repeter(+Elem, +Taille, -Liste) :-
 * Crée la liste Liste contenant Taille éléments Elem.
 *
 * Exemple :
 * ?- repeter(n,4,L).
 * L = [n, n, n, n] ;
 * false. */
repeter(_, 0, []).
repeter(Elem, Taille, [Elem|Liste]) :-
	Taille>0,
	NewTaille is Taille-1,
	repeter(Elem, NewTaille, Liste).


/* creer_matrice(+NLignes, +NCols, -Lignes, -Cols)
 * Crée une matrice de taille (NLignes,NCols). La matrice a deux représentations:
 * 1) liste de lignes (Lignes)
 * 2) liste de colonnes (Cols)
 *
 * Exemple :
 * ?- creer_matrice(2,3,L,C).
 * L = [[_9502, _9508, _9514], [_9520, _9526, _9532]],
 * C = [[_9502, _9520], [_9508, _9526], [_9514, _9532]] ;
 * false. */
creer_matrice(NLignes, NCols, Lignes, Cols) :-
	creer_lignes(NLignes, NCols, Lignes),
	transposer(Lignes, Cols).

/* creer_lignes(+NLignes, +NCols, -Lignes)
 * Créer la matrice Lignes avec NLignes lignes et NCols colonnes.
 *
 * Exemple :
 * ?- creer_lignes(2,3,L).
 * L = [[_916, _922, _928], [_934, _940, _946]]. */
creer_lignes(NLignes, NCols, Lignes) :-
	length(Lignes, NLignes),
	CreerNCols =.. [creer_ligne, NCols],
	maplist(CreerNCols, Lignes).

creer_ligne(NCols, Ligne) :-
	length(Ligne, NCols).

/* transposer(+Matrice, ?Transposee)
 * Vrai si Transposee est la transposée de la matrice Matrice.
 *
 * Exemples :
 * ?- transposer([[1,2],[3,4]],T).
 * T = [[1, 3], [2, 4]] ;
 * false.
 * ?- transposer([[1,2],[3,4]],[[1,3],[2,4]]).
 * true ;
 * false. */
transposer([H|T], Transposee) :-
	length(H, NCols),
	repeter([], NCols, Cols),
	transposer([H|T], Cols, Transposee).

/* transposer(+Matrice, +Cols, ?Transp))
 * Vrai si la transposée de la matrice (de taille MxN) Matrice est Transp.
 * Cols est une liste contenant N listes vides. */
transposer([], Cols, Cols).
transposer([H|T], Cols, Res) :-
	transposer(T, Cols, Cols1),
	maplist(ajouter_debut, Cols1, H, Res).

ajouter_debut(Liste, H, [H|Liste]).

/* nonogramme(+NLignes, +NCols, +ContLignes, +ContCols, -Lignes)
 * Remplit le nonogramme constitué de NLignes lignes et NCols colonnes ayant les
 * contraintes sur les lignes ContLignes et sur les colonnes ContCols.
 *
 * ContLignes (resp. ContCols) est une liste qui contient NLignes (resp. NCols)
 * listes. Chacune de ces dernières décrit les contraintes sur une ligne (resp.
 * une colonne) du nonogramme. Par exemple ContLignes = [[2,1]|_] veut dire que
 * la première ligne comporte 2 cases noires contigües suivis d'au moins une case
 * blanche et ensuite une case noire, toutes les autres cases sont blanches.
 *
 * Le remplissage avec n (noir, rempli) et b (blanc, non rempli) se trouve dans
 * Lignes à la fin de l'exécution. Lignes est une liste de lignes, donc chaque
 * élément de cette liste représente une ligne du dessin.
 *
 * Exemple :
 * ?- nonogramme(4,4,[[1,1],[2],[3],[1]],[[1,1],[3],[2],[1]],G).
 * G = [[n, b, b, n], [b, n, n, b], [n, n, n, b], [b, n, b, b]] ;
 * false. */
nonogramme(NLignes, NCols, ContLignes, ContCols, Lignes) :-
	creer_matrice(NLignes, NCols, Lignes, Cols),
	former_liste_contraintes(ContLignes, ContCols, Contraintes),
	appliquer_contraintes(Contraintes, Lignes, Cols).

/* former_liste_contraintes(+ContLignes, +ContCols, -Contraintes)
 * Crée la liste des contraintes en fusionnant les listes ContLignes et ContCols
 * qui sont respectivement les contraintes sur les ligne et sur les colonnes
 * décrites dans le prédicat nonogramme/5.
 *
 * La nouvelle liste Contraintes contient des triples (Cont,l/c,Index) avec
 * Cont étant une contrainte,
 * l pour une contrainte de ligne ou c celle de colonne et
 * Index étant l'indice de la ligne/colonne en commençant à 1.
 *
 * Toutes les contraintes sont triées dans l'ordre de la meilleure à la plus
 * mauvaise selon la valeur heuristique h/2.
 *
 * Exemple :
 * ?- former_liste_contraintes([[1,1],[2],[3],[1]],[[1,1],[3],[2],[1]],Cont).
 * Cont = [([1, 1], c, 1),  ([3], c, 2),  ([1, 1], l, 1),  ([3], l, 3),  ([2], c, 3),  ([2], l, 2),  ([1], c, 4),  ([1], l, 4)] ;
 * false. */
former_liste_contraintes(ContLignes, ContCols, Contraintes) :-
	ajouter_contraintes([], ContLignes, 1,  l, Contraintes1),
	ajouter_contraintes(Contraintes1, ContCols, 1, c, Contraintes2),
	sort(2, @>=, Contraintes2, Contraintes3),
	select_first(Contraintes3, Contraintes).

/* ajouter_contraintes(+Contraintes, +NewContraintes, +BaseIndex, +Label, -Resultat)
 * Ajoute les contraintes NewContraintes à la liste Contraintes.
 *
 * BaseIndex est l'indice de la première contrainte (généralement 0 ou 1) pour
 * pouvoir numéroter correctement.
 * Label sera inclus avec chaque nouvelle contrainte et est destiné à distinguer
 * des familles de contraintes différentes.
 *
 * Resultat est la liste après l'ajout de NewContraintes. Pour chaque contrainte
 * de NewContraintes on ajoute ((Cont,Label,Index),Heuristic) à Resultat où :
 * Cont est une contrainte,
 * Label toujours la même chose,
 * Index est l'indice de la contrainte dans la liste NewContraintes (en
 * commençant à BaseIndex),
 * Heuristic la valeur heuristique correspondante à Cont.
 *
 * Exemple :
 * ?- ajouter_contraintes([1,2],[[1,1],[2],[3],[1]],1,l,Cont).
 * Cont = [(([1, 1], l, 1), 4),  (([2], l, 2), 3),  (([3], l, 3), 4),  (([1], l, 4), 2), 1, 2] ;
 * false. */
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

