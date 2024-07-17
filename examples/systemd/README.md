# SPIRE services managed by SystemD

To install, download the newest spire-server and spire-agent binaries from the SPIRE website and place in /bin

Run:
```
make install
```

Edit /etc/spire/server/main.conf and update with settings as needed.

Enable the main server:

```
systemctl enable spire-server@main
```

Start the main server:

```
systemctl start spire-server@main
```


# Create a join token
```
spire-server token generate -spiffeID spiffe://example.org/changeme -socketPath /run/spire/server/sockets/main/private/api.sock
```

Edit /etc/spire/agent/main.conf and update with settings as needed, in particular the join token.

Enable the main agent:

```
systemctl enable spire-agent@main
```

Start the main agent:

```
systemctl start spire-agent@main
```


# Show Entries from the main server
```
spire-server entry show -socketPath /run/spire/server/sockets/main/private/api.sock
```
