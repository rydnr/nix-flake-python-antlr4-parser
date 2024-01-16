# vim: set fileencoding=utf-8
"""
rydnr/nix/flake/parser/events/nix_flake_input_found.py

This file declares the NixFlakeInputFound class.

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
from pythoneda.shared.nix_flake import NixFlakeInput


class NixFlakeInputFound(Event):
    """
    Represents the moment an input in a flake.nix file has been found.

    Class name: NixFlakeInputFound

    Responsibilities:
        - Wraps all contextual information of the event (the Nix flake input).

    Collaborators:
        - None
    """

    def __init__(self, nixFlakeInput: NixFlakeInput):
        """
        Creates a new NixFlakeInputFound for given input.
        :param nixFlakeInput: The flake.nix file.
        :type nixFlakeInput: str
        """
        super().__init__()
        self._nix_flake_input = nixFlakeInput

    @property
    @primary_key_attribute
    def nix_flake_input(self) -> NixFlakeInput:
        """
        Retrieves the Nix flake input.
        :return: Such instance.
        :rtype: pythoneda.shared.nix_flake.NixFlakeInput
        """
        return self._nix_flake_input
