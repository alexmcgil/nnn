{ config, lib, pkgs, ... }:

let
  memoryDir = "${config.home.homeDirectory}/Documents/Personal/agent-memory";
  uvx = "${pkgs.uv}/bin/uvx";
  handoffGuidance = ''
    В начале новой сессии проверь в Basic Memory (`agent-memory/handoffs`) активные handoff-заметки и используй подходящую по задаче. Перед продолжением сверь записанное с текущим состоянием репозиториев. Если останавливаешь незавершённую работу, обнови одну заметку: цель, репозитории, сделанное, проверки и следующий шаг. Не сохраняй пересказ чата.
  '';
in
{
  home.packages = with pkgs; [ uv codex opencode ];

  home.file.".codex/AGENTS.md".text = handoffGuidance;
  home.file.".codex-personal/AGENTS.md".text = handoffGuidance;
  xdg.configFile."opencode/AGENTS.md".text = handoffGuidance;

  # Конфиги агентов остаются изменяемыми: сохраняем остальные MCP и настройки.
  home.activation.basicMemory = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    mkdir -p "${memoryDir}" "$HOME/.basic-memory"
    config_file="$HOME/.basic-memory/config.json"
    temp_file=$(mktemp "$HOME/.basic-memory/config.json.XXXXXX")
    { if test -f "$config_file"; then cat "$config_file"; else printf '{}'; fi; } |
      ${pkgs.jq}/bin/jq --arg path "${memoryDir}" \
        '.projects = (.projects // {}) | .projects["agent-memory"] = { path: $path, mode: "local" } | .default_project = "agent-memory" | .project_root = $path' \
        > "$temp_file"
    if ! cmp -s "$config_file" "$temp_file"; then
      mv "$temp_file" "$config_file"
    else
      rm "$temp_file"
    fi

    for codex_home in "$HOME/.codex" "$HOME/.codex-personal"; do
      mkdir -p "$codex_home"
      CODEX_HOME="$codex_home" ${pkgs.codex}/bin/codex mcp add basic-memory -- ${uvx} basic-memory==1.0.0 mcp --project agent-memory
    done
    ${pkgs.opencode}/bin/opencode mcp add basic-memory --global -- ${uvx} basic-memory==1.0.0 mcp --project agent-memory
  '';
}
