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
        server_env = pkgs.python3.withPackages (ps: with ps; [ rangehttpserver ]);
      in
      with pkgs; rec {
        devShells.default = mkShell {
          buildInputs = [
              server_env
          ];
        };
        apps.default = {
          type = "app";
          program = "${pkgs.writeShellApplication 
            {
              name = "run-webserver";
              runtimeInputs = [ server_env ];
              text = ''
                cd "$(dirname "$0")"
                exec ${server_env}/bin/python3 -m rangehttpserver
              '';
            }}/bin/run-webserver";
        };
      }
    );
}
