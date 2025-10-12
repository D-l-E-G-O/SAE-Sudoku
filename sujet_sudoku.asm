# Nom et prenom binome 1 : Aparicio Diego                     
# Nom et prenom binome 2 : ----------------                    

# ===== Section donnees =====  
.data
    fichier:    .asciiz "grille.txt"
    fichier_solutions:   .asciiz "solutions.txt"
    grille:     .space  324
    grilleChar: .space  82 # 81 chars + '\n'
    ligne:      .asciiz "======================="
    colonne:    .asciiz "|| "
    tiret:      .asciiz "-"
    espace:     .asciiz " "
    
    
# ===== Section code =====  
.text

# ----- Main ----- 
main:
    jal     parseValues             	# Charger les valeurs du fichier dans la grille
    jal     transformAsciiValues    	# Convertir les char de la grille en int
    la      $s0, grille             	# Charger l'adresse de la grille dans $s0
    jal     displayGrille           	# Afficher la grille de départ
    jal     createFile			# Crée le fichier qui va contenir toutes les solutions
    move    $s7, $v0			# $s7 <- $v0 (valeur de retour: descripteur du fichier)
    jal     addNewLine             	# Retour à la ligne
    jal     solve_sudoku           	# Fonction récursive pour résoudre le sudoku
    move    $a0, $s7			# $a0 <- $s7 (descripteur du fichier des solutions)
    jal     closeFile			# Appel de la fonction closeFile
    j exit                          	# Saut à la fin du programme


# ----- Fonctions ----- 


# ----- Fonction loadFile -----
# Objectif: Ouvre un fichier passé en paramètre : appel système 13 
# $a0  = nom du fichier
# $a1 (0 = lecture, 1 = écriture)
# Registres utilisés : $v0, $a0, $a1
loadFile:
	li      $v0, 13     # Chargement appel système 13
	li      $a1, 0      # Mode d'ouverture: lecture
	syscall             
	jr      $ra         # Retour à la fonction précédente

# ----- Fonction closeFile -----
# Objectif: Ferme le fichier passé en paramètre : appel système 16
# $a0 descripteur de fichier ouvert
# Registres utilisés : $v0, $a0
closeFile:
    li      $v0, 16     # Chargement appel système 16
    syscall
    jr      $ra         # Retour à la fonction précédente

# ----- Fonction parseValues -----
# Objectif : lit un fichier et stocke la grille lue.
# Registres utilisés : $v0, $a[0-2], $s0
parseValues: 
    # Sauvegarde de la référence du dernier jump
    sub     $sp, $sp, 4     # Sauvegarde la référence du dernier jump dans le pointeur de pile
    sw      $ra, 0($sp)	    # RAM[$sp + 0] <- $ra (adresse de retour)
    # Chargement du fichier
    la      $a0, fichier    # Charge le nom du fichier qui contient la gille
    jal     loadFile        # Saut à la fonction qui charge le fichier
    move    $s0, $v0        # Stocker le descripteur de fichier dans $s0
    # Lecture du fichier
    li      $v0, 14         # Chargement appel systeme 14 (lecture de fichier)
    move    $a0, $s0        # Charger le descripteur dans $a0
    la      $a1, grille     # L'emplacement mémoire où vont être stockés les valeurs lues
    li      $a2, 324        # Nombre d'octets à lire dans le fichier
    syscall
    #Fermeture du fichier
    jal     closeFile       # Saut vers la fonction qui ferme le fichier (le descripteur est déjà dans $a0)
    #Rechargement de la référence
    lw      $ra, 0($sp)     # On recharge la référence du dernier jump            
    add     $sp, $sp, 4 
    jr      $ra             # Retour à la fonction précédente


# ----- Fonction zeroToSpace -----
# Objectif : Convertir les 0 en "-"
# Registres utilisés : $v0, $a0
zeroToSpace:
    li		$v0, 4		# Chargement appel système 4 (Affichage chaine de caractères)
    la		$a0, tiret      # Chargement chaine à afficher -> "-"
    syscall
 	j       endZeroToSpace  # Retour à la fonction précédente
    
# ----- Fonction addNewLine -----  
# Objectif : Effectue un retour à la ligne
# Registres utilisés : $v0, $a0
addNewLine:
    li      $v0, 11         # Chargement appel système 11 (Affichage d'un char)
    li      $a0, 10         # Chargement char à afficher -> '\n'
    syscall
    jr      $ra             # Retour à la fonction précédente

