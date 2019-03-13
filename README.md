# Hexdurr

CLI tool for managing Hex organization memberships and permissions.

## Installation

The latest stable version of the package can be installed by running
`mix escript.install hex hexdurr`. The development version can be installed by running
`mix do escript.build, escript.install`.

## Usage

Hexdurr takes a YAML configuration of the following and updates the Hex organization accordingly,
updating the number of reserved seats, adds/removes members and updates permission roles:

```yaml
members:
  - username: dirk.gently
    role: admin
  - username: arthur.dent
    role: write
```

Run `hexdurr generate` to generate a new YAML configuration file from the current organization
memberships, this can be useful when starting to use Hexdurr with an existing organization.

Update the organization from the given configuration by running `hexdurr run`.

### Command line flags

  * `--organization NAME` - The organization to configure (required)
  * `--file PATH` - Path to the YAML configuration file (required)
  * `--key API_KEY` - The Hex API key (required)
  * `--dry_run` - If set only outputs the changes to make without performing them (optional)
