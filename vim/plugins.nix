{ vimUtils, fetchFromGitHub }:
{
  ultisnips = vimUtils.buildVimPluginFrom2Nix {
    name = "ultisnips-countoren-2018-01-12";
    src = fetchFromGitHub {
      owner = "countoren";
      repo = "ultisnips";
      rev = "423f264e753cec260b4f14455126e6db7ba429af";
      sha256 = "19g3k0nqzizv39rxwgkca9n2gsd19z2wwsmicr0zcgnf50nhkznh";
    };
    dependencies = [];
  };

  ale = vimUtils.buildVimPluginFrom2Nix {
    name = "ale-2017-07-10";
    src = fetchFromGitHub {
      owner = "w0rp";
      repo = "ale";
      rev = "b44f6053d1faffa47191009f84dc36d14ebc3992";
      sha256 = "1vdk8s5inry8xkwa10cyjfdjqyxby76n2sm7gkz0rfqagh9v10g8";
    };
    dependencies = [];
  };

  elm-vim = vimUtils.buildVimPluginFrom2Nix {
    name = "elm.vim-2017-01-13";
    src = fetchFromGitHub {
      owner = "ElmCast";
      repo = "elm-vim";
      rev = "0c1fbfdf12f165681b8134ed2cae2c148105ac40";
      sha256 = "0l871hzg55ysns5h6v7xq63lwf4135m3xggm2s4q2pmzizivk0x2";
    };
    dependencies = [];
  };

  vim-wombat = vimUtils.buildVimPluginFrom2Nix {
    name = "vim-wombat-2017-12-22";
    src = fetchFromGitHub {
      owner = "vim-scripts";
      repo = "wombat256.vim";
      rev = "8734ba45dcf5e38c4d2686b35c94f9fcb30427e2";
      sha256 = "01fdvfwdfqn5xi88lfanb4lb6jmn1ma6wq6d9jj2x7qamdbpvsrg";
    };
    dependencies = [];
  };


  vim-javascript = vimUtils.buildVimPluginFrom2Nix {
    name = "vim-javascript-2016-11-10";
    src = fetchFromGitHub {
      owner = "pangloss";
      repo = "vim-javascript";
      rev = "d736e95330e8aa343613ad8cddf1e7cc82de7ade";
      sha256 = "136q0ask4dp99dp7fbyi1v2qrdfy6mnrh0a3hzsy9aw5g2f2rvbj";
    };
    dependencies = [];
  };

}
