{ pkgs }:
{
  simple = pkgs.pass.template ;
  fullProject = import ''${pkgs.fetchFromGitHub {
                            owner = "countoren";
                            repo = "lambdabot";
                            rev = "3c925a242f79f8d3dc47d779a6ca31e836837ece";
                            sha256 = "0yldd5s3l6pcimf1l6kdvd1g7l8lhcmylfv0q6fgazlpnca0z92v";
                        }}/nix/template.nix'';
}
