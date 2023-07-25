# Tunneling

## Bore 
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
This will expose your local port at localhost:8000 to the public internet at bore.pub:<PORT>, where the port number is assigned randomly. You can forward a port on your local machine by using the bore local command. This takes a positional argument, the local port to forward, as well as a mandatory --to option, which specifies the address of the remote server.
```
bore local 5000 --to bore.pub
```
You can optionally pass in a --port option to pick a specific port on the remote to expose, although the command will fail if this port is not available. Also, passing --local-host allows you to expose a different host on your local area network besides the loopback address localhost. 
