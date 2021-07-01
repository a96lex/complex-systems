### Complex systems ![repo size](https://img.shields.io/github/languages/code-size/a96lex/complex-systems) ![line count](https://img.shields.io/tokei/lines/github/a96lex/complex-systems)

# SIR simulator

### How to use

##### Compilation

```
gfortran -o main.x main.f90
```

##### Usage

```
./main.x <filename> <initial_infected_rate> <lambda> <delta> <iterations>
```

- filename: name of the file containing pairs of connected nodes (string)
- initial infected rate: range 0-1 (float)
- lambda: infection parameter (float)
- delta: recovery parameter (float)
- iterations: total iterations to perform (integer)
