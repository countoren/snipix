# NTmp

**Description:**  
This tool provides a set of useful functions and commands to manage templates based on the nix templates system.
The library helps you create, initialize, and manage templates and code snippets for any type of project in any language.

**Prerequisites:**  
Before using this library, ensure you have the following installed on your system:
- Nix package manager (TODO: add link to download nix)
- Flakes enabled (TODO: add link for enabling flakes)

**Installation:**

You can chose couple of flavors of installtions:
1. full-feature standalone - including writing ability for new templates
in your home folder
```bash
    git clone repoaddress
``` 
or 

```bash
    nix flake clone github:countoren/templates
```
than you could install the first generation of it on a profile with:
```bash
    cd ntmp
    nix build -f default.nix 
```

2. full-feature NixOS, HomeManager - clone the repo as sub directory( or subtree/submodule) inside your configuration folder:
and inculde it on the top level as follow:
```nix
TODO
```

3. Just templates utils - 
```bash
    nix profile install github:countoren/templates 
```
* note that this is should be treated as immutable version of the templates
  therfor save-templates might not be able to add a new templates( due to the fact it will be stored on the nix store)
* you should be able to use the utils to initialize any nix templates (levarging initWithDiff command for example)
like so
``` bash 
    TODO
```

4. Use just as nix templates - 
```bash
  nix flake init -t github:countoren/templates#basic                           
```
replace with *basic* with any template

To use this library, you can include it in your Nix environment. You can integrate it into your NixOS configuration or use it in standalone mode with HomeManager.

**Utils included:**
   - `init`: Initializes a template with the given template name (just ``` nix init -t ```).
   - `initWithDiff`: Initializes a template with the given template name and shows a diff of the changes using the specified difftool .
   - `save-template`: Creates a new template based on the current folder contents. It prompts for a template name and description, copies the current folder into the templates folder, and adds the template to the `templates.nix` file.
   - `nt-${name}`: Initializes the template with the given name and shows a diff of the changes using the specified difftool.
   - `nt-${name}-edit`: Opens the template file with the default text editor for manual editing.
   - `nt-${name}-noDiff`: Initializes the template with the given name without showing any diff.
   - `nt-${name}-description`: echo the template description.

**Contributing:**
Contributions to this library are welcome. If you find any issues, have ideas for improvements, or want to add new features, feel free to open a pull request on the repository.

**License:**  
This library is licensed under the MIT License. See the `LICENSE` file for more details.
