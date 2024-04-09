To install, download the newest spire-server and spire-agent binaries from the SPIRE website and place in /bin

Run:
```
make install
```

Edit /etc/spire/server/main.conf and update with settings as needed.

Edit /etc/spire/agent/main.conf and update with settings as needed.

Enable the main server:

```
systemctl enable spire-server@main
```

Start the main server:

```
systemctl enable spire-server@main
```

Enable the main agent:

```
systemctl enable spire-agent@main
```

Start the main server:

```
systemctl enable spire-agent@main
```


# Show Entries from the main server
```
spire-server entry show -socketPath /run/spire/server/sockets/main/private/api.sock
```
