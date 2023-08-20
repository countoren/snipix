# Snipix - Editor Agnostic Snippet and Template Tool 

## Overview

Snipix is a robust tool designed to provide a seamless and modular suite of functions and commands, aimed at enhancing template management within the Nix templates system. This library has been meticulously crafted to simplify the process of creating, initializing, and organizing templates and code snippets across a diverse range of projects and programming languages. Leveraging the elegance of simple and modular Nix expressions, Snipix empowers developers to streamline their workflow efficiently.

## Prerequisites

Before delving into the world of Snipix, it's imperative to have the following prerequisites installed on your system:

- [Nix Package Manager](https://nixos.org/download.html) - An essential tool for managing Nix packages and configuring environments.
- Flakes Enabled - Ensure that your Nix environment is [flakes-enabled](https://nixos.wiki/wiki/Flakes) to ensure optimal support.

## Installation

Choose an installation approach that aligns with your needs and preferences:

1. **Full-Featured Standalone Installation** - If you're eager to create templates within your home folder, consider cloning the repository using Git:
   ```bash
   git clone https://github.com/countoren/snipix.git
   ```
   Alternatively, leverage the Nix flake mechanism:
   ```bash
   nix flake clone github:countoren/snipix --dest snipix
   ```
   Subsequently, install the tool by navigating to the Snipix directory and executing:
   ```bash
   nix build -f default.nix 
   ```

2. **Full-Featured NixOS and HomeManager Installation** - Seamlessly integrate the repository into your configuration folder, either by cloning it as a subdirectory, subtree, or submodule. Import Snipix into your `configuration.nix` using the following approach:
```nix
  environment.systemPackages = with pkgs; [
    # Snipix
    (import ./snipix {
      inherit pkgs;
      templatesFolder = "PATH_TO_PARENT/snipix";
      installCommand = ''
        sudo nixos-rebuild switch --flake PATH_TO_YOUR_CONFIGURATION_DIR
      '';
    })
  ];
```
Replace `PATH_TO_PARENT` with the appropriate Snipix parent folder path and `PATH_TO_YOUR_CONFIGURATION_DIR` with your system flake path. For more customization options, refer to `snipix/default.nix`.

3. **Templates Utilities Only** - For an immutable version installation within your Nix profile, execute:
   ```bash
   nix profile install github:countoren/snipix 
   ```
   Note: Due to the immutable nature of the Nix store, the addition of new templates via `save-templates` might not be supported.

4. **Usage as Nix Templates** - to use as basic nix flake templates:
   ```bash
   nix flake init -t github:countoren/snipix#basic
   ```
   Replace `basic` with your desired template name.

## Usage

Seamlessly integrate Snipix into your Nix environment. Incorporate it into your NixOS configuration or utilize it independently with HomeManager.

**Included Utilities:**
   - `init`: Initialize a template with a specified name (e.g., `nix init -t`).
   - `snip`: Present users with a search and preview tool for all files within the Snipix folder (using fzf by default). The selected file's content is copied to the clipboard and displayed in the terminal.
     This command also accepts an extra path argument in order to target specific template folder in Snipix.
   - `initWithDiff`: Initialize a template and display changes using a designated diff tool.
   - `save-template`: Create a new template based on the current folder's contents. This utility prompts for a name and description, duplicates the folder, and updates `templates.nix`.
   - `snip-${name}`: Execute `snip` on a specific template folder. If the folder contains a single file, its content is directly used without user interaction.
   For instance, in Vim, use:
   ```vim
   :!snip-basic
   ```
   Press `p` to paste content into the current buffer, or use:
   ```vim
   :r!snip-basic
   ```
   If the template folder houses multiple files, run this command from the terminal.
   - `nt-${name}`: Initialize a template with diff display for changes.
   - `nt-${name}-edit`: Open the template folder in the default text editor for manual edits.
   - `nt-${name}-noDiff`: Initialize a template without displaying a diff.
   - `nt-${name}-description`: Echo the template description.

## Contribute

Contributions to this library are highly appreciated. If you come across issues, have ideas for improvements, or wish to add new features, please submit a pull request on the repository.

## License

This library is licensed under the MIT License. Additional information can be found in the `LICENSE` file.
