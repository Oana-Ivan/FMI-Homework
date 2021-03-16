# CN - Tema 4
# Ivan Oana-Mariana, 341

import numpy as np
import sympy as sym

# Ex 2

# datele problemei
a = 1
b = 4
def f(x):
    return x ** 2 + 4 * x + 1

# punctul a)

def Integrare(f, a, b, metoda):

    if metoda == "dreptunghi":
        I = 2 * ((b - a) / 2) * f((a + b) / 2)
    elif metoda == "trapez":
        I = ((b - a) / 2) * (f(a) + f(b))
    elif metoda == "Simpson":
        I = ((b - a) / 6) * (f(a) + 4 * f((a + b) / 2) + f(b))
    elif metoda == "Newton":
        I = ((b - a) / 8) * ((-1) * f(a) + 3 * f((2 * a + b) / 3) + 3 * f((a + 2 * b) / 3) + f(b))
    else:
        print("Introduceti o optiune valida pt metoda!")
        return
    return I

# punctul b)
# # init_printing(use_unicode=False, wrap_line=False)
x = sym.Symbol('x')
I = sym.integrate(f(x), (x, a, b))
print(I)

# punctul c)
print("Valori absolute")

print("Dreptunghi:")
Idreptunghi = Integrare(f, a, b, "dreptunghi")
absDreptunghi = np.abs(I - Idreptunghi)
print(absDreptunghi)

print("Trapez:")
Itrapez = Integrare(f, a, b, "trapez")
absTrapez = np.abs(I - Itrapez)
print(absTrapez)

print("Simpson:")
ISimpson = Integrare(f, a, b, "Simpson")
absSimpson = np.abs(I - ISimpson)
print(absSimpson)

print("Newton:")
INewton = Integrare(f, a, b, "Newton")
absNewton = np.abs(I - INewton)
print(absNewton)

# Ex 3
n = 20
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

# def metSubsDesc(A, b, tol):
#     """
#     param A: matrice patratica, superior triunghiulara, cu toate elem pe diag princ
#     ipala nenule
#     param b: vectorul term liberi
#     param tol: val numerica ft mica in rap cu care vom compara numerele apropiate d
#     e 0
#     return: sol sistem
#     """
#     m, n = np.shape(A)
#     if m != n:
#         print("Matricea nu este patratica. Introduceti o alta matrice.")
#         x = None
#         return x
#     #Verificam daca matricea este superior triunghiulara
#     for i in range(m):
#         for j in range(i):
#             if abs(A[i][j]) > tol:
#                 print("Matricea nu este superior triunghiulara")
#                 x = None
#                 return x
#     #Verificam daca elementele de pe diagonala principala sunt nule (sist comp det)
#     for i in range(n):
#         if A[i][i] == 0:
#             print("Sistemul nu este compatibil determinat")
#             x = None
#             return x
#     x = np.zeros((n,1))
#     x[n-1] = 1 / A[n-1][n-1] * b[n-1]
#     k = n-2
#     while k >= 0:
#         sum = 0
#         for i in range(k+1, n):
#             sum += A[k][i] * x[i]
#         x[k] = 1 / A[k][k] * (b[k] - sum)
#     k = k - 1
#     return x
# def gaussPp(A, b, tol):
#     """
#     param A: matricea asoc sistemului, patratica
#     param b: vectorul term liberi
#     param tol: val cu care comparam nr nenule
#     return x: solutia sistemului
#     m, n = np.shape(A)
#     """
#     m, n = np.shape(A)
#     if m != n:
#         print("Matricea nu este patratica. Introduceti o alta matrice.")
#         x = None
#         return x
#     A_extins = np.concatenate((A, b), axis=1) #axis=0 l-ar pune pe b o noua linie, 1 il pune drept coloana
#     for k in range(n-1):
#         max = A_extins[k][k]
#         p = k
#         for j in range(k+1, n):
#             if abs(A_extins[j][k]) > abs(max):
#                 max = A_extins[j][k]
#                 p = j
#         if abs(max) <= tol:
#             print("Sistemul nu admite solutie unica")
#             x = None
#             return x
#         if (p != k):
#             A_extins[[p, k]] = A_extins[[k, p]] #swap linia p cu linia k
#         for j in range(k+1, n):
#             A_extins[j] = A_extins[j] - (A_extins[j][k] / A_extins[k][k]) * A_extins[k]
#     if abs(A_extins[n-1][n-1]) <= tol:
#         print("Sistemul nu admite solutie unica")
#         x = None
#         return x
#     x = metSubsDesc(A_extins[:, 0:n], A_extins[:, n], tol)
#     return x


# Regresie liniara
def f_lin (x):
    return 2 * x + 3

x_lin = np.arange(n)
y_lin = np.random.rand(n)

sum_xi = 0
sum_yi = 0
sum_xi_patrat = 0
sum_prod = 0

for i in range(n):
    sum_xi = sum_xi + x_lin[i]
    sum_yi = sum_yi + y_lin[i]
    sum_xi_patrat = sum_xi_patrat + x_lin[i] * x_lin[i]
    sum_prod = sum_prod + x_lin[i] * y_lin[i]

A = np.array([[sum_xi_patrat, sum_xi],
              [sum_xi, n]])
w = np.array([[sum_prod], [sum_yi]])

print(A)
print(w)

rezultat = gaussPp(A, w, 10 ** (-16))

# Regresie polinomiala
def f_patratica(x):
    return x * x + 2

x_patratic = np.arange(n)
y_patratic = np.random.rand(1, n)

sum_xi = 0
sum_yi = 0
sum_xi_patrat = 0
sum_xi_treia = 0
sum_xi_patra = 0
sum_prod = 0
sum_prod_x_patrat = 0

for i in range(n):
    sum_xi = sum_xi + x_lin[i]
    sum_yi = sum_yi + y_lin[i]
    sum_xi_patrat = sum_xi_patrat + x_lin[i] ** 2
    sum_xi_treia = sum_xi_treia + x_lin[i] ** 3
    sum_xi_patra = sum_xi_patra + x_lin[i] ** 4
    sum_prod = sum_prod + x_lin[i] * y_lin[i]
    sum_prod = sum_prod + (x_lin[i] ** 2) * y_lin[i]

A = np.array([[sum_xi_patra, sum_xi_treia, sum_xi_patrat],
              [sum_xi_treia, sum_xi_patrat, sum_xi],
              [sum_xi_patrat, sum_xi, n]])
w = np.array([[sum_prod_x_patrat], [sum_prod], [sum_yi]])

print("Matricea A:")
print(A)
print("w:")
print(w)

rezultatP = gaussPp(A, w, 10 ** (-16))
print(rezultatP)

# gradul polinomului
m = 2

# Regresie exponentiala
def f_exp(x):
    return 2 ** x + 3

x_exp = np.random.rand(1, n)
y_exp = np.random.rand(1, n)
