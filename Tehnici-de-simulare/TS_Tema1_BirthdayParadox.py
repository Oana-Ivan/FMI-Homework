# Ivan Oana, 341 - Birthday Paradox

# Enuntarea problemei:
# Determinarea nr de persoane pentru care este mai probabil sa existe 2 persoane
# cu acceasi zi de nastere decat sa nu existe folosind metoda Monte-Carlo.

import numpy as np

def verifyRandom(nrPersoane):
    """
    Functia genereaza <nrPersoane> zile de nastere aleatoare si verifica daca exista 2 identice
    :param nrPersoane: numarul de persoane din grup
    :return: True daca exista 2 persoane cu aceeasi zi de nastere in grup
             False altfel
    """
    # Pastram zilele de nastere generate aleator intr-o colectie
    zileDeNastere = set()

    # Generam uniform <nrPersoane> numere intre 0 si 1 pentru a calcula ulterior zilele de nastere
    nrAleatoare = np.random.uniform(0, 1, nrPersoane)

    for ziNastere in nrAleatoare:
        # Zi de nastere = nr zilei din an (apartine de [1, 365])
        ziNastere = round(ziNastere * 365)

        # Verificam daca mai exista aceeasi zi de nastere in colectie
        if ziNastere in zileDeNastere:
            # Am gasit 2 zile de nastere identice
            return True

        # Adaugam noua zi in colectie
        zileDeNastere.add(ziNastere)

    # Nu sunt 2 zile de nastere identice in multimea de zile de nastere generata
    return False

def probabilitate (nrPersoane, cazuri_posibile):
    """
    :param nrPersoane: nr de persoane dintr-un grup
    :param cazuri_posibile: nr de grupuri pentru care o sa se testeze problema
    :return: probabilitaea ca 2 persoane sa aiba aceeasi zi de nastere intr-un
             grup de <nrPersoane> din <cazuri_posibile> grupuri (cazuri favorabile/cazuri posibile)
    """
    # Calculam nr de cazuri favorabile
    cazuri_favorabile = 0

    for caz_p in range(cazuri_posibile):
        # Generam nrPersoane zile de nastere si verificam daca este caz favorabil
        if verifyRandom(nrPersoane):
            cazuri_favorabile += 1

    # Returnam probabilitatea(float)
    return 1.0 * cazuri_favorabile / cazuri_posibile

def solutieBirthdayParadox(cazuri_posibile):
    """
    :param cazuri_posibile: nr de grupuri de persoane
    :return: nr de persoane pentru care probabilitatea ca 2 sa aiba acceasi zi de nastere > 0.5
    """

    # Calculam probabilitatea pentru intervalul [2, 366) deoarece
    #   1 => probabilitatea 0
    #   366: Consideram 365 de zile intr-un an => in 366 de persoane probabilitatea este 1
    for nrPersoane in range(2, 366):
        if (probabilitate(nrPersoane, cazuri_posibile) >= 0.5):
            return nrPersoane

# Verificam rezultatul prin mai multe simulari
for k in range(1, 5):
    cazuri_posibile = 10 ** k
    print("10 ^ %d simulari: %f" % (k, solutieBirthdayParadox(cazuri_posibile)))

# Raspunsul o sa fie ~ 23: Intr-un grup de 23 sau mai multe persoane probabilitatea
# ca doua persoane sa aiba aceeasi zi de nastere este mai mare sau egala cu 50%
