from sklearn.linear_model import LinearRegression


def linearFit(x, y):
    """
    Return slope, intercept and a lambda function for the linear fit
    """
    model = LinearRegression().fit(x.reshape(-1, 1), y.reshape(-1, 1))

    return model.coef_, model.intercept_, lambda x: model.predict(x.reshape(-1, 1))


import numpy as np

maximums = np.loadtxt("maximums.dat")

L, T_max_C, errC, T_max_X, errX, maxC, maxX, critMagabsC, critMagabsX = maximums.T

plots = [
    [np.log(T_max_C - 2.266), np.log(L)],
    [np.log(T_max_X - 2.266), np.log(L)],
    [np.log(maxC), np.log(L)],
    [np.log(critMagabsC), np.log(L)],
    [np.log(critMagabsX), np.log(L)],
    [np.log(maxX), np.log(L)],
]

names = [
    ["log(T_max_C - 2.266)", "log(L)"],
    ["log(T_max_X - 2.266)", "log(L)"],
    ["log(maxC)", "log(L)"],
    ["log(critMagabsC)", "log(L)"],
    ["log(critMagabsX)", "log(L)"],
    ["log(maxX)", "log(L)"],
]


newX = np.linspace(2, 4.5, 100)
for i, (y, x) in enumerate(plots):
    slope, intercept, fit = linearFit(x, y)
    print("Fit for plot {}: ".format(i), slope, intercept)
    newY = fit(newX)
    np.savetxt(
        f"exponents/fit_{names[i][0]}[{names[i][1]}].dat",
        np.column_stack((newX, newY)),
        header=f"{names[i][0]} -- {names[i][1]} slope={slope} intercept={intercept}",
    )