# ----- Fonction displayGrille -----   
# Objectif : Affiche la grille en ligne.
# Registres utilisés : $v0, $a0, $t[0-2]
displayGrille: 
    la      $t0, grille     # Charge l'adresse de la grille dans $t0
    # Sauvegarde de la référence du dernier jump
    add     $sp, $sp, -4        # Sauvegarde la référence du dernier jump dans le pointeur de pile
    sw      $ra, 0($sp)		# RAM[$sp + 0] <- $ra (adresse de retour)
    # Boucle pour afficher les valeurs de la grille à la suite
    li      $t1, 0      	#Initialisation du compteur de boucle dans $t1
    boucle_displayGrille:
        bge     $t1, 81, end_displayGrille     # Si $t1 est plus grand ou égal à 81 alors branchement vers end_displayGrille
            add     $t2, $t0, $t1              # $t0 + $t1 -> $t2 ($t0 l'adresse du tableau et $t1 la position dans le tableau)
            lb      $a0, ($t2)                 # Charger dans $a0 à l'adresse $t2
            beqz	$a0, zeroToSpace       # Si $a0 == 0, on saute vers zeroToSpace --> On n'affiche pas l'entier          
            li      $v0, 1                     # Appel système pour l'affichage d'un entier
            syscall
            endZeroToSpace:
            add     $t1, $t1, 1                # $t1 += 1;
        j boucle_displayGrille
    end_displayGrille:
        lw      $ra, 0($sp)                 # On recharge la référence 
        add     $sp, $sp, 4                 # du dernier jump
    jr $ra				    # Retour à la fonction précédente



# ----- Fonction transformAsciiValues -----   
# Objectif : Transforme les valeurs de la grille de Ascii à Integer
# Registres utilisés : $t[0-3]
transformAsciiValues:
    # Sauvegarde de la référence du dernier jump
    add     $sp, $sp, -4    # Sauvegarde la référence du dernier jump dans le pointeur de pile
    sw      $ra, 0($sp)	    # RAM[$sp + 0] <- $ra (adresse de retour)
    la      $t3, grille     # Charge l'adresse de la grille dans $t3
    li      $t0, 0          # Initialisation du compteur de boucle dans $t0
    boucle_transformAsciiValues:
        bge     $t0, 81, end_transformAsciiValues 	# Si $t0 >= 81 saut à end
            add     $t1, $t3, $t0 			# $t1 <- adresse de la grille à l'index $t0
            lb      $t2, ($t1)				# $t2 <- Mem[$t1]
            sub     $t2, $t2, 48			# $t2 -= 48 (Pour passer de char à int)
            sb      $t2, ($t1)				# On remplace la valeur dans la grille par la valeur en int
            add     $t0, $t0, 1				# $t0 += 1
        j boucle_transformAsciiValues
    end_transformAsciiValues:
    lw      $ra, 0($sp)		# On recharge la référence du dernier jump
    add     $sp, $sp, 4
    jr $ra			# Retour à la fonction précédente


# ----- Fonction getModulo ----- 
# Objectif : Fait le modulo (a mod b)
#   $a0 représente le nombre a (doit etre positif)
#   $a1 représente le nombre b (doit etre positif)
# Résultat dans : $v0
# Registres utilisés : $a0 et $a1
getModulo: 
    sub     $sp, $sp, 4		# Sauvegarde la référence du dernier jump dans le pointeur de pile
    sw      $ra, 0($sp)		# RAM[$sp + 0] <- $ra (adresse de retour)
    boucle_getModulo:
        blt     $a0, $a1, end_getModulo		# Si $a0 < $a1: saut vers end_getModulo, Sinon:
            sub     $a0, $a0, $a1		# $a0 = $a0 - $a1
        j boucle_getModulo			# Relancer la boucle
    end_getModulo:
    move    $v0, $a0		# $v0 <- $a0
    lw      $ra, 0($sp)		# On recharge la référence du dernier jump
    add     $sp, $sp, 4
    jr $ra			# Retour à la fonction précédente
                                               
