"""
rydnr/nix/flake/parser/infrastructure/cli/flake_nix_cli.py

This file defines the FlakeNixCli class.

Copyright (C) 2023-today rydnr's https://github.com/rydnr/nix-flake-python-antlr4-parser

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
from argparse import ArgumentParser
import os
from pythoneda import PrimaryPort
from pythoneda.application import PythonEDA
from pythoneda.infrastructure.cli import CliHandler
from rydnr.nix.flake.parser.events import FlakeNixFileFound
import sys


class FlakeNixCli(CliHandler, PrimaryPort):

    """
    A PrimaryPort used to gather the flake.nix path.

    Class name: FlakeNixCli

    Responsibilities:
        - Parse the command-line to retrieve the information about the flake.nix path.

    Collaborators:
        - PythonEDA subclasses: They are notified back with the information retrieved from the command line.
    """

    def __init__(self):
        """
        Creates a new FlakeNixCli instance.
        """
        super().__init__("Provide the path of the flake.nix file to process")

    @classmethod
    def priority(cls) -> int:
        """
        Retrieves the priority of this port.
        :return: The priority.
        :rtype: int
        """
        return 90

    @classmethod
    @property
    def is_one_shot_compatible(cls) -> bool:
        """
        Retrieves whether this primary port should be instantiated when
        "one-shot" behavior is active.
        It should return False unless the port listens to future messages
        from outside.
        :return: True in such case.
        :rtype: bool
        """
        return True

    def add_arguments(self, parser: ArgumentParser):
        """
        Defines the specific CLI arguments.
        :param parser: The parser.
        :type parser: argparse.ArgumentParser
        """
        parser.add_argument(
            "-f", "--flake-nix", required=True, help="The flake.nix file"
        )

    async def handle(self, app: PythonEDA, args):
        """
        Processes the command specified from the command line.
        :param app: The PythonEDA instance.
        :type app: pythoneda.application.PythonEDA
        :param args: The CLI args.
        :type args: argparse.args
        """
        if os.path.exists(args.flake_nix):
            await app.accept(FlakeNixFileFound(args.flake_nix))
        else:
            print(f"{args.flake_nix} not found")
            sys.exit(1)
