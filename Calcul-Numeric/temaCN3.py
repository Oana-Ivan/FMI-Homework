# Calcul Numeric
# Ivan Oana, varianta 2, 341

import numpy as np
from sympy import *
import matplotlib.pyplot as plt

# Ex 1.1.
n = 10

b = np.zeros(n)
for i in range(1, n + 1):
    b[i - 1] = i ** 3 + 2
print("b:")
print(b)

a_prim = np.zeros((1, n))
for i in range(0, n):
    a_prim[0][i] = (n - i)
a = np.transpose(a_prim)
print("a: ")
print(a)

A = np.zeros((n, n))
k = 0
for i in range(n):
    # k = 0
    A[i][i] = a[0][0]
    for j in range(1, n - i):
        A[i][i + j] = a[j][0]
for j in range(n):
    k = 1
    for i in range(j + 1, n):
        A[i][j] = a[k][0]
        k += 1
print("A:")
print(A)

# Ex 1.2.
def CritSylvester(A):
    (n, m) = np.shape(A)
    for i in range(m):
        minor = A[:(i+1), :(i+1)]
        if np.linalg.det(minor) <= 0:
            return False
    return True

if CritSylvester(A):
    print("A este pozitiv definita")
else:
    print("A nu este pozitiv definita")

# Ex 1.3.

def GradConjugat(A, b, eps, X):

    necunoscute = [] # vector cu [x1, x2, ..]
    for i in range(n):
        necunoscute.append(Symbol('x' + str(i + 1)))

    # Calcul f conform formulei din cursul 7 pentru f(X, Y)
    functie = 1 / 2 * np.dot(np.resize(A@necunoscute, n), np.resize(necunoscute, n)) -\
              np.dot(np.resize(b, n), np.resize(necunoscute, n))

    aux = []
    for i in range(n):
        aux.append(functie.diff(Symbol('x' + str(i + 1))))

    g = lambdify([tuple(necunoscute)], aux, "numpy")
    v_x = g(X)

    v = []
    for i in range(n):
        v.append(v_x[i][0])
    v = np.array(v)
    r = b - A@X

    for k in range(n):
        # formula pentru alpha
        a = -1 * np.dot(np.resize(v, n), np.resize(r, n)) / np.dot(np.resize(v, n), np.resize(A@v, n))
        # calcul x in functie de alpha:
        X = X - np.resize(a * v, (n, 1))

        # formula pentru beta
        b = np.dot(np.resize(r, n), np.resize(A@v, n)) / np.dot(np.resize(v, n), np.resize(A@v, n))
        # calcul v in functie de beta:
        v = -1 * r + np.resize(b * v, (n, 1))

        aux1 = g(X)

        # calcul || sigmaf|x^(k) ||
        sigma = 0
        for i in range(n):
            sigma += aux1[i][0] ** 2
        sigma = np.sqrt(sigma)

        # algoritmul se repeta pana cand sigma < epsilon
        if sigma < eps:
            break

    return X

# Ex 1.3.

# X ia valori random
X = np.random.randint(10, size=(n, 1)) # X^(0)
rezultat = GradConjugat(A, b, 10 ** (-10), X)
print(A@rezultat)
# import sympy.utilities.lambdify as lambdify

# import sympy as sym
# import test as mnea

# Ex 3
a_interval = -4
b_interval = 3
c_interval = -2
d_interval = 5

# Date din exercitiul 2
def f(x, y):
    return 3/2 * x ** 2 + 2 * x * y - x + 3/2 * y ** 2 - 3 * y
A = np.array([[3, 2],
              [2, 3]])
b = np.array([1, 3])

#  Construire suprafata z
(Nx, Ny) = (20, 20)
x_grafic = np.linspace(a_interval, b_interval, Nx)
y_grafic = np.linspace(c_interval, d_interval, Ny)
[X, Y] = np.meshgrid(x_grafic, y_grafic)
Z = f(X, Y)

fig = plt.figure(1)
axes = plt.axes(projection='3d')
surf = axes.plot_surface(X, Y, Z, cmap = plt.cm.jet)
fig.colorbar(surf)
plt.show()

# Aplicare GradientConjugat
x0 = np.transpose(np.linspace(a_interval, c_interval))
# x1 = GradConjugat(A, b, 10 ** (-10), x0)
# x2 = GradConjugat(A, b, 10 ** (-10), x1)

# Punctul de extrem = minim intre x1 si x2


# Ex 4
x = np.array([-2, 1, 3, 7])
y = np.array([5, 7, 11, 34])
n = len(X)
# ex 4. a.
def MetNewton(X, Y, x):
    c = np.zeros(n)
    c[0] = Y[0]

    for i in range(1, n):
        sum = c[0]
        for j in range(1, i - 1):
            t = 1
            if i - 1 > 1:
                for k in range(1, i - 1):
                    t *= (x - X[k])
            sum += c[j] * t

        t = 1
        for k in range(1, i - 1):
            t *= (x - X[k])

        c[i] = (y[i] - sum) / t

    # Calcul p
    p = c[0]
    for i in range(1, n):
        t = 1
        for k in range(1, i - 1):
            t *= (x - X[k])
        p += c[i] * t

    return p
#
# def f(x):
#     return x
#
# def dd(xs):
#     l = len(xs)
#     if l == 1:
#         return f(xs[0])
#     f1 = np.zeros(l - 1)
#     f2 = np.zeros(l - 1)
#
#     for i in range(l - 1):
#         f1[i] = xs[i + 1]
#         f2[i] = xs[i]
#
#     s = dd(f1) - dd(f2)
#     j = X[l - 1] - X[0]
#
#     return s/j

# Ex 4. b.
def MetNewtonDD(X, Y, x):
    valori = np.zeros((n, n - 1))
    for i in range(1, n):
        for j in range(n - i):
            valori[j][i] = ((valori[j][i - 1] - valori[j + 1][i - 1]) /
                       (x[j] - x[i + j]))

    p = valori[0][0]

    for i in range(1, n):
        aux = 1
        for j in range(i):
            aux = aux * (x - X[j])
        p += (aux * valori[0][i])

    return p
