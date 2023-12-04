# flake.nix
#
# This file packages the ANTLR4 nix-flake parser as a Nix flake.
#
# Copyright (C) 2023-today rydnr's rydnr/nix-flake-python-antlr4-parser
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <https://www.gnu.org/licenses/>.
{
  description = "Experimental Python package to parse Nix flakes";
  inputs = rec {
    flake-utils.url = "github:numtide/flake-utils/v1.0.0";
    nixos.url = "github:NixOS/nixpkgs/nixos-23.05";
    pythoneda-shared-pythoneda-banner = {
      inputs.flake-utils.follows = "flake-utils";
      inputs.nixos.follows = "nixos";
      url = "github:pythoneda-shared-pythoneda-def/banner/0.0.28";
    };
    pythoneda-shared-pythoneda-domain = {
      inputs.flake-utils.follows = "flake-utils";
      inputs.nixos.follows = "nixos";
      inputs.pythoneda-shared-pythoneda-banner.follows =
        "pythoneda-shared-pythoneda-banner";
      url = "github:pythoneda-shared-pythoneda-def/domain/0.0.3";
    };
  };
  outputs = inputs:
    with inputs;
    let
      defaultSystems = flake-utils.lib.defaultSystems;
      supportedSystems = if builtins.elem "armv6l-linux" defaultSystems then
        defaultSystems
      else
        defaultSystems ++ [ "armv6l-linux" ];
    in flake-utils.lib.eachSystem supportedSystems (system:
      let
        org = "rydnr";
        repo = "nix-flake-python-antlr4-parser";
        version = "0.0.1";
        pname = "${org}-${repo}";
        pkgs = import nixos { inherit system; };
        description = "Experimental Python package to parse Nix flakes";
        license = pkgs.lib.licenses.gpl3;
        homepage = "https://github.com/rydnr/nix-flake-python-antlr4-parser";
        maintainers = [ "rydnr <github@acm-sl.org>" ];
        archRole = "S";
        space = "D";
        layer = "D";
        nixosVersion = builtins.readFile "${nixos}/.version";
        nixpkgsRelease =
          builtins.replaceStrings [ "\n" ] [ "" ] "nixos-${nixosVersion}";
        shared = import "${pythoneda-shared-pythoneda-banner}/nix/shared.nix";
        antlr4-nix-flake-for = { antlr4-python-runtime, python }:
          let
            pnameWithUnderscores =
              builtins.replaceStrings [ "-" ] [ "_" ] pname;
            pythonpackage = "rydnr.antlr4.nix_flake";
            pythonVersionParts = builtins.splitVersion python.version;
            pythonMajorVersion = builtins.head pythonVersionParts;
            pythonMajorMinorVersion =
              "${pythonMajorVersion}.${builtins.elemAt pythonVersionParts 1}";
            wheelName =
              "${pnameWithUnderscores}-${version}-py${pythonMajorVersion}-none-any.whl";
          in python.pkgs.buildPythonPackage rec {
            inherit pname version;
            projectDir = ./.;
            pyprojectTemplateFile = ./pyprojecttoml.template;
            pyprojectTemplate = pkgs.substituteAll {
              antlr4PythonRuntime = antlr4-python-runtime.version;
              authors = builtins.concatStringsSep ","
                (map (item: ''"${item}"'') maintainers);
              desc = description;
              inherit homepage pname pythonMajorMinorVersion pythonMajorVersion
                pythonpackage version;
              package = builtins.replaceStrings [ "." ] [ "/" ] pythonpackage;
              src = pyprojectTemplateFile;
            };
            src = ./.;
            g4 = ./src/NixFlake.g4;
            format = "pyproject";

            nativeBuildInputs = with python.pkgs; [
              pip
              pkgs.jq
              poetry-core
              pkgs.antlr4
            ];
            propagatedBuildInputs = with python.pkgs; [ antlr4-python-runtime ];

            pythonImportsCheck = [ pythonpackage ];

            unpackPhase = ''
              cp -r ${src} .
              sourceRoot=$(ls | grep -v env-vars)
              chmod +w $sourceRoot
              cp ${g4} $sourceRoot/NixFlake.g4;
              cp ${pyprojectTemplate} $sourceRoot/pyproject.toml
              mkdir -p $sourceRoot/rydnr/antlr4/nix_flake/generated
              chmod -R +w $sourceRoot
              pushd $sourceRoot
              ls -lrthlia
              ${pkgs.antlr4}/bin/antlr4 -Dlanguage=Python${pythonMajorVersion} NixFlake.g4
              mv *.py *.tokens *.interp rydnr/antlr4/nix_flake/generated/
              popd
            '';

            postInstall = ''
              pushd /build/$sourceRoot
              for f in $(find . -name '__init__.py'); do
                if [[ ! -e $out/lib/python${pythonMajorMinorVersion}/site-packages/$f ]]; then
                  cp $f $out/lib/python${pythonMajorMinorVersion}/site-packages/$f;
                fi
              done
              popd
              mkdir $out/dist
              cp dist/${wheelName} $out/dist
              jq ".url = \"$out/dist/${wheelName}\"" $out/lib/python${pythonMajorMinorVersion}/site-packages/${pnameWithUnderscores}-${version}.dist-info/direct_url.json > temp.json && mv temp.json $out/lib/python${pythonMajorMinorVersion}/site-packages/${pnameWithUnderscores}-${version}.dist-info/direct_url.json
            '';

            meta = with pkgs.lib; {
              inherit description homepage license maintainers;
            };
          };
      in rec {
        defaultPackage = packages.default;
        devShells = rec {
          default = antlr4-nix-flake-default;
          antlr4-nix-flake-default = antlr4-nix-flake-python311;
          antlr4-nix-flake-python38 = shared.devShell-for {
            banner = "${
                pythoneda-shared-pythoneda-banner.packages.${system}.pythoneda-shared-pythoneda-banner-python38
              }/bin/banner.sh";
            extra-namespaces = "";
            nixpkgs-release = nixpkgsRelease;
            package = packages.antlr4-nix-flake-python38;
            pythoneda-shared-pythoneda-banner =
              pythoneda-shared-pythoneda-banner.packages.${system}.pythoneda-shared-pythoneda-banner-python38;
            pythoneda-shared-pythoneda-domain =
              pythoneda-shared-pythoneda-domain.packages.${system}.pythoneda-shared-pythoneda-domain-python38;
            python = pkgs.python38;
            inherit archRole layer org pkgs repo space;
          };
          antlr4-nix-flake-python39 = shared.devShell-for {
            banner = "${
                pythoneda-shared-pythoneda-banner.packages.${system}.pythoneda-shared-pythoneda-banner-python39
              }/bin/banner.sh";
            extra-namespaces = "";
            nixpkgs-release = nixpkgsRelease;
            package = packages.antlr4-nix-flake-python39;
            pythoneda-shared-pythoneda-banner =
              pythoneda-shared-pythoneda-banner.packages.${system}.pythoneda-shared-pythoneda-banner-python39;
            pythoneda-shared-pythoneda-domain =
              pythoneda-shared-pythoneda-domain.packages.${system}.pythoneda-shared-pythoneda-domain-python39;
            python = pkgs.python39;
            inherit archRole layer org pkgs repo space;
          };
          antlr4-nix-flake-python310 = shared.devShell-for {
            banner = "${
                pythoneda-shared-pythoneda-banner.packages.${system}.pythoneda-shared-pythoneda-banner-python310
              }/bin/banner.sh";
            extra-namespaces = "";
            nixpkgs-release = nixpkgsRelease;
            package = packages.antlr4-nix-flake-python310;
            pythoneda-shared-pythoneda-banner =
              pythoneda-shared-pythoneda-banner.packages.${system}.pythoneda-shared-pythoneda-banner-python310;
            pythoneda-shared-pythoneda-domain =
              pythoneda-shared-pythoneda-domain.packages.${system}.pythoneda-shared-pythoneda-domain-python310;
            python = pkgs.python310;
            inherit archRole layer org pkgs repo space;
          };
          antlr4-nix-flake-python311 = shared.devShell-for {
            banner = "${
                pythoneda-shared-pythoneda-banner.packages.${system}.pythoneda-shared-pythoneda-banner-python311
              }/bin/banner.sh";
            extra-namespaces = "";
            nixpkgs-release = nixpkgsRelease;
            package = packages.antlr4-nix-flake-python311;
            pythoneda-shared-pythoneda-banner =
              pythoneda-shared-pythoneda-banner.packages.${system}.pythoneda-shared-pythoneda-banner-python311;
            pythoneda-shared-pythoneda-domain =
              pythoneda-shared-pythoneda-domain.packages.${system}.pythoneda-shared-pythoneda-domain-python311;
            python = pkgs.python311;
            inherit archRole layer org pkgs repo space;
          };
        };
        packages = rec {
          default = antlr4-nix-flake-default;
          antlr4-nix-flake-default = antlr4-nix-flake-python311;
          antlr4-nix-flake-python38 = antlr4-nix-flake-for {
            antlr4-python-runtime = pkgs.python38.pkgs.antlr4-python3-runtime;
            python = pkgs.python38;
          };
          antlr4-nix-flake-python39 = antlr4-nix-flake-for {
            antlr4-python-runtime = pkgs.python39.pkgs.antlr4-python3-runtime;
            python = pkgs.python39;
          };
          antlr4-nix-flake-python310 = antlr4-nix-flake-for {
            antlr4-python-runtime = pkgs.python310.pkgs.antlr4-python3-runtime;
            python = pkgs.python310;
          };
          antlr4-nix-flake-python311 = antlr4-nix-flake-for {
            antlr4-python-runtime = pkgs.python311.pkgs.antlr4-python3-runtime;
            python = pkgs.python311;
          };
        };
      });
}
