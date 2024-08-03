{
  description = "Webserver for managing some personal game servers";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils }: 
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixpkgs { inherit system; };
        rangehttpserver = pkgs.python3Packages.buildPythonPackage rec {
          pname = "rangehttpserver";
          version = "1.3.3";
          src = pkgs.fetchPypi {
            inherit pname version;
            sha256 = "sha256-jfa7pg1oj080nIWuFRy557g9osn9CM9io9ZO8y4GNwM"; # Replace with actual sha256
          };
          doCheck = false;
        };
        server_env = pkgs.python3.withPackages (ps: [ rangehttpserver ]);
      in
      with pkgs; rec {
        packages.default = [
            server_env
        ];
        devShells.default = mkShell {
          buildInputs = [
            self.packages.${system}.default
          ];
        };
        apps.default = {
          type = "app";
          program = "${pkgs.writeShellApplication 
            {
              name = "run-webserver";
              runtimeInputs = self.packages.${system}.default;
              text = ''
                cd "$(dirname "$0")"
                exec ${server_env}/bin/python3 -m rangehttpserver
              '';
            }}/bin/run-webserver";
        };
      }
    );
}
