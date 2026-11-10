# OpenClaw

Gateway работает из официального Docker-образа `2026.11.1`, закреплённого по
digest. LM Studio остаётся отдельным host-приложением; Ollama не используется.

## Первый запуск

1. В LM Studio откройте **Developer → Server Settings → Manage Tokens**, создайте
   отдельный токен OpenClaw и вставьте его в `.env` как `LM_API_TOKEN`.
2. Запустите Gateway:

   ```bash
   test -e ~/AI/openclaw-state/openclaw.json || \
     install -m 600 openclaw.json ~/AI/openclaw-state/openclaw.json
   docker compose up -d openclaw-gateway
   docker compose ps
   ```

3. Для ChatGPT/Codex OAuth выполните интерактивно:

   ```bash
   docker exec -it openclaw-gateway node dist/index.js \
     models auth login --provider openai --method device-code
   ```

   Команда не меняет default-модель. В чате переключение только текущей сессии:
   `/model lmstudio/qwen35 -s` или `/model openai/gpt-6-astra -s`.

4. В Linux-приложении выберите **On another computer**, URL
   `ws://127.0.0.1:18789` и token из `.env`. Это не запускает второй Gateway.

На NixOS официальный AppImage `2026.11.1` запускается через `appimage-run`, но
его встроенный WebKitGTK не проходит новый capability-check Control UI. Нажмите
**Open in browser**: откроется тот же Docker Gateway, второй Gateway не
запускается. Повторно проверить native WebView стоит после обновления AppImage.

Для `qwen35` базовый проверенный профиль в **LM Studio → My Models →
gear → per-model defaults**: GPU offload `40%` и context length `32768`.
Автоматический placement этой Q8 модели на RTX 3070 завершался `SIGABRT`;
профиль 40% занимает около 5.61 ГБ VRAM. В Server Settings оставьте
включёнными JIT loading и auto-unload.
Больший context можно сохранить в per-model defaults, уменьшив GPU offload
и оставив KV cache/слои в RAM. У `qwen35` native window `262144`, а
активный OpenClaw cap — `131072` tokens; фактический load context определяет
per-model profile LM Studio.

Все установленные LLM добавлены через LM Studio discovery в режиме
`models.mode=merge`. После установки новой модели обновите catalog:

```bash
docker exec openclaw-gateway node dist/index.js \
  models list --provider lmstudio --refresh
```

OpenClaw не имеет отдельной chat-команды unload. При `preload=false` lifecycle
контролируют JIT/TTL и auto-unload LM Studio; вручную из host terminal:

```bash
lms ps
lms unload <instance-id>
lms unload --all
```

`--all` выгрузит и embedding-модель памяти; она загрузится снова при
следующем memory search. Проверенная ручная загрузка `qwen35` на 128K с
переносом большей части в RAM:

```bash
lms unload qwen35
lms load qwen35 --gpu 0.2 --context-length 131072 --parallel 1 \
  --ttl 3600 --identifier qwen35 --yes
```

Оценка LM Studio: около 5.90 GiB GPU и 20.13 GiB total memory. Это
настройка текущего instance; для следующих JIT loads её нужно
сохранить как per-model default в LM Studio.

## Управление

```bash
docker compose up -d openclaw-gateway
docker compose stop openclaw-gateway
docker compose restart openclaw-gateway
docker compose logs --tail=100 openclaw-gateway
docker exec openclaw-gateway sh -lc \
  'node dist/index.js gateway health --url ws://127.0.0.1:18789 --token "$OPENCLAW_GATEWAY_TOKEN"'
docker exec openclaw-gateway sh -lc \
  'node dist/index.js security audit --deep --token "$OPENCLAW_GATEWAY_TOKEN"'
```

Обновление выполняется только явной заменой версии и digest образа в
`compose.yaml`, затем `docker compose pull && docker compose up -d`.
После правки tracked-шаблона `openclaw.json` установите его в state командой
`install -m 600 openclaw.json ~/AI/openclaw-state/openclaw.json` и перезапустите
Gateway. OpenClaw может добавлять в state-копию служебные migration markers.

## Доступ к файлам

- RW: `~/AI/openclaw-workspace`.
- Служебное состояние: `~/AI/openclaw-state` и `~/AI/openclaw-auth`; это не
  workspace, файловые инструменты ограничены `workspaceOnly`.
- RO: по умолчанию отсутствует. Для allowlist скопируйте
  `compose.readonly.yaml.example` в игнорируемый `compose.readonly.yaml`, замените
  source и запускайте Compose с `-f compose.yaml -f compose.readonly.yaml`.
- Остальной host filesystem не смонтирован. Docker socket, `/`, `$HOME`,
  `Documents`, Syncthing, SSH и хранилища паролей не монтируются.

Gateway публикуется на всех интерфейсах хоста: loopback, LAN и VPN.
Такой bind не зависит от порядка поднятия сетевых интерфейсов при
загрузке; доступ защищён token-auth. Для Android добавьте отдельный peer
в `modules/wireguard-p2p.nix`, затем подключайтесь к `ws://10.66.66.2:18789` с token
и подтвердите pairing. Telegram позже можно добавить через `channels add`,
не меняя mounts.

Shell/процессы, browser/web, automation, MCP и plugin tools отключены. Это
компенсирует отсутствие отдельного tool-sandbox: Docker socket намеренно не
подключён. Для полноценного Docker sandbox потребуется отдельное согласование
риска socket и пересмотр tool policy.

План безопасного подключения MCP, SearXNG web search, shell, Git и
будущего Niri broker:
[`TOOLING-HANDOFF.md`](./TOOLING-HANDOFF.md).
