# Home Server (Minimal)

Very basic home server with very basic init script.

## Usage

To use this:

- Clone this project
- Make the init script executable: `chmod +x init.sh`
- Run the init script, and insert the requested values
- Spin up the docker containers, and configure

## Scripts

This contains two scripts in the scripts file. _Both scripts require this to be cloned into a folder called `home-server`_.

- `check-vpn.sh` checks the ips of various containers
- `fix-ports.sh` fixes the forwarded deluge port based on the gluetun container
