# Varianta 2

import numpy as np
import matplotlib.pyplot as plt
import math

# Exercitiul 1

# Definim functia:
def f(x):
    return 2 * x * math.cos(2 * x) - (x + 1) * (x + 1)

# apeleaza fct cu -3 si 0
# x = np.arange(a, b)
# plt.plot(x, f)
# plt.show()

a = -5
b = 5
def MetSecantei(f, x0, x1, eps):
    """
    :param f: functia data
    :param x0, x1: capetele intervalului
    :param eps: valoare apropiata de zero
    :return: xk1 - solutia aproximativa, k - nr de iteratii
    """
    # Verificare ca x0 si x1 sunt in intervalul [a, b]
    if x0 < a or x0 > b or x1 < a or x1 > b:
        print("Valorile alese pentru x0 si x1 nu se afla in interval")
        return
    k = 1
    xk2 = x0
    xk1 = x1
    while (abs(xk1-xk2)/abs(xk2)) >= eps:
        k += 1
        xk3 = xk2
        xk2 = xk1
        xk1 = (xk3 * f(xk2) - xk2 * f(xk3))/(f(xk2) - f(xk3))
        if xk1 < a or xk1 > b:
            print("Introduceti alte valori")
            return
    return xk1, k


def MetPozFalse(f, a, b, eps):
    k = 0
    a0 = a
    b0 = b
    x0 = (a0 * f(b0) - b0 * f(a0))/(f(b0) - f(a0))
    xk = x0
    ak = a0
    bk = b0
    while True:
        k += 1
        xkminus1 = xk
        akminus1 = ak
        bkminus1 = bk
        if f(xkminus1) == 0:
            xk = xkminus1
        elif f(akminus1)*f(xkminus1) < 0:
            ak = akminus1
            bk = xkminus1
            xk = (ak *f(bk) - bk*f(ak))/(f(bk) - f(ak))
        elif f(akminus1)*f(xkminus1) > 0:
            ak = xkminus1
            bk = bkminus1
            xk = (ak *f(bk) - bk*f(ak))/(f(bk) - f(ak))
        if abs(xk - xkminus1)/abs(xkminus1) >= eps:
            break
    return xk, k

# intervale: [-3, -2], [-1, 1]

sol1MetSecantei = MetSecantei(f, -3., -2., 10**(-5))
sol2MetSecantei = MetSecantei(f, -1., 1, 10**(-5))
sol1MetPozFalse = MetPozFalse(f, -3., -2., 10**(-5))
sol2MetPozFalse = MetPozFalse(f, -1., 1, 10**(-5))
solutii = np.array([sol1MetSecantei[0], sol2MetSecantei[0], sol1MetPozFalse[0], sol2MetPozFalse[0]])

x_grafic2 = np.linspace(a, b, 100)
y = np.vectorize(f)
plt.plot(x_grafic2, y(x_grafic2), linewidth=3)
plt.grid()
plt.axvline(0, color='black')
plt.axhline(0, color='black')
plt.plot(solutii, y(solutii), 'o', markerfacecolor = 'red', markersize = 10)
plt.show()

# afisare solutii
print("Rezultate intoarse de metoda secantei(solutie aproximativa si nr de iteratii)")
print("Pentru intervalul [-3, -2]")
print(sol1MetSecantei)
print("Pentru intervalul [-1, 1]")
print(sol2MetSecantei)

print("Rezultate intoarse de metoda pozitiei false(solutie aproximativa si nr de iteratii)")
print("Pentru intervalul [-3, -2]")
print(sol1MetPozFalse)
print("Pentru intervalul [-1, 1]")
print(sol2MetPozFalse)

###########################################################################
# Exercitiul 2
print("Ex2")

def metSubsDesc(A, b, tol):
    """
    param A: matrice patratica, superior triunghiulara, cu toate elem pe diag principala nenule
    param b: vectorul term liberi
    param tol: val numerica ft mica in rap cu care vom compara numerele apropiate de 0
    return: sol sistem
    """

    m, n = np.shape(A)
    if m != n:
        print("Matricea nu este patratica. Introduceti o alta matrice.")
        x = None
        return x

    # Verificam daca matricea este superior triunghiulara
    for i in range(m):
        for j in range(i):
            if abs(A[i][j]) > tol:
                print("Matricea nu este superior triunghiulara")
                x = None
                return x

    # Verificam daca elementele de pe diagonala principala sunt nule (sist comp det)
    for i in range(n):
        if A[i][i] == 0:
            print("Sistemul nu este compatibil determinat")
            x = None
            return x

    # x = np.zeros((n, 1))
    x = np.zeros(n)
    x[n - 1] = 1 / A[n - 1][n - 1] * b[n - 1]
    k = n - 2
    while k >= 0:
        sum = 0
        for i in range(k + 1, n):
            sum += A[k][i] * x[i]
        x[k] = 1 / A[k][k] * (b[k] - sum)
        k = k - 1
    return x

