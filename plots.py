import os
import re
import matplotlib.pyplot as plt


class iInput:
    """
    Interface of input parameters for executing Fortran code
    """

    filename = "net50000.dat"
    initial_infected_rate = 0.01
    _lambda = 0.0015
    delta = 0.5
    iterations = 20


def execute_cmd(input=iInput()):
    """
    Executes fortran code with set interface
    """
    command = f"./main.x {input.filename} {input.initial_infected_rate} {input._lambda} {input.delta} {input.iterations}"
    os.system(command)


def parse_output(input_file=""):
    """
    Parses the optput file generated in Fortran
    Takes filename as input and returns np arrays as output for S, I and R
    """

    S, I, R = [], [], []

    try:
        file_list = open(input_file, "r")
        lines = file_list.readlines()
        file_list.close()
    except Exception as e:
        print(e)
        lines = []

    for line in lines:
        s = re.findall(r"[-+]?\d*\.\d+|\d+", line)
        S.append(float(s[0]))
        I.append(float(s[1]))
        R.append(float(s[2]))

    return S, I, R


def sir_over_time():
    # create Fortran interface object
    i = iInput()
    i.iterations = 100

    # create a plot for each input interface
    for _ in range(1):
        execute_cmd(input=i)
        S, I, R = parse_output(input_file="sir.out")
        plt.plot(S, label="S")
        plt.plot(I, label="I")
        plt.plot(R, label="R")

        # modify interface
        i._lambda += 0.02

    plt.ylabel("Population")
    plt.xlabel("Time (arbitrary)")
    plt.legend()
    plt.savefig("figures/sir_over_time.png")
    plt.close()


def labda_dependency():
    # create Fortran interface object
    i = iInput()

    # create a plot for each input interface
    for _ in range(5):
        execute_cmd(input=i)
        S, I, R = parse_output(input_file="sir.out")
        plt.plot(I, label=f"lambda: {i._lambda}")
        # modify interface
        i._lambda += 0.02

    plt.ylabel("Infected")
    plt.xlabel("time")
    plt.legend()
    plt.savefig("figures/lambda_dependency.png")
    plt.close()

def recovery_dependency():
    # create Fortran interface object
    i = iInput()
    lamb = []
    Rt= []
    # create a plot for each input interface
    for _ in range(5):
        execute_cmd(input=i)
        S, I, R = parse_output(input_file="sir.out")
        Rf = R[-1]
        Rt.append(Rf)
        lamb.append(i._lambda)

        # modify interface
        i._lambda += 0.02

    plt.plot(lamb, Rt )
    plt.ylabel("Total Infected")
    plt.xlabel("Lambda")
   
    plt.savefig("figures/recovery_dependency.png")
    plt.close()


if __name__ == "__main__":
    os.system("gfortran -o main.x main.f90")
    sir_over_time()
    labda_dependency()
    recovery_dependency()
