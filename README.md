# Kokoro TTS on Railway

Readable copies of the start scripts used by the Railway template
"Kokoro TTS" (https://railway.com/deploy/kokoro-tts). The template itself runs official
images only; each start command unpacks the script shown here.

| Service | Image | Script |
|---|---|---|
| Kokoro (public gateway) | `caddy:2.11.9-alpine@sha256:0bbb055bda6793c999bde78b1b5ce3e89f829fb031af2cf50056ea1246559fee` | `gateway-start.sh` (embeds `Caddyfile`) |
| Kokoro-API (private) | `ghcr.io/remsky/kokoro-fastapi-cpu:v0.10.0@sha256:f54c5960c2b9387f6349080a9944f8bc7e8cdb98a4ef9238cb0b0f9ff9795f44` | `kokoro-start.sh` |

## How access works

- `KOKORO_API_KEY` is generated at deploy on the Kokoro service.
- API clients send `Authorization: Bearer <key>` (or `xi-api-key` / `X-API-Key`).
- Browsers get a Basic-auth prompt: user `kokoro`, password = the API key. The
  gateway then forwards with the Bearer key, so the built-in web player at
  `/web/` works.
- Kokoro-API also enforces the key itself (`API_KEYS`), so it stays protected
  even if someone gives it a public domain.
- Open without a key: `/healthz` (gateway), `/health` (Kokoro), and the
  redirect from `/` to `/web/`.

## CPU threads

PyTorch starts one thread per host core. On a CPU-limited container that
oversubscribes the quota and makes speech dozens of times slower, so
`kokoro-start.sh` sets `OMP_NUM_THREADS` to the container's CPU limit, at most
8. Set `OMP_NUM_THREADS` on Kokoro-API to override.

## Rebuilding the start commands

```sh
echo "sh -c 'echo $(gzip -9nc gateway-start.sh | base64 -w0) | base64 -d | gunzip > /tmp/start.sh && exec sh /tmp/start.sh'"
echo "sh -c 'echo $(base64 -w0 kokoro-start.sh) | base64 -d > /tmp/start.sh && exec sh /tmp/start.sh'"
```