# ----- Fonction check_n_column -----           
# Objectif : Vérifier que la colonne n est correcte
#	$a0 représente la colonne de la grille (compris entre 0 et 8)
# Résultat dans : $v0
# Registres utilisés : $a0, $v0, $t[0-7]
check_n_column:
    add     $sp, $sp, -4 	# Sauvegarde la référence du dernier jump dans le pointeur de pile
    sw      $ra, 0($sp) 	# RAM[$sp + 0] <- $ra (adresse de retour)
    # Calcul de l'index de départ de la colonne: index de départ = n
    move    $t0, $a0		# $t0 = $a0 = n
    # Calcul de l'index de fin de la colonne: index de fin = index de départ + 9*8
    li      $t1, 9	        # $t1 = 9
    li      $t2, 8          	# $t2 = 8
    mult    $t1, $t2		# $t1 = 9*8
    mflo    $t1    		# Charge le résultat du produit dans $t1
    add     $t1, $t1, $t0       # $t1 = index de départ + 9*8
    # Initialiser le masque binaire et le bit de décalage
    li      $t2, 0	    	# Initialise le masque à 0
    li      $t3, 1          	# Initialise 1 pour le décalage: 00000001
    # Initialiser la valeur de retour
    li      $v0, 1          	# Par défaut $v0 = 1 (true)
    boucle_check_n_column:
    	bgt     $t0, $t1, end_check_n_column    # Si $t0 > $t1: saut vers end_check_n_column, Sinon:
    	add     $t4, $s0, $t0                   # $t4 = $s0 + $t0
    	lb      $t5, ($t4)                      # Chiffre à traiter: $t5 <- Mem[$t4]
    	# Sauter si on trouve un zéro
    	beq	$t5, 0, skip_check_n_column	# Si $t5 == 0: saut vers skip_check_n_column, Sinon:
        # Sinon: Créer le bit correspondant au chiffre             
        sllv    $t6, $t3, $t5                   # Décale 1 ($t3) à gauche de $t5 positions -> Si $t5 = 5: $t6 <- 00010000 
        # Ajouter le bit au masque
        or      $t7, $t2, $t6                   # Met le masque $t2 à jour dans $t7 pour pouvoir comparer $t7 et $t2 (la version pas à jour)                  
        beq     $t2, $t7, error_check_n_column  # Sort de la boucle si $t2 = $t7 mis à jour <=> le même bit a déjà été activé <=> la ligne compte 2 fois le même chiffre
        or      $t2, $t2, $t6                   # Met à jour le masque avec le bit activé: $t2 <- $t2 || $t6 (Exemple avec $t6 = 9: 00000000 || 100000000 = 100000000)
        skip_check_n_column:
            # Incrémenter l'index de recherche
            addi    $t0, $t0, 9                     # $t0 = $t0 + 9
    	    j boucle_check_n_column                 # Relancer la boucle
    end_check_n_column:
        lw      $ra, 0($sp)	# On recharge la référence du dernier jump
    	add     $sp, $sp, 4
	jr $ra			# Retour à la fonction précédente
    error_check_n_column:
        li      $v0, 0          # Valeur de retour = 0 (false)
    	j end_check_n_column

# ----- Fonction check_n_row -----              
# Objectif : Vérifier que la ligne n est correcte
#	$a0 représente la ligne de la grille (compris entre 0 et 8)
# Résultat dans : $v0
# Registres utilisés : $a0, $v0, $t[0-7]
check_n_row:
    add     $sp, $sp, -4 	# sauvegarde la référence du dernier jump dans le pointeur de pile
    sw      $ra, 0($sp) 	# RAM[$sp + 0] <- $ra (adresse de retour)
    # Calcul de l'index de départ de la ligne: index de départ = 9*n
    li      $t0, 9		# $t0 = 9
    mult    $t0, $a0		# $t0 *= n
    mflo    $t0			# Charge le résultat du produit dans $t0
    # Calcul de l'index de fin de la ligne: index de fin = index de départ + 9
    addi    $t1, $t0, 8		# $t1 = $t0 + 8
    # Initialiser le masque binaire et le bit de décalage
    li      $t2, 0		# Initialise le masque à 0
    li      $t3, 1          	# Initialise 1 pour le décalage: 00000001
    # Initialiser la valeur de retour
    li      $v0, 1          	# Par défaut $v0 = 1 (true)
    boucle_check_n_row:
    	bgt     $t0, $t1, end_check_n_row   # Si $t0 > $t1: saut vers end_check_n_row, Sinon:
    	add     $t4, $s0, $t0               # $t4 = $s0 + $t0
    	lb      $t5, ($t4)                  # Chiffre à traiter: $t5 <- Mem[$t4]
    	# Sauter si on trouve un zéro
    	beq	$t5, 0, skip_check_n_row    # Si $t5 == 0: saut vers skip_check_n_row, Sinon:
        # Sinon: Créer le bit correspondant au chiffre
        sllv    $t6, $t3, $t5               # Décale 1 ($t3) à gauche de $t5 positions -> Si $t5 = 5: $t6 <- 00010000
        # Ajouter le bit au masque
        or      $t7, $t2, $t6               # Met le masque $t2 à jour dans $t7 pour pouvoir comparer $t7 et $t2 (la version pas à jour)                  
        beq     $t2, $t7, error_check_n_row # Sort de la boucle si $t2 = $t7 mis à jour <=> le même bit a déja été activé <=> la ligne compte 2 fois le même chiffre
        or      $t2, $t2, $t6               # Met à jour le masque avec le bit activé: $t2 <- $t2 || $t6 (Exemple avec $t6 = 9: 00000000 || 100000000 = 100000000)
        skip_check_n_row:
        # Incrémenter l'index de recherche
    	addi    $t0, $t0, 1                 # $t0 = $t0 + 1
    	j boucle_check_n_row                # Relancer la boucle
    end_check_n_row:
    	lw      $ra, 0($sp)	# On recharge la référence du dernier jump
    	add     $sp, $sp, 4
    	jr $ra			# Retour à la fonction précédente
    error_check_n_row:
        li      $v0, 0          # Valeur de retour = 0 (false)
    	j end_check_n_row

