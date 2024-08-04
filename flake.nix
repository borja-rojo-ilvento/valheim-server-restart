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
      in 
      with pkgs; {
        packages = {
          python_env = python3.withPackages (ps: with ps; [
            rangehttpserver
          ]);
          default = [
            packages.python_env
          ];
        }; 
        devShells.default = mkShell {
          buildInputs = [
              packages.default
          ];
        };
        apps.dashboard = {
          type = "app";
          program = "${pkgs.writeShellApplication 
            {
              name = "run-webserver";
              runtimeInputs = packages.default;
              text = ''
                exec ${packages.python_env}/bin/python3 -m RangeHTTPServer
              '';
            }}/bin/run-webserver";
        };
      }
    );
}
