-- Gp (GPT prompt) lua plugin for Neovim
-- forked from https://github.com/Robitx/gp.nvim/

--------------------------------------------------------------------------------
-- Default config
--------------------------------------------------------------------------------

local config = {
  -- Please start with minimal config possible.
  -- 1. openai_api_key if you don't have AI_API_KEY env set up.
  -- 2. open_api_endpoint if you don't have AI_API_HOST env set up.

  -- required openai api key (string or table with command and arguments)
  -- openai_api_key = { "cat", "path_to/openai_api_key" },
  -- openai_api_key = { "bw", "get", "password", "OPENAI_API_KEY" },
  -- openai_api_key: "sk-...",
  -- openai_api_key = os.getenv("env_name.."),
  openai_api_key = os.getenv("AI_API_KEY"),
  openai_api_endpoint = os.getenv("AI_API_HOST"),
  -- prefix for all commands
  cmd_prefix = "Gp",
  -- optional curl parameters (for proxy, etc.)
  -- curl_params = { "--proxy", "http://X.X.X.X:XXXX" }
  curl_params = {},

  -- directory for persisting state dynamically changed by user (like model or persona)
  state_dir = vim.fn.stdpath("data"):gsub("/$", "") .. "/gp/persisted",

  -- default command agents (model + persona)
  -- name, model and system_prompt are mandatory fields
  -- to use agent for chat set chat = true, for command set command = true
  -- to remove some default agent completely set it just with the name like:
  -- agents = {  { name = "GPT-4" }, ... },
  agents = {
    {
      name = "GPT-3.5T",
      chat = true,
      command = false,
      model = { model = "gpt-3.5-turbo" },
      system_prompt = "You are a general AI assistant.\n\n"
        .. "The user provided the additional info about how they would like you to respond:\n\n"
        .. "- If you're unsure don't guess and say you don't know instead.\n"
        .. "- Ask question if you need clarification to provide better answer.\n"
        .. "- Think deeply and carefully from first principles step by step.\n"
        .. "- Zoom out first to see the big picture and then zoom in to details.\n"
        .. "- Use Socratic method to improve your thinking and coding skills.\n"
        .. "- Don't elide any code from your output if the answer requires coding.\n"
        .. "- Take a deep breath; You've got this!\n",
    },
    {
      name = "GPT-4",
      chat = true,
      command = false,
      model = { model = "gpt-4" },
      system_prompt = "You are a general AI assistant.\n\n"
        .. "The user provided the additional info about how they would like you to respond:\n\n"
        .. "- If you're unsure don't guess and say you don't know instead.\n"
        .. "- Ask question if you need clarification to provide better answer.\n"
        .. "- Think deeply and carefully from first principles step by step.\n"
        .. "- Zoom out first to see the big picture and then zoom in to details.\n"
        .. "- Use Socratic method to improve your thinking and coding skills.\n"
        .. "- Don't elide any code from your output if the answer requires coding.\n"
        .. "- Take a deep breath; You've got this!\n",
    },
    {
      name = "GPT-3.5T-16K",
      chat = false,
      command = true,
      model = { model = "gpt-3.5-turbo-16k" },
      system_prompt = "You are an AI working as a code editor.\n\n"
        .. "Please AVOID COMMENTARY OUTSIDE OF THE SNIPPET RESPONSE.\n"
        .. "START AND END YOUR ANSWER WITH:\n\n```",
    },
  },

  -- directory for storing chat files
  chat_dir = vim.fn.stdpath("data"):gsub("/$", "") .. "/gp/chats",
  -- chat user prompt prefix
  chat_user_prefix = "🗨:",
  -- chat assistant prompt prefix (static string or a table {static, template})
  -- first string has to be static, second string can contain template {{agent}}
  -- just a static string is legacy and the [{{agent}}] element is added automatically
  -- if you really want just a static string, make it a table with one element { "🤖:" }
  chat_assistant_prefix = { "🤖:", "[{{agent}}]" },
  -- chat topic generation prompt
  chat_topic_gen_prompt = "Summarize the topic of our conversation above"
    .. " in two or three words. Respond only with those words.",
  -- chat topic model (string with model name or table with model name and parameters)
  chat_topic_gen_model = "gpt-3.5-turbo",
  -- explicitly confirm deletion of a chat file
  chat_confirm_delete = false,
  -- conceal model parameters in chat
  chat_conceal_model_params = false,
  -- local shortcuts bound to the chat buffer
  -- (be careful to choose something which will work across specified modes)
  chat_shortcut_respond = { modes = { "n", "i", "v", "x" }, shortcut = "<C-g><C-g>" },
  chat_shortcut_delete = { modes = { "n", "i", "v", "x" }, shortcut = "<C-g>d" },
  chat_shortcut_stop = { modes = { "n", "i", "v", "x" }, shortcut = "<C-g>s" },
  chat_shortcut_new = { modes = { "n", "i", "v", "x" }, shortcut = "<C-g>c" },
  -- default search term when using :GpChatFinder
  chat_finder_pattern = "topic ",
  -- if true, finished ChatResponder won't move the cursor to the end of the buffer
  chat_free_cursor = false,

  -- how to display GpChatToggle or GpContext: popup / split / vsplit / tabnew
  toggle_target = "vsplit",

  -- styling for chatfinder
  -- border can be "single", "double", "rounded", "solid", "shadow", "none"
  style_chat_finder_border = "single",
  -- margins are number of characters or lines
  style_chat_finder_margin_bottom = 8,
  style_chat_finder_margin_left = 1,
  style_chat_finder_margin_right = 2,
  style_chat_finder_margin_top = 2,
  -- how wide should the preview be, number between 0.0 and 1.0
  style_chat_finder_preview_ratio = 0.5,

  -- styling for popup
  -- border can be "single", "double", "rounded", "solid", "shadow", "none"
  style_popup_border = "single",
  -- margins are number of characters or lines
  style_popup_margin_bottom = 8,
  style_popup_margin_left = 1,
  style_popup_margin_right = 2,
  style_popup_margin_top = 2,
  style_popup_max_width = 160,

  -- command config and templates bellow are used by commands like GpRewrite, GpEnew, etc.
  -- command prompt prefix for asking user for input (supports {{agent}} template variable)
  command_prompt_prefix_template = "🤖 {{agent}} ~ ",
  -- auto select command response (easier chaining of commands)
  -- if false it also frees up the buffer cursor for further editing elsewhere
  command_auto_select_response = true,

  -- templates
  template_selection = "I have the following from {{filename}}:"
    .. "\n\n```{{filetype}}\n{{selection}}\n```\n\n{{command}}",
  template_rewrite = "I have the following from {{filename}}:"
    .. "\n\n```{{filetype}}\n{{selection}}\n```\n\n{{command}}"
    .. "\n\nRespond exclusively with the snippet that should replace the selection above.",
  template_append = "I have the following from {{filename}}:"
    .. "\n\n```{{filetype}}\n{{selection}}\n```\n\n{{command}}"
    .. "\n\nRespond exclusively with the snippet that should be appended after the selection above.",
  template_prepend = "I have the following from {{filename}}:"
    .. "\n\n```{{filetype}}\n{{selection}}\n```\n\n{{command}}"
    .. "\n\nRespond exclusively with the snippet that should be prepended before the selection above.",
  template_command = "{{command}}",

  -- example hook functions (see Extend functionality section in the README)
  hooks = {
    InspectPlugin = function(plugin, params)
      local bufnr = vim.api.nvim_create_buf(false, true)
      local copy = vim.deepcopy(plugin)
      local key = copy.config.openai_api_key
      copy.config.openai_api_key = key:sub(1, 3) .. string.rep("*", #key - 6) .. key:sub(-3)
      local plugin_info = string.format("Plugin structure:\n%s", vim.inspect(copy))
      local params_info = string.format("Command params:\n%s", vim.inspect(params))
      local lines = vim.split(plugin_info .. "\n" .. params_info, "\n")
      vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, lines)
      vim.api.nvim_win_set_buf(0, bufnr)
    end,

    -- GpImplement rewrites the provided selection/range based on comments in it
    Implement = function(gp, params)
      local template = "Having following from {{filename}}:\n\n"
        .. "```{{filetype}}\n{{selection}}\n```\n\n"
        .. "Please rewrite this according to the contained instructions."
        .. "\n\nRespond exclusively with the snippet that should replace the selection above."

      local agent = gp.get_command_agent()
      gp.info("Implementing selection with agent: " .. agent.name)

      gp.Prompt(
        params,
        gp.Target.rewrite,
        nil, -- command will run directly without any prompting for user input
        agent.model,
        template,
        agent.system_prompt
      )
    end,

    -- your own functions can go here, see README for more examples like
    -- :GpExplain, :GpUnitTests.., :GpTranslator etc.

    -- -- example of making :%GpChatNew a dedicated command which
    -- -- opens new chat with the entire current buffer as a context
    -- BufferChatNew = function(gp, _)
    -- 	-- call GpChatNew command in range mode on whole buffer
    -- 	vim.api.nvim_command("%" .. gp.config.cmd_prefix .. "ChatNew")
    -- end,

    -- -- example of adding command which opens new chat dedicated for translation
    -- Translator = function(gp, params)
    -- 	local agent = gp.get_command_agent()
    -- 	local chat_system_prompt = "You are a Translator, please translate between English and Chinese."
    -- 	gp.cmd.ChatNew(params, agent.model, chat_system_prompt)
    -- end,

    -- -- example of adding command which writes unit tests for the selected code
    UnitTests = function(gp, params)
      local template = "I have the following code from {{filename}}:\n\n"
        .. "```{{filetype}}\n{{selection}}\n```\n\n"
        .. "Please respond by writing table driven unit tests for the code above."
      local agent = gp.get_command_agent()
      gp.Prompt(params, gp.Target.enew, nil, agent.model, template, agent.system_prompt)
    end,

    -- -- example of adding command which explains the selected code
    Explain = function(gp, params)
      local template = "I have the following code from {{filename}}:\n\n"
        .. "```{{filetype}}\n{{selection}}\n```\n\n"
        .. "Please respond by explaining the code above."
      local agent = gp.get_chat_agent()
      gp.Prompt(params, gp.Target.popup, nil, agent.model, template, agent.system_prompt)
    end,
  },
}

return config
