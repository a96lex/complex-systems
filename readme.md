### Complex systems ![repo size](https://img.shields.io/github/languages/code-size/a96lex/complex-systems) ![line count](https://img.shields.io/tokei/lines/github/a96lex/complex-systems)

# SIR simulator

### How to use

##### Compilation

```
gfortran -o main.x main.f90
```

##### Usage

```
main.x <filename> <initial_infected_rate> <lambda> <delta>
```

- filename: name of the file containing pairs of connected nodes
- initial infected rate: range 0-1
- lambda: infection parameter
- delta: recovery parameter
