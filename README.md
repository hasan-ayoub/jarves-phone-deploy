# Jarves — phone-friendly deploy

1. Extract the zip (Files app → tap it). You get ~10 files: upload them all to a new GitHub repo (browser upload works now).

## Render (all from your phone browser)
1. Upload the extracted files (incl. the docker folder) to a GitHub repo.
2. render.com → New → Blueprint → pick the repo → Apply.
3. First deploy takes ~10 min. Open the `.onrender.com` URL. Admin: `/jarves`.
(Persistent disk needs Render's paid plan; on free, data resets on redeploy — delete `disk:` from render.yaml to try free.)

## Railway / Fly
Both build the Dockerfile as-is. Set env `DB_TYPE=sqlite`, mount a volume at `/var/www/app/data`.

## Laptop
`docker compose up --build` → http://localhost:8080 (MySQL version)
