# Handoff: MCP и инструменты OpenClaw

Статус: план, ничего из ниже не включено. Базовая версия OpenClaw:
`2026.11.1`.

## Текущая граница

- Gateway работает в Docker Compose.
- Агент видит и меняет только `/workspace` →
  `~/AI/openclaw-workspace`.
- Разрешены только `group:fs` и `group:memory`;
  `runtime`, `web`, `ui`, `automation`, `messaging`, `nodes`, `agents` и
  `plugins` запрещены.
- `workspaceOnly=true`, elevated tools выключены.
- Нет Docker socket, `exec`, MCP-серверов, сторонних plugins и
  skills.

Это безопасная точка возврата. Не расширять общие groups ради
одного инструмента.

## Главная особенность OpenClaw

Sandbox изолирует shell, дочерние процессы и файловые tools, но
не переносит сам Gateway, native plugins и MCP tools в sandbox. MCP и
plugins вызываются на стороне Gateway и лишь дополнительно
ограничиваются tool policy. Native plugin имеет те же права в
процессе, что и OpenClaw.

Отсюда два независимых контура:

1. Shell и файловые tools — в отдельном sandbox runtime.
2. MCP — в узких sidecar-контейнерах, каждый со своими mounts,
   секретами и сетью.

Официальные опорные документы:

