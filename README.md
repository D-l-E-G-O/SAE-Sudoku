# SAE Sudoku ![Static Badge](https://img.shields.io/badge/Statut-Termin%C3%A9-red)

Projet de début de 1ère année de **BUT Informatique** à l’**IUT d’Illkirch**.

Le but de ce projet était de coder un **solveur de grille de sudoku en assembleur**.
Le solveur lit un fichier nommé "grille.txt" contenant la représentation de la grille de sudoku à résoudre et crée un fichié nommé "solutions.txt" qui contient toutes le solutions (s'il y en a).


## Technologies utilisées

- **Langage :** MIPS32
- **IDE :** MARS


## Équipe

- Nombre de développeurs : **1**  
- Durée du projet : **3 semaines**


## Installation et exécution

1. Cloner le dépôt :
    ```bash
    git clone https://github.com/mon-utilisateur/sae-sudoku.git
    cd sae-sudoku
    ```
2. Ouvrir le fichier **sujet_sudoku.asm** dans un IDE comme MARS, SPIM ou QTSPIM : <br>
    MARS : https://dpetersanderson.github.io/ <br>
    SPIM : https://spimsimulator.sourceforge.net/ <br>
    QTSPIM : https://sourceforge.net/projects/spimsimulator/files/
3. Définir la grille de sudoku :
    Modifier la grille dans la section .data
    Ou créer un fichier nommé "grille.txt" contenant une grille au bon format, par exemple :
       ```bash
       530070000
       600195000
       098000060
       800060003
       400803001
       700020006
       060000280
       000419005
       000080079
       ```
5. Exécuter le programme puis lire le résultat dans le fichier "solutions.txt" qui sera créé.


## Fonctionnalités principales

- Lire la grille se trouvant dans le fichier "grille.txt"
- Convertir les caractères de la grille en entiers
- Créer le fichier "solutions.txt" qui va contenir toutes les solutions
- Trouver toutes les solutions à l'aide d'une fonction récursive (algorithme de rétro-propagation) tout en affichant chaque solution à l'écran
  et en stockant chaque solution dans le fichier "solutions.txt". (Si la grille est impossible à résoudre, le programme n'affichera tout simplement aucun résultat)
