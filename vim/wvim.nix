{ pkgs ? import <nixpkgs> {}
, pkgsPath
, additionalVimrc 
}:
import ./nvim.nix { inherit pkgs; 
  additionalVimrc = ''
    let $PATH = $PATH.":${pkgs.quick-lint-js}/bin"
  '' + additionalVimrc;
  additionalPlugins = with pkgs.vimPlugins; [
    vim-go
    (pkgs.vimUtils.buildVimPlugin {
      name = "quick-lint-js";
      src = ''${pkgs.fetchzip {
        url = "https://c.quick-lint-js.com/releases/2.13.0/vim/quick-lint-js-vim.zip";
        sha256 = "obeNmt9SsTvs7ewlg3ISiW/wCYYJCwAozVHa+3xSHyU=";
        stripRoot=false;
      }}/quick-lint-js.vim'';
    })
  ];
}
