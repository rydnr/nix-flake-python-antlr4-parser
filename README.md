# Nix flake ANTLR4 parser

Experimental ANTLR4 parser for [Nix](https://nixos.org "Nix") [flakes](https://nixos.org/manual/nix/unstable/command-ref/new-cli/nix3-flake "flakes").

Currently, the grammar only tries to extract the flake inputs.

## How to run it

Find out the latest version in <https://github.com/rydnr/nix-flake-python-antlr4-parser/tags>, and use it instead of the `[version]` placeholder below.

``` sh
nix run github:rydnr/nix-flake-to-graphviz/[version]?dir=nix
```

### Usage

``` sh
nix run github:rydnr/nix-flake-to-graphviz/[version]?dir=nix -- [-h|--help] [-v|-vv|-q] [-f|--flake-nix file]
```
- `-h|--help`: Prints the usage.
- `-v|-vv|-q`: The verbosity.
- `-f|--flake-nix`: The flake.nix file to analyze.