# ----- Fonction check_n_square -----           
# Objectif : Vérifier que le carré n est correct
#	$a0 représente le carré de la grille (compris entre 0 et 8)
# Résultat dans : $v0
# Registres utilisés : $a0, $v0, $t[0-8]
check_n_square:
    add     $sp, $sp, -4 	# Sauvegarde la référence du dernier jump dans le pointeur de pile
    sw      $ra, 0($sp) 	# RAM[$sp + 0] <- $ra (adresse de retour)
    # Calcul de l'index de départ de la ligne: index de départ = 3*(n%3) + 27*(n/3)
    move    $t0, $a0        # $t0 = n
    li      $a1, 3          # $a1 = 3
    jal getModulo           # $v0 = n%3
    move    $t1, $v0        # $t1 = n%3
    mult    $t1, $a1        # $t1 = 3*(n%3)
    mflo    $t1		    # Charge le résultat du produit dans $t1
    li      $t2, 27         # $t2 = 27
    div     $t0, $a1        # $t0 = n/3
    mflo    $t0             # Charge le résultat du produit dans $t0
    mult    $t0, $t2        # $t0 = (n/3)*27
    mflo    $t0		    # Charge le résultat du produit dans $t0
    add     $t0, $t0, $t1   # $t0 = (n/3)*27 + 3*(n%3)
    # Calcul de l'index de fin de la ligne: index de fin = index de départ + 20
    addi    $t1, $t0, 20    # $t1 = $t0 + 20
    # Initialiser le masque binaire et le bit de décalage
    li      $t2, 0          # Initialise le masque à 0
    li      $t3, 1          # Initialise 1 pour le décalage: 00000001
    # Initialiser la valeur de retour
    li      $v0, 1          # Par défaut $v0 = 1 (true)
    # Initialiser le compteur
    li	    $t8, 0	    # $t8 = 0
    boucle_check_n_square:
    	bgt     $t0, $t1, end_check_n_square    # Si $t0 > $t1: saut vers end_check_n_square, Sinon:
    	add     $t4, $s0, $t0                   # $t4 = $s0 + $t0
    	lb      $t5, ($t4)                      # Chiffre à traiter: $t5 <- Mem[$t4]
    	# Sauter si on trouve un zéro
    	beq	$t5, 0, skip_check_n_square     # Si $t5 == 0: saut vers skip_check_n_square, Sinon:
        # Sinon: Créer le bit correspondant au chiffre
        sllv    $t6, $t3, $t5                   # Décale 1 ($t3) à gauche de $t5 positions -> Si $t5 = 5: $t6 <- 00010000
        # Ajouter le bit au masque
        or      $t7, $t2, $t6                   # Met le masque $t2 à jour dans $t7 pour pouvoir comparer $t7 et $t2 (la version pas à jour)                  
        beq     $t2, $t7, error_check_n_square  # Sort de la boucle si $t2 = $t7 mis à jour <=> le même bit a déja été activé <=> la ligne compte 2 fois le même chiffre
        or      $t2, $t2, $t6                   # Met à jour le masque avec le bit activé: $t2 <- $t2 || $t6 (Ex avec $t6 = 9: 00000000 || 100000000 = 100000000)
        skip_check_n_square:
        # Incrémenter l'index de recherche
        addi	$t8, $t8, 1			# $t8 = $t8 + 1
        beq	$t8, 3, next_line		# Si $t8 == 3: saut vers next_line, Sinon: 
        addi    $t0, $t0, 1                     # $t0 = $t0 + 1
        j boucle_check_n_square         	# Relancer la boucle
   next_line:
   	li 	$t8, 0			# $t8 = 0
       	addi    $t0, $t0, 7		# $t0 = $t0 + 7
    	j boucle_check_n_square         # Relancer la boucle
    end_check_n_square:
    	lw      $ra, 0($sp)	# On recharge la référence du dernier jump
    	add     $sp, $sp, 4
    	jr $ra			# Retour à la fonction précédente
    error_check_n_square:
        li      $v0, 0          # Valeur de retour = 0 (false)
    	j end_check_n_square

