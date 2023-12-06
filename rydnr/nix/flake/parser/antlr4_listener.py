"""
rydnr/nix/flake/parser/antlr4_listener.py

This file declares the Antlr4Listener class.

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
from antlr4 import CommonTokenStream, FileStream, ParseTreeWalker
from antlr4.error.ErrorListener import ErrorListener
from pythoneda import EventListener, listen
from pythoneda.shared.git import GitRepo
from pythoneda.shared.nix_flake import GithubUrlFor, NixFlakeInput
from rydnr.nix.flake.parser.events import FlakeNixFileFound, NixFlakeInputFound
from rydnr.nix.flake.parser.generated import (
    NixFlakeLexer,
    NixFlakeListener,
    NixFlakeParser,
)
from typing import List


class Antlr4Listener(EventListener, NixFlakeListener):
    """
    Reacts upon FlakeNixFound events to extract its inputs.

    Class name: Antlr4Listener

    Responsibilities:
        - Knows how to use ANTLR4 classes.
        - Knows how to extract inputs from Nix flakes.

    Collaborators:
        - rydnr.nix.flake.parser.generated.NixFlakeListener: The ANTLR4 listener.
    """

    _json_output = True

    def __init__(self, flakeNixFile: str):
        """
        Creates a new Antlr4Listener for given file.
        :param flakeNixFile: The flake.nix file to process.
        :type flakeNixFile: str
        """
        super().__init__()
        self._flake_nix_file = flakeNixFile
        self._nix_flake_inputs = []

    @property
    def flake_nix_file(self) -> str:
        """
        Retrieves the path of the flake.nix file.
        :return: Such information.
        :rtype: str
        """
        return self._flake_nix_file

    @property
    def nix_flake_inputs(self) -> List[NixFlakeInput]:
        """
        Retrieves the Nix flake inputs.
        :return: Such list.
        :rtype: List[pythoneda.shared.nix_flake.NixFlakeInput]
        """
        return self._nix_flake_inputs

    @classmethod
    def json_output(cls, flag: bool):
        """
        Annotates whether to format the output in JSON or not.
        :param flag: The flag.
        :type flag: bool
        """
        cls._json_output = flag

    @classmethod
    @listen(FlakeNixFileFound)
    async def from_flake_nix_file(
        cls, event: FlakeNixFileFound
    ) -> List[NixFlakeInputFound]:
        """
        Retrieves the inputs from the file identified in the event.
        :param event: The event.
        :type event: rydnr.nix.flake.parser.events.FlakeNixFileFound
        :return: A list of events for each Nix flake input found.
        :rtype: List[pythoneda.shared.nix_flake.NixFlakeInput]
        """
        result = []
        lexer = NixFlakeLexer(FileStream(event.flake_nix_file))
        stream = CommonTokenStream(lexer)
        parser = NixFlakeParser(stream)
        parser.removeErrorListeners()
        parser.addErrorListener(ErrorListener())
        tree = parser.flake()
        listener = Antlr4Listener(event.flake_nix_file)
        walker = ParseTreeWalker()
        walker.walk(listener, tree)
        for input in listener.nix_flake_inputs:
            result.append(NixFlakeInputFound(input))
            if cls._json_output:
                print(input)
        return result

    def exitInput(self, ctx: NixFlakeParser.InputContext):
        """
        Gets called when the "input" rule in the grammar exits,
        and provides information about the tokens parsed in the "ctx" argument.
        :param ctx: The parsing context.
        :type ctx: rydnr.nix.flake.parser.generated.NixFlakeParser.InputContext
        """
        input_name = None
        input_url = None
        url_assignment = ctx.input_url_assignment()
        if url_assignment is None:
            input_obj = ctx.input_obj()
            if input_obj is not None:
                input_name = str(input_obj.IDENTIFIER())
                input_url = str(input_obj.url().STRING()).strip('"')
        else:
            input_name = str(url_assignment.IDENTIFIER())
            input_url = str(url_assignment.STRING()).strip('"')

        version = self.extract_version(input_url)
        owner, repo = GitRepo.extract_repo_owner_and_repo_name(input_url)

        self._nix_flake_inputs.append(
            NixFlakeInput(input_name, version, GithubUrlFor(owner, repo))
        )

    def extract_version(self, url: str) -> str:
        """
        Extracts the version from given url.
        :param url: The url.
        :type url: str
        :return: The version.
        :rtype: str
        """
        return url.split("/")[2]
