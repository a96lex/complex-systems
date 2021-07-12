import os
import re
import matplotlib.pyplot as plt


class iInput:
    """
    Interface of input parameters for executing Fortran code
    """

    def __init__(self) -> None:
        self.base_path = "nets/"
        self._filename = "net1000.dat"
        self.output_path = f"figures/{self.filename.replace('.dat','')}"
        self.initial_infected_rate = 0.01
        self._lambda = 0.0015
        self.delta = 0.5
        self.iterations = 20

    @property
    def filename(self):
        return self._filename

    @filename.setter
    def filename(self, value):
        self._filename = value
        self.output_path = f"figures/{self.filename.replace('.dat','')}"


def execute_cmd(input=iInput()):
    """
    Executes fortran code with set interface
    """
    command = f"./main.x {input.base_path}{input.filename} {input.initial_infected_rate} {input._lambda} {input.delta} {input.iterations}"
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


def sir_over_time(i=iInput()):
    i.iterations = 100
    i._lambda = 0.0015

    # create the plot
    execute_cmd(input=i)
    S, I, R = parse_output(input_file="sir.out")

    plt.plot(S, label="S")
    plt.plot(I, label="I")
    plt.plot(R, label="R")
    plt.ylabel("Population")
    plt.xlabel("Time (arbitrary)")
    plt.legend()
    plt.savefig(f"{i.output_path}/sir_over_time.png")
    plt.close()


def labda_dependency(i=iInput()):
    i._lambda = 0.0015
    # create a plot for each input interface
    for _ in range(5):
        execute_cmd(input=i)
        S, I, R = parse_output(input_file="sir.out")
        plt.plot(I, label=f"lambda: {i._lambda:.4f}")
        # modify interface
        i._lambda += 0.02

    plt.ylabel("Infected")
    plt.xlabel("time")
    plt.legend()
    plt.savefig(f"{i.output_path}/lambda_dependency.png")
    plt.close()


def recovery_dependency(i=iInput()):
    lamb = []
    Rt = []
    # create a plot for each input interface
    for _ in range(25):
        execute_cmd(input=i)
        S, I, R = parse_output(input_file="sir.out")
        Rf = R[-1]
        Rt.append(Rf)
        lamb.append(i._lambda)

        # modify interface
        i._lambda += 0.002

    plt.plot(lamb, Rt)
    plt.ylabel("Total Infected")
    plt.xlabel("Lambda")
    plt.savefig(f"{i.output_path}/recovery_dependency.png")
    plt.close()


def run(input=iInput()):
    sir_over_time(i=input)
    labda_dependency(i=input)
    recovery_dependency(i=input)


if __name__ == "__main__":
    filenames = ["net1000.dat", "net50000.dat"]

    os.system("gfortran -o main.x main.f90")  # compile fortran

    for name in filenames:
        input = iInput()
        input.filename = name
        if not os.path.exists(input.output_path):
            os.makedirs(input.output_path)
        print(f"Creating plots for {name}")
        run(input=input)
