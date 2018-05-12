{
# Allow proprietary packages
	allowUnfree = true;

	packageOverrides = pkgs_: with pkgs_; {
		mvim = import ./vim { inherit pkgs; };
	};
}
