# Tunneling

## Bore \
https://github.com/ekzhang/bore \
**Description** A modern, simple TCP tunnel in Rust that exposes local ports to a remote server, bypassing standard NAT connection firewalls \
Installation requires Rust
```
cargo install bore-cli
```
On your local machine, run this:
```
bore local 8000 --to bore.pub
```
This will expose your local port at localhost:8000 to the public internet at bore.pub:<PORT>, where the port number is assigned randomly.
