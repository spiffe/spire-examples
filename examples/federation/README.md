# Federation Example with SPIRE 0.11.0

This is an example implementation of the scenario described on the [Federation Tutorial]().

## Requirements

- Go 1.14
- docker-compose

## Build

```
$ ./build.sh
```

## Run

```
$ docker-compose up -d
```

This starts the SPIRE Servers and the applications.

## Start SPIRE Agents 

```
$ ./1-start-spire-agents.sh
```

## Bootstrap Federation

```
$ ./2-bootstrap-federation.sh
```

## Create Workload Registration Entries

```
$ ./3-create-registration-entries.sh
```

After running this script, it may take some seconds for the applications to receive their SVIDs and trust bundles. 

## See it working on the browser

Open up a browser to http://localhost:8080/quotes and you should see a grid of randomly generated phony stock quotes that are updated every 1 second.

## Clean up

```
$ docker-compose down
```