# ----- Fonction check_columns -----            
# Objectif : Vérifier la validité de toutes les colonnes de la grille de sudoku
# Résultat dans : $v0
# Registres utilisés : $a0, $t9
check_columns:
    add     $sp, $sp, -4 	# Sauvegarde la référence du dernier jump dans le pointeur de pile
    sw      $ra, 0($sp) 	# RAM[$sp + 0] <- $ra (adresse de retour)
    li      $t9, 0		# $t9 <- 0
    # Initialiser la valeur de retour
    li      $v0, 1              # Par défaut $v0 = 1 (true)
    boucle_check_columns:
   	bge     $t9, 9, end_check_columns	# Si $t9 >= 9: saut vers end_check_columns, Sinon:
   	move      $a0, $t9			# Affectation du registre d'argument à la ligne que l'on souhaite vérifier: $a0 <- $t9
    	jal check_n_column			# Appel de la fonction check_n_rows
    	beq     $v0, $0, end_check_columns	# Si la valeur de retour == 0: saut vers end_check_columns, Sinon:
        addi    $t9, $t9, 1			# $t9 <- $t9 + 1
    	j boucle_check_columns			# Relancer la boucle
    end_check_columns:
    	lw      $ra, 0($sp)		# On recharge la référence 
    	add     $sp, $sp, 4		# du dernier jump
    	jr $ra				# Retour à la fonction précédente

# ----- Fonction check_rows -----               
# Objectif : Vérifier la validité de toutes les lignes de la grille de sudoku
# Résultat dans : $v0
# Registres utilisés : $a0, $t9
check_rows:
    add     $sp, $sp, -4 	# Sauvegarde la référence du dernier jump dans le pointeur de pile
    sw      $ra, 0($sp) 	# RAM[$sp + 0] <- $ra (adresse de retour)
    li      $t9, 0		# $t9 <- 0
    boucle_check_rows:
   	bge     $t9, 9, end_check_rows		    # Si $t9 >= 9: saut vers end_check_rows, Sinon:
   	move      $a0, $t9			    # Affectation du registre d'argument à la ligne à vérifier: $a0 <- $t9
    	jal check_n_row			            # Appel de la fonction check_n_rows
    	beq     $v0, $0, end_check_rows		    # Si la valeur de retour == 0: saut vers end_check_rows, Sinon:
        addi    $t9, $t9, 1			    # $t9 <- $t9 + 1
    	j boucle_check_rows			    # Relancer la boucle
    end_check_rows:
    	lw      $ra, 0($sp)		# On recharge la référence 
    	add     $sp, $sp, 4		# du dernier jump
    	jr $ra				# Retour à la fonction précédente

# ----- Fonction check_squares -----            
# Objectif : Vérifier la validité de tous les carrés de la grille de sudoku
# Résultat dans : $v0
# Registres utilisés : $a0, $t0
check_squares:
    add     $sp, $sp, -4 	# Sauvegarde la référence du dernier jump dans le pointeur de pile
    sw      $ra, 0($sp) 	# RAM[$sp + 0] <- $ra (adresse de retour)
    li      $t9, 0		# $t9 <- 0
    boucle_check_squares:
   	bge     $t9, 9, end_check_squares		# Si $t9 >= 9: saut vers end_check_squares, Sinon:
   	move      $a0, $t9			        # Affectation du registre d'argument à la ligne que l'on souhaite vérifier: $a0 <- $t9
    	jal check_n_square			        # Appel de la fonction check_n_rows
    	beq     $v0, $0, end_check_squares	    	# Si la valeur de retour == 0: saut vers end_check_squares, Sinon:
        addi    $t9, $t9, 1			        # $t9 <- $t9 + 1
    	j boucle_check_squares			        # Relancer la boucle
    end_check_squares:
    	lw      $ra, 0($sp)		# On recharge la référence 
    	add     $sp, $sp, 4		# du dernier jump
    	jr $ra				# Retour à la fonction précédente

