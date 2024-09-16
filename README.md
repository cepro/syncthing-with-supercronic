# Syncthing on fly with Supercronic

An always up syncthing instance on fly with a supercronic for running various jobs that write to shared folders.

This server serves 2 purposes:
- an always up instance that cepro members can sync with at any time
- a store downloads of profile and other data produced by periodic job runs

## File system on the host

* /var/syncthing
  * syncthing files and folders being shared
* /supercronic/crontab
  * scheduled jobs configuration
* /usr/local/bin
  * syncthing executable
  * supercronic executable 

## Logs

TODO: these logs need to be parsed properly by our fly-log-shipper instance. can be done if decide to proceed with this approach 

Logs go to stdout which ends up on papertrail at https://my.papertrailapp.com/events?q=json.message.app%3Asyncthing-with-supercronic


## Log in to the host

```sh
fly ssh console
```

## Syncthing Administration

The admin GUI is needed to:
- add / accept connections to new peers (syncthing network "devices")
- accept folders shared by a peer

The admin GUI can be accessed by setting up a proxy through wireguard:
```sh
fly proxy 38384:8384
```

Then locally opening up http://127.0.0.1:38384/

## Fly Setup

```sh
fly apps create --name "syncthing-with-supercronic" --org cepro
fly volumes create --region lhr --size 1 --count 1 --yes syncthing_files
fly deploy --no-public-ips
```
