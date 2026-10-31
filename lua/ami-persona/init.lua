-- ami-persona: steer the advisor's style, as a standalone ami extension.
--
-- It hooks the chat_turn_pre event and injects a persona instruction as an extra
-- system message into each outgoing chat request — e.g. "be terse", a house voice,
-- a reviewer mindset. Switch personas at runtime with :AmiPersona.
--
--   require("ami").setup({
--     extensions = { require("ami-chat"), require("ami-persona") },
--     persona = { active = "terse" },   -- or add your own under `personas`
--   })
--
-- A reference example of a prompt-injection extension built purely on chat_turn_pre.
local state = { api = nil }

-- The active persona's instruction text (or nil when disabled / empty).
local function active_text()
  local c = state.api.config
  if not c.enabled then
    return nil
  end
  local text = (c.personas or {})[c.active or "default"]
  if text and vim.trim(text) ~= "" then
    return text
  end
  return nil
end

local function names()
  local out = { "off" }
  for k in pairs(state.api.config.personas or {}) do
    out[#out + 1] = k
  end
  table.sort(out)
  return out
end

local function set(name)
  local c = state.api.config
  if name == "off" then
    c.enabled = false
    state.api.notify("persona: off")
  elseif (c.personas or {})[name] ~= nil then
    c.enabled, c.active = true, name
    state.api.notify("persona: " .. name)
  else
    state.api.notify("no such persona '" .. tostring(name) .. "'", vim.log.levels.WARN)
  end
end

return {
  name = "persona",

  config = {
    enabled = true,
    active = "default", -- "default" is empty = no injection until you pick one
    -- name -> instruction. Users can add their own (merged with these).
    personas = {
      default = "",
      terse = "Be terse: prefer one or two lines, skip preamble and hedging unless a caveat is genuinely important.",
      teacher = "Teach as you go: briefly explain the why, and name the main trade-off or alternative.",
      reviewer = "Act as a critical code reviewer: lead with the single most important risk, bug, or smell you see.",
    },
  },

  -- Inject the persona as a system message, just after the advisor system prompt.
  events = {
    chat_turn_pre = function(req)
      local text = active_text()
      if text and req.messages then
        table.insert(req.messages, math.min(2, #req.messages + 1), { role = "system", content = text })
      end
    end,
  },

  commands = {
    AmiPersona = {
      desc = "Select the chat persona (no arg = pick; 'off' disables)",
      nargs = "?",
      complete = names,
      fn = function(opts)
        if opts.args ~= "" then
          set(opts.args)
        else
          vim.ui.select(names(), { prompt = "Persona:" }, function(choice)
            if choice then
              set(choice)
            end
          end)
        end
      end,
    },
  },

  setup = function(api)
    state.api = api
  end,
}
