# vim: set fileencoding=utf-8
"""
rydnr/nix/flake/parser/events/flake_nix_file_found.py

This file declares the FlakeNixFileFound class.

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
from pythoneda.shared import Event, primary_key_attribute


class FlakeNixFileFound(Event):
    """
    Represents the moment a file.nix file has been found.

    Class name: FlakeNixFileFound

    Responsibilities:
        - Wraps all contextual information of the event (the file path).

    Collaborators:
        - None
    """

    def __init__(self, flakeNixFile: str):
        """
        Creates a new FlakeNixFileFound for given file.
        :param flakeNixFile: The flake.nix file.
        :type flakeNixFile: str
        """
        super().__init__()
        self._flake_nix_file = flakeNixFile

    @property
    @primary_key_attribute
    def flake_nix_file(self) -> str:
        """
        Retrieves the path of the flake.nix file.
        :return: Such information.
        :rtype: str
        """
        return self._flake_nix_file
