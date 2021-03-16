import numpy as np

# Ex 2
d = 15
f = -5
c = -4
n = 15

# Date de intrare
A = np.zeros((n, n))
A[0][0] = A[n-1][n-1] = d
A[0][1] = f
A[n-1][n-2] = c
b = np.zeros(n)
b[0] = b[n-1] = 2
for i in range(1, n-1):
    A[i][i] = d
    A[i][i+1] = f
    A[i][i-1] = c
    b[i] = 1
print(A)
print(b)

# Construim matricele L si R
L = np.zeros((n, n))
R = np.zeros((n, n))

R[0][0] = A[0][0]
for i in range(0, n-2):
    L[i][i] = 1
    # L[i-1][i] = li = ci/ri
    L[i+1][i] = A[i+1][i]/R[i][i]
    # R[i][i+1] = si = bi
    R[i][i + 1] = b[i]
    # R[i+1][i+1] = ri+1= ai+1 - li * si
    R[i + 1][i + 1] = A[i+1][i+1] - L[i+1][i] * R[i][i+1]

L[n-2][n-2] = L[n-1][n-1] = 1
L[n-1][n-2] = A[n-1][n-2]/R[n-2][n-2]
R[n-2][n-1] = b[n-1]
R[n-1][n-1] = A[n-1][n-1] - L[n-1][n-2] * R[n-2][n-1]
print(L)
print(R)

# Aflam vectorul y
y = np.zeros(n)
y[0] = b[0]
for i in range(1, n):
    y[i] = b[i] - L[i][i-1]*y[i-1]
print(y)

# Aflam vectorul x
x = np.zeros(n)
x[n-1] = (b[n-1] - L[n-1][n-2] * y[n-2])/R[n-1][n-1]
for i in range(n-1, 0, -1):
    print(i)
    x[i-1] = (b[i-1] - L[i-1][i-2]*y[i-2] - R[i-1][i]*x[i])/R[i-1][i-1]
print(x)

# Verificari
print(R@x)
print(y)

print(L@y)
print(b)

# -----------------------------------------------------
# #  ex 3
# Introducere date
A = np.array([[6, 5, 6],
              [2, 1, 1],
              [6, 5, 7]])
n = 3
col1 = col2 = col3 = [0, 0, 0]
colI31 = [1, 0, 0]
colI32 = [0, 1, 0]
colI33 = [0, 0, 1]

# ex 4
n = 10
b = np.zeros(n)
for i in range(0, n-1):
    b[i] = i*i*i + 2
a_aux = np.array([i for i in range(n, 0, -1)])
print(a_aux)
a = np.transpose(a_aux)
print(a)
A = np.zeros((n, n))
n1 = round(n/2)
for i in range(0, n-2):
    A[i][i] = a[0]
    for j in range(1, n1):
        A[i][i-j] = A[i+j][i] = a[i+1]
print(A)