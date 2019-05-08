# Sat Apr 13 14:16:27 2019
with import <nixpkgs> {};
import (fetchFromGitHub {
                   owner="NixOS";
                   repo="nixpkgs";
                   rev="7edf2db";
                   sha256="1j6srm8xrzvmmivnb7n7pnqkayrbfd2a09rq3j5kk7bsznzy3nx6";
                 }) { 
                   config= { 
                     allowUnfree = true; 
                     oraclejdk.accept_license = true;
                   }; 
                 }