# ----- Fonction check_sudoku -----             
# Objectif : Vérifier que la grille de sudoku est valide
# Résultat dans : $v0
# Registres utilisés : 
check_sudoku:
    add     $sp, $sp, -4 		# Sauvegarde la référence du dernier jump dans le pointeur de pile
    sw      $ra, 0($sp) 		# RAM[$sp + 0] <- $ra (adresse de retour)
    jal check_rows			# Saut vers la fonction check_rows
    beq     $v0, $0, end_check_sudoku	# Si la valeur de retour est 0 (false): saut vers end_check_sudoku, Sinon:
    jal check_columns			# Saut vers la fonction check_columns
    beq     $v0, $0, end_check_sudoku	# Si la valeur de retour est 0 (false): saut vers end_check_sudoku, Sinon:
    jal check_squares			# Saut vers la fonction check_squares
    beq     $v0, $0, end_check_sudoku	# Si la valeur de retour est 0 (false): saut vers end_check_sudoku, Sinon:
    # Message de validation de la grille pour le débogage
    #la      $a0, validation   	 # Adresse de la chaine à afficher
    #li      $v0, 4              # Appel système 4: afficher une chaîne de caractères
    #syscall
    end_check_sudoku:
    	lw      $ra, 0($sp)     # On recharge la référence 
    	add     $sp, $sp, 4     # du dernier jump
    	jr $ra			# Retour à la fonction précédente


# ----- Fonction solve_sudoku -----
# Objectif : Trouver toutes les solutions possibles de la grille de sudoku (s'il y en a)
# Registres utilisés : $a0, $s[1-3]
solve_sudoku:	
    sub     $sp, $sp, 4 	# Sauvegarde de la référence du dernier jump
    sw      $ra, 0($sp) 	# RAM[$sp + 0] <- $ra (adresse de retour)
    li      $s1, 0      	# Initialisation pour la boucle case vide
    li      $s3, 1      	# Initialisation pour la boucle chiffre
    # Trouver l'adresse de la première case vide
    boucle_case_vide: 
    	bge     $s1, 81, solution       # Si $s1 >= 81 (= aucune case vide): saut vers solution, Sinon:
    	add     $s2, $s0, $s1       	# $s2 <-- $s0 + $s1 ($s0 = l'adresse du tableau et $s1 = la position dans le tableau)
        lb      $a0, ($s2)		# Charge la valeur contenue à cet emplacement
	beqz 	$a0, boucle_chiffre  	# Si $a0 == 0: saut vers boucle_chiffre, Sinon:
    	add     $s1, $s1, 1         	# $s1 += 1
    	j   boucle_case_vide            # Relancer la boucle
    # Tester pour 1 à 9 les valeurs dans la case vide	
    boucle_chiffre:
	bgt     $s3, 9, fin_boucle_chiffre 	# Si $s3 > 9: saut vers fin_boucle_chiffre, Sinon:
	sb 	$s3, 0($s2) 			# On essaye le chiffre en le plaçant dans la case vide (adresse $s2 dans la grille)
	jal check_sudoku 			# On vérifie si la grille est toujours correcte
	beqz 	$v0, fin_test 			# Si $v0 == 0 (grille invalide): saut vers fin_test, Sinon:
	# Propagation
	sub     $sp, $sp, 8		# Sauvegarde de la référence du dernier jump
        sw      $s2, 0($sp)     # RAM[$sp + 0] <- $s2 (adresse de la case que l'on vient de remplir)
        sw      $s3, 4($sp)     # RAM[$sp + 4] <- $s3 (chiffre que l'on a inséré dans la case vide)
        jal     solve_sudoku    # Appel récursif de la fonction solve_sudoku --> Retro propagation
        lw      $s2, 0($sp)	# On charge $s2 à nouveau
        lw      $s3, 4($sp)	# On charge $s3 à nouveau
        add     $sp, $sp, 8     # On recharge la référence du dernier jump
    fin_test:
	sb      $zero, 0($s2)   # On remplit la case vide avec un 0
	add     $s3, $s3, 1     # $s3 += 1
        j   boucle_chiffre      # Relancer la boucle
    fin_boucle_chiffre:
	lw      $ra, 0($sp)     # On recharge la référence du dernier jump         
    	add     $sp, $sp, 4 
        jr $ra			# Retour à la fonction précédente
	
    solution:
        jal     transformIntValues	# Convertir la grille en valeurs Ascii
    	jal     saveSolution	    	# Sauvegarder les solutions dans le fichier
    	jal 	displayGrille		# Affiche la grille comme solution
    	jal 	addNewLine 	  	# Saute une ligne
    	lw      $ra, 0($sp)     	# On recharge la référence du dernier jump            
    	add     $sp, $sp, 4 
    	jr $ra				# Retour à la fonction précédente
        
