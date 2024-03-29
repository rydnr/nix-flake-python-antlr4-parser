# vim: set fileencoding=utf-8
"""
rydnr/nix/flake/parser/application/nix_flake_python_antlr4_parser.py

This file declares the NixFlakePythonAntlr4Parser class.

Copyright (C) 2023-today rydnr's rydnr/nix-flake-python-antlr4-parser

This program is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program.  If not, see <https://www.gnu.org/licenses/>.
"""
import asyncio
from pythoneda.shared.application import enable, PythonEDA
from pythoneda.shared.infrastructure.cli import LoggingConfigCli


@enable(LoggingConfigCli)
class NixFlakePythonAntlr4Parser(PythonEDA):
    """
    A PythonEDA application that runs the ANTLR4-based Nix flake parser.

    Class name: NixFlakePythonAntlr4Parser

    Responsibilities:
        - Runs PythonEDA to parse Nix flakes using the ANTLR4 parser.

    Collaborators:
        - rydnr.nix.flake.parser.Antlr4Listener: The ANTLR4 listener.
    """

    def __init__(self):
        """
        Creates a new NixFlakePythonAntlr4Parser instance.
        """
        # nix_flake_python_antlr4_parser_banner is automatically generated
        # by rydnr/nix-flake-python-antlr4-parser flake.
        try:
            from rydnr.nix.flake.parser.application.nix_flake_python_antlr4_parser_banner import (
                NixFlakePythonAntlr4ParserBanner,
            )

            banner = NixFlakePythonAntlr4ParserBanner()
        except ImportError:
            banner = None

        super().__init__(banner, __file__)


if __name__ == "__main__":
    asyncio.run(
        NixFlakePythonAntlr4Parser.main(
            "rydnr.nix.flake.parser.application.NixFlakePythonAntlr4Parser"
        )
    )