- [MCP](https://docs.openclaw.ai/tools/mcp)
- [Sandbox modes, scope and backend](https://docs.openclaw.ai/gateway/sandboxing/modes-scope-and-backend)
- [Supported capability matrix](https://docs.openclaw.ai/gateway/sandboxing/supported-capability-matrix)
- [Docker backend](https://docs.openclaw.ai/gateway/sandboxing/docker-backend)
- [SSH backend](https://docs.openclaw.ai/gateway/sandboxing/ssh-backend)
- [Tool policy](https://docs.openclaw.ai/gateway/config-tools/tool-policy)
- [Plugin execution model](https://docs.openclaw.ai/plugins/architecture)
- [Exec approvals](https://docs.openclaw.ai/tools/exec-approvals)

## Контур A: MCP

### Предпочтительная схема

Каждый MCP-сервер запускать как отдельный Compose service:

- Streamable HTTP; SSE — только если сервер не умеет Streamable HTTP.
- Без host `ports`; только `expose` во внутреннюю Docker network.
- Gateway входит в эту network; MCP-sidecar не входит в общую
  сеть, если ему не нужен Internet.
- `read_only: true`, `cap_drop: [ALL]`, `no-new-privileges`, non-root user,
  tmpfs для `/tmp`.
- Ни Docker/Podman socket, ни Gateway state/auth, ни весь `$HOME` в sidecar
  не монтируются.
- Монтируется только нужный каталог с `:ro` или `:rw`.
- Секрет передаётся только этому sidecar через Compose secret/file.
  Если Bearer token нужен и Gateway, его ссылка хранится в
  игнорируемом `.env`, но не в tracked JSON.
- Image фиксируется по версии и digest.

Пример-каркас, не готовая конфигурация:

```yaml
services:
  openclaw-gateway:
    networks: [default, mcp-tools]

  mcp-example:
    image: vendor/server:VERSION@sha256:DIGEST
    expose: ["3000"]
    networks: [mcp-tools]
    read_only: true
    tmpfs: [/tmp]
    cap_drop: [ALL]
    security_opt: [no-new-privileges:true]
    volumes:
      - /explicit/allowed/path:/data:ro

networks:
  mcp-tools:
    internal: true
```

### Подключение к OpenClaw

Добавлять сервер через **Control UI → Settings → MCP → Add server**,
так как запущенный Gateway владеет live state. Базовая запись:

```json5
{
  mcp: {
    servers: {
      example: {
        url: "http://mcp-example:3000/mcp",
        transport: "streamable-http",
        requestTimeoutMs: 20000,
        connectionTimeoutMs: 5000,
        toolFilter: {
          include: ["read_*"],
          exclude: ["delete_*", "admin_*"],
        },
      },
    },
  },
}
```

После подключения:

1. `mcp probe` — получить реальные имена tools.
2. Убрать `group:plugins` из глобального `tools.deny` только
   одновременно с добавлением точных MCP tool names/server glob в
   `tools.alsoAllow`. Не разрешать весь `group:plugins`.
3. Если чаты sandboxed, те же точные names добавить в
   `tools.sandbox.tools.alsoAllow`: sandbox policy — второй независимый
   gate.
4. Для первого теста оставить только read-only tool. Write/delete
   включать по одному после проверки arguments и path validation.

Проверка без агентного turn:

```bash
docker exec openclaw-gateway node dist/index.js mcp status --verbose
docker exec openclaw-gateway node dist/index.js mcp doctor
docker exec openclaw-gateway node dist/index.js mcp probe example
```

Stdio MCP по умолчанию не использовать: процесс запускается в
контексте Gateway и видит его filesystem/env. Исключение — маленький
аудированный сервер без секретов и с отдельно обоснованным
риском.

## Web search: SearXNG

Для обычного поиска не нужен MCP-адаптер: OpenClaw имеет
официальный `@openclaw/searxng-plugin`, который даёт нормализованный
`web_search` через JSON API SearXNG. План:

1. Запустить official SearXNG image как отдельный Compose service,
   запиненный по версии и digest.
2. Не публиковать port на host. Gateway и SearXNG подключить к
   отдельной bridge network `web-search`.
3. Эта network не может быть `internal: true`: SearXNG нужен исходящий
   Internet для поисковиков. При ужесточении egress разрешить DNS и
   HTTP/HTTPS наружу, но блокировать RFC1918, link-local, metadata endpoints
   и остальную локальную сеть, кроме Gateway→SearXNG.
4. Хранить `settings.yml` и cache в отдельных служебных
   каталогах, не в agent workspace. Никаких user/Gateway secrets в
   SearXNG не монтировать.
5. В `settings.yml` обязательно включить `json` в `search.formats`,
   задать случайный `server.secret_key`, оставить `debug: false` и
   `public_instance: false`. Secret не коммитить.
6. Для одного внутреннего клиента сначала обойтись без Valkey и
   SearXNG limiter. Если сервис когда-нибудь появится в LAN/VPN,
   добавить reverse proxy/auth и Valkey-backed limiter до публикации.
7. Установить и включить точную проверенную версию official
   SearXNG plugin; добавить `searxng` в явный `plugins.allow`.
8. Явно выбрать provider `searxng`. Не использовать auto-detection и
   не настраивать fallback на платный/облачный search.

Предварительная OpenClaw-конфигурация:

```json5
{
  tools: {
    web: {
      search: {
        provider: "searxng",
        maxResults: 5,
        timeoutSeconds: 15,
      },
    },
  },
  plugins: {
    allow: ["memory-core", "lmstudio", "openai", "searxng"],
    entries: {
      searxng: {
        config: {
          webSearch: {
            baseUrl: "http://searxng:8080",
            categories: "general,news",
          },
        },
      },
    },
  },
}
```

В tool policy убрать `group:web` из `tools.deny`, одновременно:

- добавить только `web_search` в `tools.alsoAllow`;
- оставить `web_fetch`, `x_search` и browser в явном deny;
- при sandbox mode добавить только `web_search` в
  `tools.sandbox.tools.alsoAllow`.

`web_fetch` не включать автоматически: это отдельная способность с
более широким SSRF/prompt-injection риском. Результаты поиска тоже
считать недоверенным вводом: они не должны сами по себе разрешать
shell, запись файлов или передачу секретов.

Проверка перед включением агенту:

```bash
# Из Gateway network; ответ должен быть JSON.
docker exec openclaw-gateway curl -fsS \
  'http://searxng:8080/search?q=openclaw&format=json'

docker exec openclaw-gateway node dist/index.js plugins inspect searxng
docker exec openclaw-gateway node dist/index.js security audit --deep
```

Затем в **Control UI → Settings → Search** выполнить test search и
проверить один agent turn. В `docker compose ps` у SearXNG не должно
быть host-published port.

Официальные документы:

- [OpenClaw SearXNG search](https://docs.openclaw.ai/tools/searxng-search)
- [OpenClaw web search](https://docs.openclaw.ai/tools/web)
- [SearXNG Search API](https://docs.searxng.org/dev/search_api.html)
- [SearXNG container installation](https://docs.searxng.org/admin/installation-docker)

## Контур B: shell, Git и процессы

Цель — `agents.defaults.sandbox.mode="all"`, чтобы даже main session не
получала host execution. Для текущего containerized Gateway есть два
поддерживаемых пути.

### Вариант 1: изолированный SSH worker

Это наименьшее изменение текущего Gateway:

- Отдельный Compose service с `sshd`, `/bin/sh`, `python3`, GNU `stat` и
  `readlink`.
- Только внутренняя Docker network, без host port и Internet egress.
- Нет mounts Gateway state/auth, user home, Docker socket и SSH agent.
- Отдельные SSH key и pinned host key только для этого worker;
  существующие `~/.ssh` и user keys не используются.
- Ключ видит Gateway SSH backend, но не агент и не его shell.
- Worker image pinned; non-root login; `cap_drop: [ALL]`; `no-new-privileges`;
  лимиты CPU/RAM/PIDs.

Профиль OpenClaw:

```json5
{
  agents: {
    defaults: {
      sandbox: {
        mode: "all",
        backend: "ssh",
        scope: "agent",
        workspaceAccess: "rw",
        ssh: {
          target: "openclaw@openclaw-tool-worker:22",
          workspaceRoot: "/srv/openclaw-sandboxes",
          strictHostKeyChecking: true,
          updateHostKeys: true,
          identityFile: "/home/node/.config/openclaw/worker/id_ed25519",
          knownHostsFile: "/home/node/.config/openclaw/worker/known_hosts",
        },
      },
    },
  },
}
```

Важно: SSH backend один раз копирует локальный workspace, после чего
remote workspace становится source of truth. Автосинхронизации обратно в
`~/AI/openclaw-workspace` нет. Каталог `/srv/openclaw-sandboxes` нужно
сохранять в отдельном bind mount. `scope: "agent"` выбран для одного
персонального агента; для разных недоверенных профилей нужны
разные workers/OS users, так как SSH shell может видеть соседние remote
каталоги того же user.

### Вариант 2: весь OpenClaw в отдельном rootless Docker daemon

Gateway сам работает в Docker. Для создания sibling sandbox containers
ему нужны Docker CLI и daemon socket. В официальном image `2026.11.1`
нет ни `docker`, ни `podman` CLI. Простое монтирование
`/var/run/docker.sock` дало бы Gateway эквивалент root-контроля хоста,
поэтому этот вариант отклонён.

Отдельный daemon только для sandbox тоже не подходит: OpenClaw
требует тот же daemon, который запустил Gateway, и проверяет
его container identity перед переносом mounts. Поэтому план такой:

1. Отдельный rootless Docker daemon под system user `openclaw`.
2. Перенести в этот daemon весь OpenClaw Compose: Gateway, MCP-sidecars и
   будущие sandbox containers. Остальные host containers остаются в
   текущем daemon.
3. Дать system user доступ к OpenClaw state/auth и workspace, но не к
   SSH, KeePassXC, Documents и другим user secrets.
4. Собрать маленький derived Gateway image из того же pinned OpenClaw
   image, добавив только Docker CLI.
5. Подключить к Gateway socket этого же rootless daemon и задать
   `DOCKER_HOST`. Socket никогда не передавать в agent sandbox.
6. Собрать и запинить отдельный sandbox image с нужными CLI
   (`git`, `rg`, shell); не ставить пакеты в runtime.
7. Включить Docker sandbox с профилем `mode: "all"`, `scope: "session"`,
   `workspaceAccess: "rw"`, `readOnlyRoot: true`, tmpfs и `capDrop: ["ALL"]`.
   Для RO allowlist использовать только `sandbox.docker.binds` с `:ro`.
8. Сначала `network: "none"`; внешнюю сеть включать только после
   отдельного решения о DNS/egress policy.
9. После `sandbox explain` разрешить `exec`/`process` в режиме
   `ask` или узкого allowlist. Approvals снижают риск ошибки, но не
   заменяют filesystem/process isolation.

Выбор: SSH worker проще и не даёт Gateway container-engine socket;
rootless migration сохраняет host-backed workspace и даёт Docker browser,
но это более крупная операционная миграция.

## Какой механизм для какой задачи

- Чтение/запись в workspace: встроенные file tools; после включения
  sandbox они работают через его filesystem bridge.
- Git внутри workspace: `git` в sandbox image, сначала без сети,
  SSH agent и credentials. Push — отдельный этап с repo-scoped identity.
- Web search: official SearXNG provider и отдельный SearXNG sidecar;
  не MCP-адаптер и не browser automation.
- Внешние API: MCP-sidecar с точечным egress и отдельным token.
- Niri/Wayland: узкий host broker/MCP с белым списком операций.
  Не передавать агенту весь Wayland socket, D-Bus session или generic shell.
- Android и Telegram: это clients/channels, а не основание для расширения
  tool policy. Для недоверенных channels нужен sandbox mode `all` и
  отдельные session permissions.
- Browser/UI automation: отдельный browser sandbox только после
  анализа его сети, profile и CDP ingress. Host browser control не включать.
- Сторонний native plugin: только после code review и фиксации
  версии; по умолчанию предпочитать MCP-sidecar.

## Порядок внедрения

1. Первая read-only способность — SearXNG `web_search` по плану выше.
2. Вторая — один конкретный read-only MCP use case.
3. Проверить MCP image/source, запинить версию, создать sidecar без
   host ports и без mounts.
4. Запустить `mcp probe`, зафиксировать точный tool allowlist.
5. Проверить, что sidecar не видит Gateway state/auth, Docker socket и
   хостовые secrets.
6. После этого выбрать SSH worker или миграцию всего OpenClaw
   на отдельный rootless Docker daemon, затем включать shell.
7. Write/delete, общий Internet egress, Git credentials, browser и Wayland — только
   отдельными этапами.

## Приёмочные проверки

```bash
docker exec openclaw-gateway node dist/index.js config validate
docker exec openclaw-gateway node dist/index.js sandbox explain --json
docker exec openclaw-gateway node dist/index.js sandbox list
docker exec openclaw-gateway node dist/index.js mcp status --verbose
docker exec openclaw-gateway node dist/index.js mcp doctor
docker exec openclaw-gateway node dist/index.js security audit --deep
```

Дополнительно нужно доказать:

- RW в workspace работает; RO mount не принимает запись.
- `/home`, `~/.ssh`, password stores, Gateway state/auth и host sockets не видны.
- Sandbox container не privileged, без capabilities и без host network.
- MCP-sidecar не имеет host-published ports и лишнего egress.
- Запрещённый tool не появляется в catalog и не вызывается по имени.
- В logs нет tokens и полных sensitive tool arguments.

Live `~/AI/openclaw-state/openclaw.json` не перезаписывать целиком пока
Gateway работает: он содержит runtime/migration metadata. Изменения
применять через Control UI **Save & Publish** и затем зеркалить
только стабильные настройки в tracked `services/openclaw/openclaw.json`.
