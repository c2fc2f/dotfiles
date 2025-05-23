<!--- LTeX: language=en-US --->

# culxttes/dotfiles

<div align="center">
  <img src="https://upload.wikimedia.org/wikipedia/commons/c/c4/NixOS_logo.svg" alt="NixOS Logo" width="500"/>
</div>


This repository contains my personal NixOS configuration files, structured to facilitate reproducible and modular system setups using Nix Flakes and Home Manager.

## Features

* **Nix Flakes**: Utilizes the Nix Flakes feature for declarative and reproducible system configurations.
* **Home Manager**: Manages user-specific configurations, ensuring consistency across environments.
* **Modular Design**: Organized into modules for hosts and users, promoting reusability and clarity.
* **Development Shells**: Provides predefined development environments for various projects.
* **Secrets Management**: Handles sensitive information securely using [sops](https://github.com/mozilla/sops).
* **CI Integration**: Includes GitHub Actions workflows for continuous integration and validation.

## Repository Structure

* `flake.nix` & `flake.lock`: Define the Nix Flake entry point and lock dependencies.
* `hosts/`: Contains host-specific configurations.
* `users/`: Defines user-specific settings and packages.
* `modules/`: Houses custom NixOS and Home Manager modules.
* `devshells/`: Sets up development environments with necessary tools and dependencies.
* `secrets/`: Encrypted secrets managed via sops.
* `.github/workflows/`: CI workflows for automated checks and builds.
* `.sops.yaml`: Configuration file for sops, specifying encryption details.
* `treefmt.nix`: Defines formatting standards for the codebase.
## Getting Started

### Prerequisites

* Nix with Flakes enabled.
* [sops](https://github.com/mozilla/sops) installed for secrets management.

### Installation

1. **Clone the Repository**:

   ```bash
   git clone https://github.com/culxttes/dotfiles.git
   cd dotfiles
   ```



2. **Review and Customize**:

   Inspect the `hosts/` and `users/` directories to understand the configurations. Modify them as needed to suit your environment.

3. **Apply Configuration**:

   Use the following command to apply the configuration to your system:

   ```bash
   sudo nixos-rebuild switch --flake
   ```




## Secrets Management

Sensitive information is managed using sops. Ensure you have the necessary GPG/SSH keys to decrypt the secrets.

To edit a secret:

```bash
sops secrets/secrets.yaml
```



## Development Shells

The `devshells/` directory contains configurations for development environments. To enter a development shell:

```bash
nix develop
```




## Continuous Integration

GitHub Actions workflows are defined in `.github/workflows/` to automate testing and validation of configurations.

## License

This project is licensed under the [Unlicense](https://unlicense.org/), dedicating it to the public domain.
