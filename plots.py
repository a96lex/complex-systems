import os
import re
import matplotlib.pyplot as plt


class iInput:
    """
    Interface of input parameters for executing Fortran code
    """

    filename = "nets/net1000.dat"
    initial_infected_rate = 0.01
    _lambda = 0.007
    delta = 0.7
    iterations = 20


def parse_output(input_file=""):
    """
    Parses the optput file generated in Fortran
    Takes filename as input and returns np arrays as output for S, I and R
    """

    S = []
    I = []
    R = []

    try:
        file_list = open(input_file, "r")
        lines = file_list.readlines()
    except Exception as e:
        print(e)
        lines = []

    for line in lines:
        s = re.findall(r"[-+]?\d*\.\d+|\d+", line)
        S.append(float(s[0]))
        I.append(float(s[1]))
        R.append(float(s[2]))

    return S, I, R


def main():
    # create Fortran interface object
    i = iInput()

    # create a plot for each input interface
    for _ in range(5):
        os.system(
            f"./main.x {i.filename} {i.initial_infected_rate} {i._lambda} {i.delta} {i.iterations}"
        )
        S, I, R = parse_output(input_file="sir.out")
        plt.plot(I, label=f"lambda: {i._lambda}")

        # modify interface
        i._lambda += 0.02

    plt.ylabel("Infected")
    plt.xlabel("time")
    plt.legend()
    plt.show()


if __name__ == "__main__":
    main()
