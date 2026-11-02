# ami-persona.nvim

Steer the advisor's style in [ami](https://github.com/moosch/ami.nvim).

A small extension that contributes a **persona instruction** to each chat request —
e.g. "be terse", a house voice, or a reviewer mindset — and lets you switch at
runtime. It returns its instruction to chat's `chat.system` collector hook (chat
composes it into the turn), so it's also the reference example of a return-style
contribution via a collector.

## Requirements

- [ami.nvim](https://github.com/moosch/ami.nvim) + [ami-chat.nvim](https://github.com/moosch/ami-chat.nvim).

## Install

```lua
{
  "moosch/ami.nvim",
  dependencies = { "moosch/ami-chat.nvim", "moosch/ami-persona.nvim" },
  config = function()
    require("ami").setup({
      extensions = { require("ami-chat"), require("ami-persona") },
      -- persona = { active = "terse" },   -- pick a built-in, or add your own below
    })
  end,
}
```

## Use

- `:AmiPersona` — pick a persona (no arg prompts; `off` disables injection).
- `:AmiPersona terse` / `:AmiPersona off` — set directly.
- `/persona [name|off]` — the same, as a slash-command in the ami-chat input.

Built-in personas: `terse`, `teacher`, `reviewer`, and `default` (a no-op). Add your
own under `personas` (they merge with the built-ins):

```lua
persona = {
  active = "house",
  personas = {
    house = "Use our house voice: calm, concrete, no hype. Cite the file/line when relevant.",
  },
}
```

## Configuration

| Key | Default | Meaning |
| --- | --- | --- |
| `enabled` | `true` | master switch (also toggled by `:AmiPersona off`) |
| `active` | `"default"` | which persona is injected (`default` = none) |
| `personas` | built-ins | `name -> instruction`; yours merge with the built-ins |

The active persona is added as a system message just after the advisor's system
prompt, so it shapes the reply without replacing ami's advisor identity. It applies
to chat turns (not inline completion or proactive nudges).

## License

[MIT](LICENSE)
