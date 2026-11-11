# anki-desktop-docker (CI-ready with AnkiConnect)

This Docker image provides a headless-capable Anki desktop installation, designed for **use in CI environments** and long-lived single-replica deployments. It is based on [mlcivilengineer/anki-desktop-docker](https://github.com/mlcivilengineer/anki-desktop-docker) and includes:

- ✅ Pre-installed **Anki Desktop**
- 🔌 Bundled **AnkiConnect** plugin (ID: `2055492159`)
- 🐳 Ready to run in GitHub Actions or other CI/CD pipelines

---

# 🐳 Usage
```bash
docker run -d \
  --name anki \
  -p 3000:3000 \
  -p 8765:8765 \
  -e ANKICONNECT_API_KEY=change-me \
  -v anki-config:/config \
  ghcr.io/spigell/anki-desktop-docker:25.02.5-latest
```

This starts the Anki desktop in the background, serves the KasmVNC web UI on http://localhost:3000 (HTTPS on `3001`), and exposes AnkiConnect on http://localhost:8765.

For CI you can drop `-v` and `-e`: the image still starts with an empty `/config` and seeds a fresh profile.

## Ports

| Port   | Purpose                                                      |
| ------ | ------------------------------------------------------------ |
| `3000` | KasmVNC web UI (HTTP). Set `CUSTOM_USER`/`PASSWORD` to protect it. |
| `3001` | KasmVNC web UI (HTTPS)                                       |
| `8765` | AnkiConnect HTTP API                                         |

## `/config` volume

`/config` is the `abc` user's home. The Anki profile lives in `/config/Anki2` (collection, media, add-ons and `prefs21.db`); the KasmVNC/openbox settings sit next to it in `/config/.config`.

- On the first start, `/config/Anki2` is seeded from the image defaults in `/defaults/Anki2`. An existing profile is never overwritten. Ownership is reset to `abc` on every start.
- On every start, the bundled AnkiConnect add-on is copied into `/config/Anki2/addons21/2055492159/`, so an existing profile always runs the image's AnkiConnect. The rest of the profile is untouched.
- A volume from an older image whose `/config/.config/openbox/autostart` or `menu.xml` still launches Anki on `/tmp/Anki2` gets those files replaced with the image defaults on start, so Anki uses `/config/Anki2`. Customised files without `/tmp/Anki2` are left alone.
- If any of these steps fails (for example the config cannot be written), the container does not start Anki.
- After you sign in to AnkiWeb, `prefs21.db` holds your AnkiWeb login. **Treat the volume as a secret**: do not share it, bake it into an image or commit it.
- Only **one container may use a profile at a time**. Run a single replica and stop the old container before starting a new one on the same volume (on Kubernetes, use the `Recreate` strategy).

## `ANKICONNECT_API_KEY`

On every start, AnkiConnect's `config.json` in `/config/Anki2/addons21/2055492159/` is rewritten from the image default:

- `apiKey` is set to `ANKICONNECT_API_KEY` when it is set and non-empty, and to `null` (no authentication) otherwise. The key is never logged.
- `webBindAddress` is set to `ANKICONNECT_BIND_ADDRESS` when it is set and non-empty, and stays `0.0.0.0` otherwise (see below). `webBindPort` stays `8765`. Overrides of these keys saved via Anki's add-on config dialog are dropped on start.

Clients must then send the key as `"key"` in every request, e.g.:

```bash
curl -s localhost:8765 -d '{"action":"version","version":6,"key":"change-me"}'
```

## `ANKICONNECT_BIND_ADDRESS`

Sets the address AnkiConnect listens on. Leave it unset or empty to keep the default `0.0.0.0` (all interfaces), as CI does.

When the only client runs next to Anki, for example an MCP sidecar in the same Kubernetes pod, bind to loopback so AnkiConnect is unreachable from outside the pod even without an API key:

```yaml
env:
  - name: ANKICONNECT_BIND_ADDRESS
    value: "127.0.0.1"
```

With `127.0.0.1`, publishing port `8765` (`-p 8765:8765`) no longer reaches AnkiConnect from the host.

## One-time AnkiWeb login

1. Start the container with a persistent `/config` volume.
2. Open the web UI on port `3000`, click **Sync** in Anki and sign in with your AnkiWeb account.
3. The login is stored in `/config/Anki2/prefs21.db` and survives restarts; you do not need to sign in again.

**Do not expose AnkiConnect or the web UI to the public internet without `ANKICONNECT_API_KEY`, web UI credentials and proper proxying.**

# 📦 License & Credits
    Based on mlcivilengineer/anki-desktop-docker
    Anki Desktop is © Anki developers, licensed under AGPLv3
    AnkiConnect is © its authors, licensed under MIT