def gaussPT(A, b):
        """
        param A: matricea asoc sistemului, patratica
        param b: vectorul term liberi
        param tol: val cu care comparam nr nenule
        return x: solutia sistemului
        """

        m, n = np.shape(A)
        if m != n:
            print("Matricea nu este patratica. Introduceti o alta matrice.")
            x = None
            return x
        # Pas 1
        auxNumerotare = np.zeros(n)
        for i in range(n):
            auxNumerotare[i] = i
        A_extins = np.concatenate((A, b), axis=1)  # axis=0 l-ar pune pe b o noua linie, 1 il pune drept coloana
        A_extins = A_extins.astype(float)
        # indexi = 1

        # Pas 2
        for k in range(n - 1):
            max = A_extins[k][k]
            p = k
            m = k
            for i in range(k, n):
                for j in range(k, n):
                    if abs(A_extins[i][j]) > abs(max):
                        max = A_extins[i][j]
                        p = i
                        m = j

            if abs(max) <= (10 ** (-16)):
                print("Sistem incompatibil sau compatibil nedeterminat")
                x = None
                return x

            if (p != k):
                A_extins[[p, k]] = A_extins[[k, p]]  # swap linia p cu linia k

            if m != k:
                A_extins[:, [m, k]] = A_extins[:, [k, m]]
                auxNumerotare[[m, k]] = auxNumerotare[[k, m]]
            #     schimbam coloana m cu coloana k
            #     aux = np.zeros(n)
            #     for a in range(n):
            #         aux[a] = A_extins[a][m]
            #     for a in range(n):
            #         A_extins[a][m] = A_extins[a][k]
            #     for a in range(n):
            #         A_extins[a][k] = aux[a]

            for l in range(k + 1, n):
                mlk = A_extins[l][k]/A_extins[k][k]
                A_extins[l] = A_extins[l] - mlk * A_extins[k]
                # A_extins[l, k+1:n] = A_extins[l, k+1:n] - mlk * A_extins[k, k+1:n]

        if abs(A_extins[n - 1][n - 1]) <= (10 ** (-16)):
            print("Sistem incompatibil sau compatibil nedeterminat")
            x = None
            return x

        tol = 10 ** -16
        x = np.zeros(n)
        y = metSubsDesc(A_extins[:, 0:n], A_extins[:, n], tol)
        # print(y)
        for i in range(n):
            x[i] = y[int(auxNumerotare[i])]
        return y

n = 15
A = np.zeros((n, n))
for i in range(1, n-1):
    A[i][i] = 15
    A[i][i-1] = -4
    A[i][i+1] = -5

A[0][0] = A[n-1][n-1] = 15
A[0][1] = -5
A[n-1][n-2] = -4
print(A)
b = np.zeros((n, 1))
b[0][0] = b[n-1][0] = 2
for i in range(1, n-2):
    b[i][0] = 1
# A = np.array([[1., 10 ** -16], [1., 1.]])
# b = np.array([[10 ** -16], [2.]])
sol = gaussPT(A, b)
print(sol)

###########################################################################
# Exercitiul 3
print("Ex3")
def gaussPp(A, b, tol):
    """
    param A: matricea asoc sistemului, patratica
    param b: vectorul term liberi
    param tol: val cu care comparam nr nenule
    return x: solutia sistemului
    """

    m, n = np.shape(A)
    if m != n:
        print("Matricea nu este patratica. Introduceti o alta matrice.")
        x = None
        return x
    # Pasul 1: concatenam matricea A cu matricea termenilor liberi
    A_extins = np.concatenate((A, b), axis=1)  # axis=0 l-ar pune pe b o noua linie, 1 il pune drept coloana
    # Pasul 2:
    for k in range(1, n-1):
        max = A_extins[k][k]
        print(k)
        p = k
        for j in range(k + 1, n):
            if abs(A_extins[j][k]) > abs(max):
                max = A_extins[j][k]
                p = j

        if abs(max) <= tol:
            print("Sistemul nu admite solutie unica")
            x = None
            return x

        if (p != k):
            A_extins[[p, k]] = A_extins[[k, p]]  # swap linia p cu linia k

        for j in range(k + 1, n):
            A_extins[j] = A_extins[j] - (A_extins[j][k] / A_extins[k][k]) * A_extins[k]
        print("\nMatricea extinsa dupa iteratia k = {}".format(k))
        print(A_extins)

    if abs(A_extins[n - 1][n - 1]) <= tol:
        print("Sistemul nu admite solutie unica")
        x = None
        return x

    x = metSubsDesc(A_extins[:, 0:n], A_extins[:, n], tol)
    return x

# A = [[3, 8, 5], [3, 28, 23], [3, 3, 1]]
# b = [[18], [76], [4]]
# tol = 10 ** (-16)
# gaussPp(A, b, tol)

A = [[0., 1., 2.], [1., 0., 1.], [3., 2., 1.]]
b = [[8.], [4.], [10.]]
tol = 10 ** (-16)
solEx3 = gaussPp(A, b, tol)
print(solEx3)