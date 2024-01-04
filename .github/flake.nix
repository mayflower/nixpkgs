{
  description = "Merge upstream nixpkgs";

  outputs =
    { self, nixpkgs }:
    let
      system = "x86_64-linux";
      pkgs = import nixpkgs { inherit system; };
      git_bin = "${pkgs.git}/bin/git";
    in
    {
      packages."${system}" = {

        merge-and-push = pkgs.writeScriptBin "merge-and-push" ''
          #!${pkgs.stdenv.shell}
          set -xeu

          user_name=''${git_user_name:-$(${git_bin} config user.name)}
          user_mail=''${git_user_mail:-$(${git_bin} config user.email)}

          ${git_bin} config user.name "$user_name"
          ${git_bin} config user.email "$user_mail"

          if [[ "" = "$(${git_bin} remote -v get-url upstream || true)" ]] ; then
            ${git_bin} remote add upstream "$upstream_url" >&2
          fi

          ${git_bin} fetch upstream "$upstream_branch" >&2

          merge="upstream/$upstream_branch"

          if [[ "" != "$(${git_bin} log -1 --format=%H HEAD..$merge)" ]] ; then
            ${git_bin} merge $merge >&2
            ${git_bin} push >&2
          fi

          exit 0
        '';

        nightly-merge = pkgs.writeScriptBin "nightly-merge" ''
          #!${pkgs.stdenv.shell}
          set -xeu

          . ${self.packages."${system}".merge-and-push}/bin/merge-and-push
        '';
      };
    };
}