# ----- Fonctions Supplémentaires pour l'affichage de la grille de sudoku ----- 

# ----- Fonction add_column -----
# Objectif : Affiche le séparateur de colonnes
# Registres utilisés : $v0, $a[0-1], $t0
add_column:
    # Sauvegarde de la référence du dernier jump
    add     $sp, $sp, -4    
    sw      $ra, 0($sp) 
    move    $a0, $t0			# $a0 <- $t0
    li      $a1, 9			# $a1 <- 9
    jal     getModulo			# Appel de la fonction getModulo
    beq     $v0, 8, end_add_column 	# Si le retour de la fonction == 8: Saut vers end_add_column, Sinon:
    la      $a0, colonne   		# Adresse de la chaine à afficher
    li      $v0, 4         		# Appel système 4: afficher une chaine de caractères
    syscall
    end_add_column:
    	lw      $ra, 0($sp)	# On recharge la référence 
	add     $sp, $sp, 4     # du dernier jump
        jr      $ra		# Retour à la fonction précédente

# ----- Fonction add_row -----
# Objectif : Effectue un retour à la ligne et affiche le séparateur de lignes
# Registres utilisés : $v0, $a0, $t0
add_row:
    add     $sp, $sp, -4        	# Sauvegarde de la référence du dernier jump
    sw      $ra, 0($sp)
    li      $v0, 1          		# Code de retour pour empêcher une boucle infinie
    beq     $t0, 80, end_add_row    	# Si $t0 == 80: saut vers end_add_row, Sinon:
    la      $a0, ligne   		# Adresse de la chaine a afficher
    li      $v0, 4          		# Appel système 4: afficher une chaine de caractères
    syscall
    jal addNewLine			# Appel de la fonction addNewLine
    end_add_row:
    	lw      $ra, 0($sp)	# On recharge la référence 
    	add     $sp, $sp, 4     # du dernier jump
    	jr $ra			# Retour à la fonction précédente

# ----- Fonction displaySudoku -----   
# Objectif : Affiche la grille de sudoku de manière matricielle.
# Registres utilisés : $v0, $a[0-1], $t[0-1]
displaySudoku:  
    add     $sp, $sp, -4        # Sauvegarde de la référence du dernier jump
    sw      $ra, 0($sp)
    li      $t0, 0		# $t0 <- 0
    jal addNewLine		# Appel de la fonction addNewLine
    boucle_displaySudoku:
        bge     $t0, 81, end_displaySudoku    	# Si $t0 >= 81: saut vers end_displaySudoku, Sinon:
            # Afficher l'entier
            add     $t1, $s0, $t0           	# $s0 + $t0 -> $t1 ($s0 l'adresse du tableau et $t0 la position dans le tableau)
            lb      $a0, ($t1)              	# Charger dans $a0 à l'adresse $t1
            li      $v0, 1                  	# Code pour l'affichage d'un entier
            syscall
            # Afficher un espace
            la      $a0, espace   		# Adresse de la chaine à afficher
    	    li      $v0, 4          		# Appel système 4: afficher une chaine de caracteres
    	    syscall
    	    # Afficher le séparateur de colonnes si necessaire
    	    move $a0, $t0 			# $a0 <- $t0
            li $a1, 3				# $a1 <- 3
            jal getModulo			# Appel de la fonction getModulo
            beq $v0, 2, add_column		# Si la valeur de retour == 2: saut vers add_column, Sinon:
            # Sauter une ligne si necessaire
            move $a0, $t0 			# $a0 <- $t0
            li $a1, 9				# $a1 <- 9
            jal getModulo			# Appel de la fonction getModulo
            beq $v0, 8, addNewLine		# Si la valeur de retour == 8: saut vers addNewLine, Sinon:
            # Afficher le separateur de lignes si necessaire
            move $a0, $t0 			# $a0 <- $t0
            li $a1, 27				# $a1 <- 27
            jal getModulo			# Appel de la fonction getModulo
            beq $v0, 26, add_row		# Si la valeur de retour == 26: saut vers add_row, Sinon:
            # Incrémenter $t0
            add     $t0, $t0, 1             	# $t0 += 1;
        j boucle_displaySudoku			# Relancer la boucle
    end_displaySudoku:
        lw      $ra, 0($sp)                 # On recharge la référence 
        add     $sp, $sp, 4                 # du dernier jump
    jr $ra				    # Retour à la fonction précédente

