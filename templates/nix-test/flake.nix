{
  description = "<repo-name> — reproducible test environment";

  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

  outputs = { self, nixpkgs }:
    let
      system = "aarch64-darwin";
      pkgs = import nixpkgs { inherit system; };
      pythonEnv = pkgs.python3.withPackages (ps: [
        ps.pytest
        # add the repo's actual runtime deps here, e.g. ps.requests
      ]);
    in {
      devShells.${system}.default = pkgs.mkShell {
        packages = [ pythonEnv ];
      };
    };
}
