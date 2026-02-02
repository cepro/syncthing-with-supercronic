# Syncthing on Fly with Supercronic

An always-up Syncthing instance on Fly.io with Supercronic for running various scheduled jobs that write to shared folders.

This server serves 2 purposes:

- An always-up instance that Simtricity members can sync with at any time
- A store for downloads of profiles and other data produced by periodic job runs

## Architecture

- **Syncthing** (v2.0.13): File synchronization
- **Supercronic** (v0.2.42): Cron job scheduler with Prometheus metrics
- **Supervisord**: Process manager that keeps both services running

## File System on the Host

- `/var/syncthing` - Syncthing configuration and synced folders (persistent volume)
- `/supercronic/crontab` - Scheduled jobs configuration
- `/usr/local/bin` - Syncthing and Supercronic executables

## Health Checks & Self-Healing

The deployment includes multiple layers of health monitoring:

1. **Docker HEALTHCHECK**: Container-level health check every 30s
2. **Fly Syncthing TCP check**: Monitors port 22000 every 15s
3. **Fly Supercronic HTTP check**: Monitors `/health` on port 9746 every 30s
4. **Fly Syncthing API check**: Monitors `/rest/noauth/health` on port 8384 every 30s
5. **Supervisor autorestart**: Both services restart automatically if they crash

If any health check fails, Fly.io will restart the container.

## Logs

Logs go to stdout which ends up on Papertrail at:
<https://my.papertrailapp.com/events?q=json.message.app%3Asimt-syncthing-with-cron>

TODO: These logs need to be parsed properly by our fly-log-shipper instance.

## Log in to the Host

```sh
fly ssh console -a simt-syncthing-with-cron
```

## Syncthing Administration

The admin GUI is needed to:

- Add / accept connections to new peers (Syncthing network "devices")
- Accept folders shared by a peer

The admin GUI can be accessed by setting up a proxy through WireGuard:

```sh
fly proxy 38384:8384 -a simt-syncthing-with-cron
```

Then locally open <http://127.0.0.1:38384/>

## Fly Setup (First Deployment)

```sh
fly apps create --name "simt-syncthing-with-cron" --org microgridfoundry
fly volumes create --region lhr --size 1 --count 1 --yes syncthing_files -a simt-syncthing-with-cron
fly ips allocate-v4 --shared -a simt-syncthing-with-cron
fly deploy
```

## Subsequent Deployments

```sh
fly deploy
```

## Monitoring

Check the app status:

```sh
fly status -a simt-syncthing-with-cron
fly checks list -a simt-syncthing-with-cron
```

View logs:

```sh
fly logs -a simt-syncthing-with-cron
```