# ----- Fonctions pour l'enregistrement des solutions ----- 

# ----- Fonction createFile -----
# Objectif : Crée/Ouvre un fichier passé en paramètre : appel système 13 
# 	$a0  représente le nom du fichier
# 	$a1 (0 = lecture, 1 = écriture, 2 = lecture + écriture, ..., 9 = écriture en mode APPEND)
#	$a2 définit les droits Unix du fichier
# Résultat dans $v0
# Registres utilisés : $v0, $a[0-2]
createFile:
    # Sauvegarde de la référence du dernier jump
    add     $sp, $sp, -4    
    sw      $ra, 0($sp)
    li      $v0, 13         		# Chargement appel système 13: ouvrir un fichier
    la      $a0, fichier_solutions   	# Nom du fichier créé
    li      $a1, 9          		# Mode d'ouverture (ici écriture en mode APPEND --> à la fin du fichier)
    li      $a2, 420      		# Permissions (-rw-r--r-- = 644 en octal = 420 en décimal) --> Lecture/écriture pour le propriétaire, lecture pour le groupe et les autres
    syscall             
    lw      $ra, 0($sp)		# On recharge la référence 
    add     $sp, $sp, 4     	# du dernier jump
    jr $ra			# Retour à la fonction précédente

# ----- Fonction saveSolution -----
# Objectif : Sauvegarde une solution dans un fichier
# 	$a0 représente le descripteur du fichier
# 	$a1 représente la chaine à écrire
#	$a2 représente le nombre d'octets à écrire
# Registres utilisés : $v0, $a[0-2]
saveSolution:
    # Sauvegarde de la référence du dernier jump
    add     $sp, $sp, -4    
    sw      $ra, 0($sp)
    # Creation du fichier
    move    $a0, $s7		# $a0 <- $s7 (descripteur du fichier des solutions)
    li      $v0, 15		# $v0 <- 15 (code pour écrire dans un fichier)
    la      $a1, grilleChar	# $a1 <- adresse de la grilleChar
    li      $a2, 82		# $a2 <- 82 (81 chars + '\n' = 82 octets à écrire)
    syscall			# Ecrit dans le fichier
    lw      $ra, 0($sp)		# On recharge la référence 
    add     $sp, $sp, 4     	# du dernier jump
    jr $ra			# Retour à la fonction précédente


# ----- Fonction transformIntValues -----   
# Objectif : Transforme les valeurs de la grille de Integer à Ascii
# Registres utilisés : $t[0-4]
transformIntValues:
    add     $sp, $sp, -4	# Sauvegarde de la référence du dernier jump
    sw      $ra, 0($sp)
    li      $t0, 0          	# Initialisation du compteur de boucle dans $t0
    la      $t1, grilleChar 	# Charge l'adresse de la grilleChar dans $t1
    boucle_transformIntValues:
        bge     $t0, 81, end_transformIntValues		# Si $t0 >= 81, saut vers end_transformIntValues, Sinon:
            add     $t2, $s0, $t0 			# $t2 <- $s0 + $t0
            add     $t3, $t1, $t0			# $t3 <- $t1 + $t0
            lb      $t4, ($t2)				# Charger dans $t4 à l'adresse $t2 (valeur de la grille à l'index $t0)
            add     $t4, $t4, 48			# $t4 += 48 (Pour passer de int à char Ascii)
            sb      $t4, ($t3)				# On place le char dans la grilleChar à l'index $t0
            add     $t0, $t0, 1				# $t0 += 1
        j boucle_transformIntValues			# Relancer la boucle
    end_transformIntValues:
    add     $t3, $t1, $t0	# $t3 <- $t1 + $t0
    li      $t4, 10         	# Chargement char:  '\n'
    sb	    $t4, ($t3)		# On place le char dans la grilleChar à l'index $t0
    lw      $ra, 0($sp)		# On recharge la référence 
    add     $sp, $sp, 4		# du dernier jump
    jr $ra			# Retour à la fonction précédente




exit: 
    li $v0, 10	# Appel système pour terminer le programme
    syscall
