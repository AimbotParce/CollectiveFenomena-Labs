from sklearn.linear_model import LinearRegression


def linearFit(x, y):
    """
    Return slope, intercept and a lambda function for the linear fit
    """
    model = LinearRegression().fit(x.reshape(-1, 1), y.reshape(-1, 1))

    return model.coef_, model.intercept_, lambda x: model.predict(x.reshape(-1, 1))


import numpy as np

maximums = np.loadtxt("maximums.dat")

L, TcC, errTcC, TcX, errTcX, maxC, maxX, magabs_Tc_C, magabs_Tc_X = maximums.T

plots = [
    [np.log(TcC - 2.266), np.log(L)],
    [np.log(TcX - 2.266), np.log(L)],
    [np.log(maxC), np.log(L)],
    [np.log(magabs_Tc_C), np.log(L)],
    [np.log(magabs_Tc_X), np.log(L)],
    [np.log(maxX), np.log(L)],
]

names = [
    ["log(TcC - 2.266)", "log(L)"],
    ["log(TcX - 2.266)", "log(L)"],
    ["log(maxC)", "log(L)"],
    ["log(magabs_Tc_C)", "log(L)"],
    ["log(magabs_Tc_X)", "log(L)"],
    ["log(maxX)", "log(L)"],
]


newX = np.linspace(2, 4.5, 100)
for i, (y, x) in enumerate(plots):
    slope, intercept, fit = linearFit(x, y)
    pName = f"{names[i][0]}[{names[i][1]}]"
    print(f"Fit for plot {pName:<30}: slope={slope[0][0]:.3} intercept={intercept[0]:.3}")
    newY = fit(newX)
    np.savetxt(
        f"exponents/fit_{names[i][0]}[{names[i][1]}].dat",
        np.column_stack((newX, newY)),
        header=f"{names[i][0]} -- {names[i][1]} slope={slope} intercept={intercept}",
    )
