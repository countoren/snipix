{ pkgs }:
{
    filemanip = 
      import (pkgs.fetchFromGitHub { 
        owner="countoren"; 
        repo="filemanip"; 
        rev="d951882"; 
        sha256="1cv4nmc70yy8lyka5ywd3ss2lg96h291k841d00hjhpqr4bziiyr"; 
      }) {};
}
