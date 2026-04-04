# anki-desktop-docker (CI-ready with AnkiConnect)

This Docker image provides a headless-capable Anki desktop installation, designed for **use in CI environments**. It is based on [mlcivilengineer/anki-desktop-docker](https://github.com/mlcivilengineer/anki-desktop-docker) and includes:

- ✅ Pre-installed **Anki Desktop**
- 🔌 Bundled **AnkiConnect** plugin (ID: `2055492159`)
- 🐳 Ready to run in GitHub Actions or other CI/CD pipelines

---

# 🐳 Usage
```bash
docker run -d \
  --name anki \
  -p 8765:8765 \
  pull ghcr.io/spigell/anki-desktop-docker:25.09.2-latest

This starts the Anki desktop in the background and exposes AnkiConnect on http://localhost:8765.
```

**This image is intended for CI and trusted environments. Do not expose AnkiConnect to the public internet without proper authentication and proxying.**

# 📦 License & Credits
    Based on mlcivilengineer/anki-desktop-docker
    Anki Desktop is © Anki developers, licensed under AGPLv3
    AnkiConnect is © its authors, licensed under MIT
