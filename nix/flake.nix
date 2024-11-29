# nix/flake.nix
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
  description = "Nix flake for https://github.com/rydnr/nix-flake-python-antlr4-parser";
  inputs = rec {
    flake-utils.url = "github:numtide/flake-utils/v1.0.0";
    nixos.url = "github:NixOS/nixpkgs/24.05";
    pythoneda-shared-nix-flake-shared = {
      inputs.flake-utils.follows = "flake-utils";
      inputs.nixos.follows = "nixos";
      inputs.pythoneda-shared-pythonlang-banner.follows =
        "pythoneda-shared-pythonlang-banner";
      inputs.pythoneda-shared-pythonlang-domain.follows =
        "pythoneda-shared-pythonlang-domain";
      url = "github:pythoneda-shared-nix-flake-def/shared/0.0.45";
    };
    pythoneda-shared-pythonlang-application = {
      inputs.flake-utils.follows = "flake-utils";
      inputs.nixos.follows = "nixos";
      inputs.pythoneda-shared-pythonlang-banner.follows =
        "pythoneda-shared-pythonlang-banner";
      inputs.pythoneda-shared-pythonlang-domain.follows =
        "pythoneda-shared-pythonlang-domain";
      url = "github:pythoneda-shared-pythonlang-def/application/0.0.57";
    };
    pythoneda-shared-pythonlang-banner = {
      inputs.flake-utils.follows = "flake-utils";
      inputs.nixos.follows = "nixos";
      url = "github:pythoneda-shared-pythonlang-def/banner/0.0.49";
    };
    pythoneda-shared-pythonlang-domain = {
      inputs.flake-utils.follows = "flake-utils";
      inputs.nixos.follows = "nixos";
      inputs.pythoneda-shared-pythonlang-banner.follows =
        "pythoneda-shared-pythonlang-banner";
      url = "github:pythoneda-shared-pythonlang-def/domain/0.0.36";
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
        version = "0.0.5";
        pname = "${org}-${repo}";
        pythonpackage = "rydnr.nix.flake.parser";
        package = builtins.replaceStrings [ "." ] [ "/" ] pythonpackage;
        entrypoint = "nix_flake_python_antlr4_parser";
        description = "Experimental Python package to parse Nix flakes";
        license = pkgs.lib.licenses.gpl3;
        homepage = "https://github.com/rydnr/nix-flake-python-antlr4-parser";
        maintainers = [ "rydnr <github@acm-sl.org>" ];
        archRole = "B";
        space = "D";
        layer = "A";
        nixosVersion = builtins.readFile "${nixos}/.version";
        nixpkgsRelease =
          builtins.replaceStrings [ "\n" ] [ "" ] "nixos-${nixosVersion}";
        shared = import "${pythoneda-shared-pythonlang-banner}/nix/shared.nix";
        pkgs = import nixos { inherit system; };
        nix-flake-python-antlr4-parser-for = { antlr4-python-runtime, python
          , pythoneda-shared-nix-flake-shared
          , pythoneda-shared-pythonlang-application
          , pythoneda-shared-pythonlang-banner
          , pythoneda-shared-pythonlang-domain }:
          let
            pnameWithUnderscores =
              builtins.replaceStrings [ "-" ] [ "_" ] pname;
            pythonVersionParts = builtins.splitVersion python.version;
            pythonMajorVersion = builtins.head pythonVersionParts;
            pythonMajorMinorVersion =
              "${pythonMajorVersion}.${builtins.elemAt pythonVersionParts 1}";
            wheelName =
              "${pnameWithUnderscores}-${version}-py${pythonMajorVersion}-none-any.whl";
            banner_file =
              "${package}/application/nix_flake_python_antlr4_parser_banner.py";
            banner_class = "NixFlakePythonAntlr4ParserBanner";
          in python.pkgs.buildPythonPackage rec {
            inherit pname version;
            projectDir = ../.;
            pyprojectTemplateFile = ./pyprojecttoml.template;
            pyprojectTemplate = pkgs.substituteAll {
              antlr4PythonRuntime = antlr4-python-runtime.version;
              authors = builtins.concatStringsSep ","
                (map (item: ''"${item}"'') maintainers);
              desc = description;
              inherit homepage package pname pythonMajorMinorVersion
                pythonMajorVersion pythonpackage version;
              pythonedaSharedNixFlakeShared =
                pythoneda-shared-nix-flake-shared.version;
              pythonedaSharedPythonlangApplication =
                pythoneda-shared-pythonlang-application.version;
              pythonedaSharedPythonlangBanner =
                pythoneda-shared-pythonlang-banner.version;
              pythonedaSharedPythonlangDomain =
                pythoneda-shared-pythonlang-domain.version;
              src = pyprojectTemplateFile;
            };
            bannerTemplateFile = ../templates/banner.py.template;
            bannerTemplate = pkgs.substituteAll {
              project_name = pname;
              file_path = banner_file;
              inherit banner_class org repo;
              tag = version;
              pescio_space = space;
              arch_role = archRole;
              hexagonal_layer = layer;
              python_version = pythonMajorMinorVersion;
              nixpkgs_release = nixpkgsRelease;
              src = bannerTemplateFile;
            };
            entrypointTemplateFile =
              "${pythoneda-shared-pythonlang-banner}/templates/entrypoint.sh.template";
            entrypointTemplate = pkgs.substituteAll {
              arch_role = archRole;
              hexagonal_layer = layer;
              nixpkgs_release = nixpkgsRelease;
              inherit homepage maintainers org python repo version;
              pescio_space = space;
              python_version = pythonMajorMinorVersion;
              pythoneda_shared_pythoneda_banner =
                pythoneda-shared-pythonlang-banner;
              pythoneda_shared_pythoneda_domain =
                pythoneda-shared-pythonlang-domain;
              src = entrypointTemplateFile;
            };
            src = ../.;
            g4 = ../antlr4/NixFlake.g4;
            format = "pyproject";

            nativeBuildInputs = with python.pkgs; [
              pip
              poetry-core
              pkgs.antlr4
            ];
            propagatedBuildInputs = with python.pkgs; [
              antlr4-python-runtime
              pythoneda-shared-nix-flake-shared
              pythoneda-shared-pythonlang-application
              pythoneda-shared-pythonlang-banner
              pythoneda-shared-pythonlang-domain
            ];

            # pythonImportsCheck = [ pythonpackage ];

            unpackPhase = ''
              cp -r ${src} .
              sourceRoot=$(ls | grep -v env-vars)
              chmod -R +w $sourceRoot
              find $sourceRoot -type d -exec chmod 777 {} \;
              cp ${g4} $sourceRoot/NixFlake.g4;
              cp ${pyprojectTemplate} $sourceRoot/pyproject.toml
              cp ${bannerTemplate} $sourceRoot/${banner_file}
              cp ${entrypointTemplate} $sourceRoot/entrypoint.sh
              ls -lia
              mkdir -p $sourceRoot/rydnr/nix/flake/parser/generated
              chmod -R +w $sourceRoot
              pushd $sourceRoot
              ls -lrthlia
              ${pkgs.antlr4}/bin/antlr4 -Dlanguage=Python${pythonMajorVersion} NixFlake.g4
              mv *.py *.tokens *.interp rydnr/nix/flake/parser/generated/
              popd
            '';

            postPatch = ''
              substituteInPlace /build/$sourceRoot/entrypoint.sh \
                --replace "@SOURCE@" "$out/bin/${entrypoint}.sh" \
                --replace "@PYTHONEDA_EXTRA_NAMESPACES@" "rydnr" \
                --replace "@PYTHONPATH@" "$out/lib/python${pythonMajorMinorVersion}/site-packages:$PYTHONPATH" \
                --replace "@CUSTOM_CONTENT@" "" \
                --replace "@ENTRYPOINT@" "$out/lib/python${pythonMajorMinorVersion}/site-packages/${package}/application/${entrypoint}.py" \
            '';

            postInstall = ''
              pushd /build/$sourceRoot
              for f in $(find . -name '__init__.py'); do
                if [[ ! -e $out/lib/python${pythonMajorMinorVersion}/site-packages/$f ]]; then
                  cp $f $out/lib/python${pythonMajorMinorVersion}/site-packages/$f;
                fi
              done
              popd
              mkdir $out/dist $out/bin
              cp dist/${wheelName} $out/dist
              cp /build/$sourceRoot/entrypoint.sh $out/bin/${entrypoint}.sh
              chmod +x $out/bin/${entrypoint}.sh
              cp -r /build/$sourceRoot/templates $out/lib/python${pythonMajorMinorVersion}/site-packages
              echo '#!/usr/bin/env sh' > $out/bin/banner.sh
              echo "export PYTHONPATH=$PYTHONPATH" >> $out/bin/banner.sh
              echo "${python}/bin/python $out/lib/python${pythonMajorMinorVersion}/site-packages/${banner_file} \$@" >> $out/bin/banner.sh
              chmod +x $out/bin/banner.sh
            '';

            meta = with pkgs.lib; {
              inherit description homepage license maintainers;
            };
          };
      in rec {
        apps = rec {
          default = nix-flake-python-antlr4-parser-python312;
          nix-flake-python-antlr4-parser-python39 = shared.app-for {
            package = packages.nix-flake-python-antlr4-parser-python39;
            inherit entrypoint;
          };
          nix-flake-python-antlr4-parser-python310 = shared.app-for {
            package = packages.nix-flake-python-antlr4-parser-python310;
            inherit entrypoint;
          };
          nix-flake-python-antlr4-parser-python311 = shared.app-for {
            package = packages.nix-flake-python-antlr4-parser-python311;
            inherit entrypoint;
          };
          nix-flake-python-antlr4-parser-python312 = shared.app-for {
            package = packages.nix-flake-python-antlr4-parser-python312;
            inherit entrypoint;
          };
          nix-flake-python-antlr4-parser-python313 = shared.app-for {
            package = packages.nix-flake-python-antlr4-parser-python313;
            inherit entrypoint;
          };
        };
        defaultApp = apps.default;
        defaultPackage = packages.default;
        devShells = rec {
          default = nix-flake-python-antlr4-parser-python312;
          nix-flake-python-antlr4-parser-python39 = shared.devShell-for {
            banner =
              "${packages.nix-flake-python-antlr4-parser-python39}/bin/banner.sh";
            extra-namespaces = "rydnr";
            nixpkgs-release = nixpkgsRelease;
            package = packages.nix-flake-python-antlr4-parser-python39;
            pythoneda-shared-pythonlang-banner =
              pythoneda-shared-pythonlang-banner.packages.${system}.pythoneda-shared-pythonlang-banner-python39;
            pythoneda-shared-pythonlang-domain =
              pythoneda-shared-pythonlang-domain.packages.${system}.pythoneda-shared-pythonlang-domain-python39;
            python = pkgs.python39;
            inherit archRole layer org pkgs repo space;
          };
          nix-flake-python-antlr4-parser-python310 = shared.devShell-for {
            banner =
              "${packages.nix-flake-python-antlr4-parser-python310}/bin/banner.sh";
            extra-namespaces = "rydnr";
            nixpkgs-release = nixpkgsRelease;
            package = packages.nix-flake-python-antlr4-parser-python310;
            pythoneda-shared-pythonlang-banner =
              pythoneda-shared-pythonlang-banner.packages.${system}.pythoneda-shared-pythonlang-banner-python310;
            pythoneda-shared-pythonlang-domain =
              pythoneda-shared-pythonlang-domain.packages.${system}.pythoneda-shared-pythonlang-domain-python310;
            python = pkgs.python310;
            inherit archRole layer org pkgs repo space;
          };
          nix-flake-python-antlr4-parser-python311 = shared.devShell-for {
            banner =
              "${packages.nix-flake-python-antlr4-parser-python311}/bin/banner.sh";
            extra-namespaces = "rydnr";
            nixpkgs-release = nixpkgsRelease;
            package = packages.nix-flake-python-antlr4-parser-python311;
            pythoneda-shared-pythonlang-banner =
              pythoneda-shared-pythonlang-banner.packages.${system}.pythoneda-shared-pythonlang-banner-python311;
            pythoneda-shared-pythonlang-domain =
              pythoneda-shared-pythonlang-domain.packages.${system}.pythoneda-shared-pythonlang-domain-python311;
            python = pkgs.python311;
            inherit archRole layer org pkgs repo space;
          };
          nix-flake-python-antlr4-parser-python312 = shared.devShell-for {
            banner =
              "${packages.nix-flake-python-antlr4-parser-python312}/bin/banner.sh";
            extra-namespaces = "rydnr";
            nixpkgs-release = nixpkgsRelease;
            package = packages.nix-flake-python-antlr4-parser-python312;
            pythoneda-shared-pythonlang-banner =
              pythoneda-shared-pythonlang-banner.packages.${system}.pythoneda-shared-pythonlang-banner-python312;
            pythoneda-shared-pythonlang-domain =
              pythoneda-shared-pythonlang-domain.packages.${system}.pythoneda-shared-pythonlang-domain-python312;
            python = pkgs.python312;
            inherit archRole layer org pkgs repo space;
          };
          nix-flake-python-antlr4-parser-python313 = shared.devShell-for {
            banner =
              "${packages.nix-flake-python-antlr4-parser-python313}/bin/banner.sh";
            extra-namespaces = "rydnr";
            nixpkgs-release = nixpkgsRelease;
            package = packages.nix-flake-python-antlr4-parser-python313;
            pythoneda-shared-pythonlang-banner =
              pythoneda-shared-pythonlang-banner.packages.${system}.pythoneda-shared-pythonlang-banner-python313;
            pythoneda-shared-pythonlang-domain =
              pythoneda-shared-pythonlang-domain.packages.${system}.pythoneda-shared-pythonlang-domain-python313;
            python = pkgs.python313;
            inherit archRole layer org pkgs repo space;
          };
        };
        packages = rec {
          default = nix-flake-python-antlr4-parser-python312;
          nix-flake-python-antlr4-parser-python39 =
            nix-flake-python-antlr4-parser-for {
              antlr4-python-runtime = pkgs.python39.pkgs.antlr4-python3-runtime;
              python = pkgs.python39;
              pythoneda-shared-nix-flake-shared =
                pythoneda-shared-nix-flake-shared.packages.${system}.pythoneda-shared-nix-flake-shared-python39;
              pythoneda-shared-pythonlang-application =
                pythoneda-shared-pythonlang-application.packages.${system}.pythoneda-shared-pythonlang-application-python39;
              pythoneda-shared-pythonlang-banner =
                pythoneda-shared-pythonlang-banner.packages.${system}.pythoneda-shared-pythonlang-banner-python39;
              pythoneda-shared-pythonlang-domain =
                pythoneda-shared-pythonlang-domain.packages.${system}.pythoneda-shared-pythonlang-domain-python39;
            };
          nix-flake-python-antlr4-parser-python310 =
            nix-flake-python-antlr4-parser-for {
              antlr4-python-runtime =
                pkgs.python310.pkgs.antlr4-python3-runtime;
              python = pkgs.python310;
              pythoneda-shared-nix-flake-shared =
                pythoneda-shared-nix-flake-shared.packages.${system}.pythoneda-shared-nix-flake-shared-python310;
              pythoneda-shared-pythonlang-application =
                pythoneda-shared-pythonlang-application.packages.${system}.pythoneda-shared-pythonlang-application-python310;
              pythoneda-shared-pythonlang-banner =
                pythoneda-shared-pythonlang-banner.packages.${system}.pythoneda-shared-pythonlang-banner-python310;
              pythoneda-shared-pythonlang-domain =
                pythoneda-shared-pythonlang-domain.packages.${system}.pythoneda-shared-pythonlang-domain-python310;
            };
          nix-flake-python-antlr4-parser-python311 =
            nix-flake-python-antlr4-parser-for {
              antlr4-python-runtime =
                pkgs.python311.pkgs.antlr4-python3-runtime;
              python = pkgs.python311;
              pythoneda-shared-nix-flake-shared =
                pythoneda-shared-nix-flake-shared.packages.${system}.pythoneda-shared-nix-flake-shared-python311;
              pythoneda-shared-pythonlang-application =
                pythoneda-shared-pythonlang-application.packages.${system}.pythoneda-shared-pythonlang-application-python311;
              pythoneda-shared-pythonlang-banner =
                pythoneda-shared-pythonlang-banner.packages.${system}.pythoneda-shared-pythonlang-banner-python311;
              pythoneda-shared-pythonlang-domain =
                pythoneda-shared-pythonlang-domain.packages.${system}.pythoneda-shared-pythonlang-domain-python311;
            };
          nix-flake-python-antlr4-parser-python312 =
            nix-flake-python-antlr4-parser-for {
              antlr4-python-runtime =
                pkgs.python312.pkgs.antlr4-python3-runtime;
              python = pkgs.python312;
              pythoneda-shared-nix-flake-shared =
                pythoneda-shared-nix-flake-shared.packages.${system}.pythoneda-shared-nix-flake-shared-python312;
              pythoneda-shared-pythonlang-application =
                pythoneda-shared-pythonlang-application.packages.${system}.pythoneda-shared-pythonlang-application-python312;
              pythoneda-shared-pythonlang-banner =
                pythoneda-shared-pythonlang-banner.packages.${system}.pythoneda-shared-pythonlang-banner-python312;
              pythoneda-shared-pythonlang-domain =
                pythoneda-shared-pythonlang-domain.packages.${system}.pythoneda-shared-pythonlang-domain-python312;
            };
          nix-flake-python-antlr4-parser-python313 =
            nix-flake-python-antlr4-parser-for {
              antlr4-python-runtime =
                pkgs.python313.pkgs.antlr4-python3-runtime;
              python = pkgs.python313;
              pythoneda-shared-nix-flake-shared =
                pythoneda-shared-nix-flake-shared.packages.${system}.pythoneda-shared-nix-flake-shared-python313;
              pythoneda-shared-pythonlang-application =
                pythoneda-shared-pythonlang-application.packages.${system}.pythoneda-shared-pythonlang-application-python313;
              pythoneda-shared-pythonlang-banner =
                pythoneda-shared-pythonlang-banner.packages.${system}.pythoneda-shared-pythonlang-banner-python313;
              pythoneda-shared-pythonlang-domain =
                pythoneda-shared-pythonlang-domain.packages.${system}.pythoneda-shared-pythonlang-domain-python313;
            };
        };
      });
}
