{
# Allow proprietary packages
	allowUnfree = true;

	packageOverrides = pkgs_: with pkgs_; {
		my_vim = import ./vim { inherit pkgs; };
		myVim = pkgs.vim_configurable.override {
			config.vim = {
				ruby = true;
				gui = true;
			};
			ruby = ruby;
		};	 


	};
}
