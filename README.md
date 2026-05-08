# TimeTill landing page

Static site at [timetillapp.com](https://timetillapp.com), deployed via GitHub Pages.

## Files

```
Landing/
  index.html        # main page (live countdown demo, features, screenshots)
  privacy.html      # privacy policy — required URL for App Store submission
  styles.css        # one stylesheet, dark mode + responsive
  icon.svg          # countdown ring icon (also favicon)
  og.png            # 1200×630 share preview for iMessage / Twitter / Slack
  generate_og.swift # regenerate og.png — `swift generate_og.swift`
  CNAME             # required by GitHub Pages → tells it timetillapp.com
```

## Deploy via GitHub Pages

### Option A — dedicated `timetill-website` repo (recommended)

1. Create a new public repo on GitHub called something like `timetill-website` or `timetillapp-com`.
2. Push the **contents** of this `Landing/` folder to the repo's root (not the folder itself, the contents):
   ```sh
   cd "TimeTill2/Landing"
   git init
   git add .
   git commit -m "Initial landing page"
   git branch -M main
   git remote add origin git@github.com:<you>/timetill-website.git
   git push -u origin main
   ```
3. On the repo: **Settings → Pages → Build and deployment**
   - Source: **Deploy from a branch**
   - Branch: **main** / **/ (root)** → Save
4. GitHub will publish to `https://<you>.github.io/timetill-website/` within a minute.
5. Same page → **Custom domain** → enter `timetillapp.com` → Save.
   The `CNAME` file in this folder already declares the domain, so this just confirms it.
6. Configure DNS (see below). After it propagates, GitHub auto-provisions a Let's Encrypt SSL cert. Tick **Enforce HTTPS**.

### Option B — using GitHub Actions to deploy from a subfolder of an existing repo

Skip if Option A is simpler. Use this if you'd rather keep the website inside an existing repo. Create `.github/workflows/pages.yml` in your repo:

```yaml
name: Deploy landing
on:
  push:
    branches: [main]
    paths: ["TimeTill2/Landing/**"]
permissions:
  contents: read
  pages: write
  id-token: write
jobs:
  deploy:
    runs-on: ubuntu-latest
    environment:
      name: github-pages
      url: ${{ steps.deployment.outputs.page_url }}
    steps:
      - uses: actions/checkout@v4
      - uses: actions/upload-pages-artifact@v3
        with:
          path: TimeTill2/Landing
      - id: deployment
        uses: actions/deploy-pages@v4
```

## DNS records for `timetillapp.com`

GitHub Pages serves from these IPs. Add them at your registrar's DNS panel:

| Type | Name | Value |
|------|------|-------|
| `A` | `@` | `185.199.108.153` |
| `A` | `@` | `185.199.109.153` |
| `A` | `@` | `185.199.110.153` |
| `A` | `@` | `185.199.111.153` |
| `CNAME` | `www` | `<your-github-username>.github.io` |

(Add all four `A` records — GitHub uses round-robin across them. Don't add a fifth or substitute.)

If your registrar supports IPv6 too, also add the `AAAA` records:

| Type | Name | Value |
|------|------|-------|
| `AAAA` | `@` | `2606:50c0:8000::153` |
| `AAAA` | `@` | `2606:50c0:8001::153` |
| `AAAA` | `@` | `2606:50c0:8002::153` |
| `AAAA` | `@` | `2606:50c0:8003::153` |

After DNS propagates (5 min – 24 hr), the GitHub Pages page in your repo settings will show ✓ DNS check successful, and you can tick "Enforce HTTPS".

## Before publishing — replace placeholders

Search-and-replace across `index.html` and `privacy.html`:

- `hello@timetillapp.com` → your real support email
- `href="#"` on the App Store buttons → your App Store URL once approved

## Local preview

```sh
cd Landing
python3 -m http.server 8000
# open http://localhost:8000
```

## Adding real screenshots later

The current showcase uses CSS-styled phone/watch mockups. Once your app is on the App Store and you've taken real screenshots:

1. Take in Simulator with `Cmd+S` (saves to Desktop)
2. Drop into `Landing/` (e.g. `screenshot-iphone.png`)
3. Replace the `<div class="device-iphone">` block in `index.html` with `<img src="screenshot-iphone.png" alt="…" />` + appropriate styling
4. Push, GitHub Pages auto-redeploys
