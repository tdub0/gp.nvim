<!-- panvimdoc-ignore-start -->

<a href="https://github.com/tdub0/gp.nvim/blob/main/LICENSE"><img alt="GitHub" src="https://img.shields.io/github/license/tdub0/gp.nvim"></a>

# Gp.nvim (GPT prompt) Neovim AI plugin

<!-- panvimdoc-ignore-end -->

<br>

**ChatGPT like sessions and Instructable text/code operations in your favorite editor. This forked version does not contain speech to text or image generation capabilities.**

<p align="left">
<img src="https://github.com/Robitx/gp.nvim/assets/8431097/cb288094-2308-42d6-9060-4eb21b3ba74c" width="49%">
<img src="https://github.com/Robitx/gp.nvim/assets/8431097/c538f0a2-4667-444e-8671-13f8ea261be1" width="49%">
</p>

# Goals and Features

The goal is to extend Neovim with the **power of GPT models in a simple unobtrusive extensible way.**  
Trying to keep things as native as possible - reusing and integrating well with the natural features of (Neo)vim.

- **Streaming responses**
  - no spinner wheel and waiting for the full answer
  - response generation can be canceled half way through
  - properly working undo (response can be undone with a single `u`)
- **Infinitely extensible** via hook functions specified as part of the config
  - hooks have access to everything in the plugin and are automatically registered as commands
  - see [4. Configuration](#4-configuration) and [Extend functionality](#extend-functionality) sections for details
- **Minimum dependencies** (`neovim`, `curl`, `grep` and optionally `sox`)
  - zero dependencies on other lua plugins to minimize chance of breakage
- **ChatGPT like sessions**
  - just good old neovim buffers formated as markdown with autosave and few buffer bound shortcuts
  - last chat also quickly accessible via toggable popup window
  - chat finder - management popup for searching, previewing, deleting and opening chat sessions
- **Instructable text/code operations**
  - templating mechanism to combine user instructions, selections etc into the gpt query
  - multimodal - same command works for normal/insert mode, with selection or a range
  - many possible output targets - rewrite, prepend, append, new buffer, popup
  - non interactive command mode available for common repetitive tasks implementable as simple hooks  
    (explain something in a popup window, write unit tests for selected code into a new buffer,  
    finish selected code based on comments in it, etc.)
  - custom instructions per repository with `.gp.md` file  
    (instruct gpt to generate code using certain libs, packages, conventions and so on)

# Install

## 1. Install the plugin

Snippets for your preferred package manager:

```lua
-- lazy.nvim
{
	"tdub0/gp.nvim",
	config = function()
		require("gp").setup()

		-- or setup with your own config (see Install > Configuration in Readme)
		-- require("gp").setup(config)

        	-- shortcuts might be setup here (see Usage > Shortcuts in Readme)
	end,
}
```

```lua
-- packer.nvim
use({
    "tdub0/gp.nvim",
    config = function()
        require("gp").setup()

	-- or setup with your own config (see Install > Configuration in Readme)
	-- require("gp").setup(config)

        -- shortcuts might be setup here (see Usage > Shortcuts in Readme)
    end,
})
```

## 2. API Key and Host

The default configuration expects two environment variables to connect to the intended GPT instance: `AI_API_KEY` with the API key and `AI_API_HOST` with the GPT URL. The configuration setting `openai_api_key` is set to the value of `AI_API_KEY` and `openai_api_endpoint` is set to the value of `AI_API_HOST`.

The API key and host values can be passed to the plugin in multiple ways:

| Method                    | Example                                                        | Security Level      |
| ------------------------- | -------------------------------------------------------------- | ------------------- |
| hardcoded string          | `openai_api_key: "sk-...",`                                    | Low                 |
| default env var           | set `AI_API_KEY` environment variable in shell config      | Medium              |
| custom env var            | `openai_api_key = os.getenv("CUSTOM_ENV_NAME"),`               | Medium              |
| read from file            | `openai_api_key = { "cat", "path_to_api_key" },`               | Medium-High         |
| password manager          | `openai_api_key = { "bw", "get", "password", "OAI_API_KEY" },` | High                |

If `openai_api_key` is a table, Gp runs it asynchronously to avoid blocking Neovim (password managers can take a second or two).

## 3. Dependencies

The core plugin only needs `curl` installed to make calls to OpenAI API and `grep` for ChatFinder. So Linux, BSD and Mac OS should be covered.

## 4. Configuration

Below is a linked snippet with the default values, but I suggest starting with minimal config possible (just `openai_api_key` if you don't have `AI_API_KEY` env set up and `openai_api_endpoint` if you don't have `AI_API_HOST` env setup). Defaults change over time to improve things, options might get deprecated and so on - it's better to change only things where the default doesn't fit your needs.

https://github.com/tdub0/gp.nvim/blob/main/lua/gp/config.lua#L7-L219

# Usage

## Chat commands

#### `:GpChatNew` <!-- {doc=:GpChatNew}  -->

Open a fresh chat in the current window. It can be either empty or include the visual selection or specified range as context. This command also supports subcommands for layout specification:

- `:GpChatNew vsplit` Open a fresh chat in a vertical split window.
- `:GpChatNew split` Open a fresh chat in a horizontal split window.
- `:GpChatNew tabnew` Open a fresh chat in a new tab.
- `:GpChatNew popup` Open a fresh chat in a popup window.

#### `:GpChatPaste` <!-- {doc=:GpChatPaste}  -->

Paste the selection or specified range into the latest chat, simplifying the addition of code from multiple files into a single chat buffer. This command also supports subcommands for layout specification:

- `:GpChatPaste vsplit` Paste into the latest chat in a vertical split window.
- `:GpChatPaste split` Paste into the latest chat in a horizontal split window.
- `:GpChatPaste tabnew` Paste into the latest chat in a new tab.
- `:GpChatPaste popup` Paste into the latest chat in a popup window.

#### `:GpChatToggle` <!-- {doc=:GpChatToggle}  -->

Open chat in a toggleable popup window, showing the last active chat or a fresh one with selection or a range as a context. This command also supports subcommands for layout specification:

- `:GpChatToggle vsplit` Toggle chat in a vertical split window.
- `:GpChatToggle split` Toggle chat in a horizontal split window.
- `:GpChatToggle tabnew` Toggle chat in a new tab.
- `:GpChatToggle popup` Toggle chat in a popup window.

#### `:GpChatFinder` <!-- {doc=:GpChatFinder}  -->

Open a dialog to search through chats.

#### `:GpChatRespond` <!-- {doc=:GpChatRespond}  -->

Request a new GPT response for the current chat. Usin`:GpChatRespond N` request a new GPT response with only the last N messages as context, using everything from the end up to the Nth instance of `🗨:..` (N=1 is like asking a question in a new chat).

#### `:GpChatDelete` <!-- {doc=:GpChatDelete}  -->

Delete the current chat. By default requires confirmation before delete, which can be disabled in config using `chat_confirm_delete = false,`.

## Text/Code commands

#### `:GpRewrite`<!-- {doc=:GpRewrite}  -->

Opens a dialog for entering a prompt. After providing prompt instructions into the dialog, the generated response replaces the current line in normal/insert mode, selected lines in visual mode, or the specified range (e.g., `:%GpRewrite` applies the rewrite to the entire buffer).

`:GpRewrite {prompt}` Executes directly with specified `{prompt}` instructions, bypassing the dialog. Suitable for mapping repetitive tasks to keyboard shortcuts or for automation using headless Neovim via terminal or shell scripts.

#### `:GpAppend` <!-- {doc=:GpAppend}  -->

Similar to `:GpRewrite`, but the answer is added after the current line, visual selection, or range.

#### `:GpPrepend` <!-- {doc=:GpPrepend}  -->

Similar to `:GpRewrite`, but the answer is added before the current line, visual selection, or range.

#### `:GpEnew` <!-- {doc=:GpEnew}  -->

Similar to `:GpRewrite`, but the answer is added into a new buffer in the current window.

#### `:GpNew` <!-- {doc=:GpNew}  -->

Similar to `:GpRewrite`, but the answer is added into a new horizontal split window.

#### `:GpVnew` <!-- {doc=:GpVnew}  -->

Similar to `:GpRewrite`, but the answer is added into a new vertical split window.

#### `:GpTabnew` <!-- {doc=:GpTabnew}  -->

Similar to `:GpRewrite`, but the answer is added into a new tab.

#### `:GpPopup` <!-- {doc=:GpPopup}  -->

Similar to `:GpRewrite`, but the answer is added into a pop-up window.

#### `:GpImplement` <!-- {doc=:GpImplement}  -->

Example hook command to develop code from comments in a visual selection or specified range.

#### `:GpContext`<!-- {doc=:GpContext}  -->

Provides custom context per repository:

- opens `.gp.md` file for a given repository in a toggable window.
- appends selection/range to the context file when used in visual/range mode.
- also supports subcommands for layout specification:

  - `:GpContext vsplit` Open `.gp.md` in a vertical split window.
  - `:GpContext split` Open `.gp.md` in a horizontal split window.
  - `:GpContext tabnew` Open `.gp.md` in a new tab.
  - `:GpContext popup` Open `.gp.md` in a popup window.

- refer to [Custom Instructions](#custom-instructions) for more details.

## Agent commands

#### `:GpNextAgent` <!-- {doc=:GpNextAgent}  -->

Cycles between available agents based on the current buffer (chat agents if current buffer is a chat and command agents otherwise). The agent setting is persisted on disk across Neovim instances.

#### `:GpAgent` <!-- {doc=:GpAgent}  -->

Displays currently used agents for chat and command instructions.

#### `:GpAgent XY` <!-- {doc=:GpAgent-XY}  -->

Choose a new agent based on its name, listing options based on the current buffer (chat agents if current buffer is a chat and command agents otherwise). The agent setting is persisted on disk across Neovim instances.

## Other commands

#### `:GpStop` <!-- {doc=:GpStop}  -->

Stops all currently running responses and jobs.

#### `:GpInspectPlugin` <!-- {doc=:GpInspectPlugin}  -->

Inspects the GPT prompt plugin object in a new scratch buffer.

## GpDone autocommand

Commands like `GpRewrite`, `GpAppend` etc. run asynchronously and generate event `GpDone`, so you can define autocmd (like auto formating) to run when gp finishes:

```lua
    vim.api.nvim_create_autocmd({ "User" }, {
        pattern = {"GpDone"},
        callback = function(event)
            print("event fired:\n", vim.inspect(event))
            -- local b = event.buf
            -- DO something
        end,
    })
```

## Custom instructions

By calling `:GpContext` you can make `.gp.md` markdown file in a root of a repository. Commands such as `:GpRewrite`, `:GpAppend` etc. will respect instructions provided in this file (works better with gpt4, gpt 3.5 doesn't always listen to system commands). For example:

```md
Use ‎C++17.
Use Testify library when writing Go tests.
Use Early return/Guard Clauses pattern to avoid excessive nesting.
...
```

Here is [another example](https://github.com/tdub0/gp.nvim/blob/main/.gp.md).

## Scripting

`GpDone` event + `.gp.md` custom instructions provide a possibility to run gp.nvim using headless (neo)vim from terminal or shell script. So you can let gp run edits accross many files if you put it in a loop.

`test` file:

```
1
2
3
4
5
```

`.gp.md` file:

````
If user says hello, please respond with:

```
Ahoy there!
```
````

calling gp.nvim from terminal/script:

- register autocommand to save and quit nvim when Gp is done
- second jumps to occurrence of something I want to rewrite/append/prepend to (in this case number `3`)
- selecting the line
- calling gp.nvim acction

```
$ nvim --headless -c "autocmd User GpDone wq" -c "/3" -c "normal V" -c "GpAppend hello there"  test
```

resulting `test` file:

```
1
2
3
Ahoy there!
4
5
```

# Shortcuts

There are no default global shortcuts to mess with your own config. Bellow are examples for you to adjust or just use directly.

## Native

You can use the good old `vim.keymap.set` and paste the following after `require("gp").setup(conf)` call
(or anywhere you keep shortcuts if you want them at one place).

```lua
local function keymapOptions(desc)
    return {
        noremap = true,
        silent = true,
        nowait = true,
        desc = "GPT prompt " .. desc,
    }
end

-- Chat commands
vim.keymap.set({"n", "i"}, "<C-g>c", "<cmd>GpChatNew<cr>", keymapOptions("New Chat"))
vim.keymap.set({"n", "i"}, "<C-g>t", "<cmd>GpChatToggle<cr>", keymapOptions("Toggle Chat"))
vim.keymap.set({"n", "i"}, "<C-g>f", "<cmd>GpChatFinder<cr>", keymapOptions("Chat Finder"))

vim.keymap.set("v", "<C-g>c", ":<C-u>'<,'>GpChatNew<cr>", keymapOptions("Visual Chat New"))
vim.keymap.set("v", "<C-g>p", ":<C-u>'<,'>GpChatPaste<cr>", keymapOptions("Visual Chat Paste"))
vim.keymap.set("v", "<C-g>t", ":<C-u>'<,'>GpChatToggle<cr>", keymapOptions("Visual Toggle Chat"))

vim.keymap.set({ "n", "i" }, "<C-g><C-x>", "<cmd>GpChatNew split<cr>", keymapOptions("New Chat split"))
vim.keymap.set({ "n", "i" }, "<C-g><C-v>", "<cmd>GpChatNew vsplit<cr>", keymapOptions("New Chat vsplit"))
vim.keymap.set({ "n", "i" }, "<C-g><C-t>", "<cmd>GpChatNew tabnew<cr>", keymapOptions("New Chat tabnew"))

vim.keymap.set("v", "<C-g><C-x>", ":<C-u>'<,'>GpChatNew split<cr>", keymapOptions("Visual Chat New split"))
vim.keymap.set("v", "<C-g><C-v>", ":<C-u>'<,'>GpChatNew vsplit<cr>", keymapOptions("Visual Chat New vsplit"))
vim.keymap.set("v", "<C-g><C-t>", ":<C-u>'<,'>GpChatNew tabnew<cr>", keymapOptions("Visual Chat New tabnew"))

-- Prompt commands
vim.keymap.set({"n", "i"}, "<C-g>r", "<cmd>GpRewrite<cr>", keymapOptions("Inline Rewrite"))
vim.keymap.set({"n", "i"}, "<C-g>a", "<cmd>GpAppend<cr>", keymapOptions("Append (after)"))
vim.keymap.set({"n", "i"}, "<C-g>b", "<cmd>GpPrepend<cr>", keymapOptions("Prepend (before)"))

vim.keymap.set("v", "<C-g>r", ":<C-u>'<,'>GpRewrite<cr>", keymapOptions("Visual Rewrite"))
vim.keymap.set("v", "<C-g>a", ":<C-u>'<,'>GpAppend<cr>", keymapOptions("Visual Append (after)"))
vim.keymap.set("v", "<C-g>b", ":<C-u>'<,'>GpPrepend<cr>", keymapOptions("Visual Prepend (before)"))
vim.keymap.set("v", "<C-g>i", ":<C-u>'<,'>GpImplement<cr>", keymapOptions("Implement selection"))

vim.keymap.set({"n", "i"}, "<C-g>gp", "<cmd>GpPopup<cr>", keymapOptions("Popup"))
vim.keymap.set({"n", "i"}, "<C-g>ge", "<cmd>GpEnew<cr>", keymapOptions("GpEnew"))
vim.keymap.set({"n", "i"}, "<C-g>gn", "<cmd>GpNew<cr>", keymapOptions("GpNew"))
vim.keymap.set({"n", "i"}, "<C-g>gv", "<cmd>GpVnew<cr>", keymapOptions("GpVnew"))
vim.keymap.set({"n", "i"}, "<C-g>gt", "<cmd>GpTabnew<cr>", keymapOptions("GpTabnew"))

vim.keymap.set("v", "<C-g>gp", ":<C-u>'<,'>GpPopup<cr>", keymapOptions("Visual Popup"))
vim.keymap.set("v", "<C-g>ge", ":<C-u>'<,'>GpEnew<cr>", keymapOptions("Visual GpEnew"))
vim.keymap.set("v", "<C-g>gn", ":<C-u>'<,'>GpNew<cr>", keymapOptions("Visual GpNew"))
vim.keymap.set("v", "<C-g>gv", ":<C-u>'<,'>GpVnew<cr>", keymapOptions("Visual GpVnew"))
vim.keymap.set("v", "<C-g>gt", ":<C-u>'<,'>GpTabnew<cr>", keymapOptions("Visual GpTabnew"))

vim.keymap.set({"n", "i"}, "<C-g>x", "<cmd>GpContext<cr>", keymapOptions("Toggle Context"))
vim.keymap.set("v", "<C-g>x", ":<C-u>'<,'>GpContext<cr>", keymapOptions("Visual Toggle Context"))

vim.keymap.set({"n", "i", "v", "x"}, "<C-g>s", "<cmd>GpStop<cr>", keymapOptions("Stop"))
vim.keymap.set({"n", "i", "v", "x"}, "<C-g>n", "<cmd>GpNextAgent<cr>", keymapOptions("Next Agent"))
```

## Whichkey

Or go more fancy by using [which-key.nvim](https://github.com/folke/which-key.nvim) plugin:

```lua
-- VISUAL mode mappings
-- s, x, v modes are handled the same way by which_key
require("which-key").register({
    -- ...
    ["<C-g>"] = {
        c = { ":<C-u>'<,'>GpChatNew<cr>", "Visual Chat New" },
        p = { ":<C-u>'<,'>GpChatPaste<cr>", "Visual Chat Paste" },
        t = { ":<C-u>'<,'>GpChatToggle<cr>", "Visual Toggle Chat" },

        ["<C-x>"] = { ":<C-u>'<,'>GpChatNew split<cr>", "Visual Chat New split" },
        ["<C-v>"] = { ":<C-u>'<,'>GpChatNew vsplit<cr>", "Visual Chat New vsplit" },
        ["<C-t>"] = { ":<C-u>'<,'>GpChatNew tabnew<cr>", "Visual Chat New tabnew" },

        r = { ":<C-u>'<,'>GpRewrite<cr>", "Visual Rewrite" },
        a = { ":<C-u>'<,'>GpAppend<cr>", "Visual Append (after)" },
        b = { ":<C-u>'<,'>GpPrepend<cr>", "Visual Prepend (before)" },
        i = { ":<C-u>'<,'>GpImplement<cr>", "Implement selection" },

        g = {
            name = "generate into new ..",
            p = { ":<C-u>'<,'>GpPopup<cr>", "Visual Popup" },
            e = { ":<C-u>'<,'>GpEnew<cr>", "Visual GpEnew" },
            n = { ":<C-u>'<,'>GpNew<cr>", "Visual GpNew" },
            v = { ":<C-u>'<,'>GpVnew<cr>", "Visual GpVnew" },
            t = { ":<C-u>'<,'>GpTabnew<cr>", "Visual GpTabnew" },
        },

        n = { "<cmd>GpNextAgent<cr>", "Next Agent" },
        s = { "<cmd>GpStop<cr>", "GpStop" },
        x = { ":<C-u>'<,'>GpContext<cr>", "Visual GpContext" },
    },
    -- ...
}, {
    mode = "v", -- VISUAL mode
    prefix = "",
    buffer = nil,
    silent = true,
    noremap = true,
    nowait = true,
})

-- NORMAL mode mappings
require("which-key").register({
    -- ...
    ["<C-g>"] = {
        c = { "<cmd>GpChatNew<cr>", "New Chat" },
        t = { "<cmd>GpChatToggle<cr>", "Toggle Chat" },
        f = { "<cmd>GpChatFinder<cr>", "Chat Finder" },

        ["<C-x>"] = { "<cmd>GpChatNew split<cr>", "New Chat split" },
        ["<C-v>"] = { "<cmd>GpChatNew vsplit<cr>", "New Chat vsplit" },
        ["<C-t>"] = { "<cmd>GpChatNew tabnew<cr>", "New Chat tabnew" },

        r = { "<cmd>GpRewrite<cr>", "Inline Rewrite" },
        a = { "<cmd>GpAppend<cr>", "Append (after)" },
        b = { "<cmd>GpPrepend<cr>", "Prepend (before)" },

        g = {
            name = "generate into new ..",
            p = { "<cmd>GpPopup<cr>", "Popup" },
            e = { "<cmd>GpEnew<cr>", "GpEnew" },
            n = { "<cmd>GpNew<cr>", "GpNew" },
            v = { "<cmd>GpVnew<cr>", "GpVnew" },
            t = { "<cmd>GpTabnew<cr>", "GpTabnew" },
        },

        n = { "<cmd>GpNextAgent<cr>", "Next Agent" },
        s = { "<cmd>GpStop<cr>", "GpStop" },
        x = { "<cmd>GpContext<cr>", "Toggle GpContext" },
        },
    -- ...
}, {
    mode = "n", -- NORMAL mode
    prefix = "",
    buffer = nil,
    silent = true,
    noremap = true,
    nowait = true,
})

-- INSERT mode mappings
require("which-key").register({
    -- ...
    ["<C-g>"] = {
        c = { "<cmd>GpChatNew<cr>", "New Chat" },
        t = { "<cmd>GpChatToggle<cr>", "Toggle Chat" },
        f = { "<cmd>GpChatFinder<cr>", "Chat Finder" },

        ["<C-x>"] = { "<cmd>GpChatNew split<cr>", "New Chat split" },
        ["<C-v>"] = { "<cmd>GpChatNew vsplit<cr>", "New Chat vsplit" },
        ["<C-t>"] = { "<cmd>GpChatNew tabnew<cr>", "New Chat tabnew" },

        r = { "<cmd>GpRewrite<cr>", "Inline Rewrite" },
        a = { "<cmd>GpAppend<cr>", "Append (after)" },
        b = { "<cmd>GpPrepend<cr>", "Prepend (before)" },

        g = {
            name = "generate into new ..",
            p = { "<cmd>GpPopup<cr>", "Popup" },
            e = { "<cmd>GpEnew<cr>", "GpEnew" },
            n = { "<cmd>GpNew<cr>", "GpNew" },
            v = { "<cmd>GpVnew<cr>", "GpVnew" },
            t = { "<cmd>GpTabnew<cr>", "GpTabnew" },
        },

        x = { "<cmd>GpContext<cr>", "Toggle GpContext" },
        s = { "<cmd>GpStop<cr>", "GpStop" },
        n = { "<cmd>GpNextAgent<cr>", "Next Agent" },
    },
    -- ...
}, {
    mode = "i", -- INSERT mode
    prefix = "",
    buffer = nil,
    silent = true,
    noremap = true,
    nowait = true,
})
```

# Extend functionality

You can extend/override the plugin functionality with your own, by putting functions into `config.hooks`.
Hooks have access to everything (see `InspectPlugin` example in defaults) and are
automatically registered as commands (`GpInspectPlugin`).

Here are some more examples:

- `:GpUnitTests`

  ````lua
  -- example of adding command which writes unit tests for the selected code
  UnitTests = function(gp, params)
      local template = "I have the following code from {{filename}}:\n\n"
          .. "```{{filetype}}\n{{selection}}\n```\n\n"
          .. "Please respond by writing table driven unit tests for the code above."
      local agent = gp.get_command_agent()
      gp.Prompt(params, gp.Target.enew, nil, agent.model, template, agent.system_prompt)
  end,
  ````

- `:GpExplain`

  ````lua
  -- example of adding command which explains the selected code
  Explain = function(gp, params)
      local template = "I have the following code from {{filename}}:\n\n"
          .. "```{{filetype}}\n{{selection}}\n```\n\n"
          .. "Please respond by explaining the code above."
      local agent = gp.get_chat_agent()
      gp.Prompt(params, gp.Target.popup, nil, agent.model, template, agent.system_prompt)
  end,
  ````

- `:GpCodeReview`

  ````lua
  -- example of usig enew as a function specifying type for the new buffer
  CodeReview = function(gp, params)
      local template = "I have the following code from {{filename}}:\n\n"
          .. "```{{filetype}}\n{{selection}}\n```\n\n"
          .. "Please analyze for code smells and suggest improvements."
      local agent = gp.get_chat_agent()
      gp.Prompt(params, gp.Target.enew("markdown"), nil, agent.model, template, agent.system_prompt)
  end,
  ````

- `:GpTranslator`

  ```lua
  -- example of adding command which opens new chat dedicated for translation
  Translator = function(gp, params)
    local agent = gp.get_command_agent()
  local chat_system_prompt = "You are a Translator, please translate between English and Chinese."
  gp.cmd.ChatNew(params, agent.model, chat_system_prompt)
  end,
  ```

- `:GpBufferChatNew`

  ```lua
  -- example of making :%GpChatNew a dedicated command which
  -- opens new chat with the entire current buffer as a context
  BufferChatNew = function(gp, _)
      -- call GpChatNew command in range mode on whole buffer
      vim.api.nvim_command("%" .. gp.config.cmd_prefix .. "ChatNew")
  end,
  ```

The raw plugin text editing method `Prompt` has seven aprameters:

- `params` is a [table passed to neovim user commands](https://neovim.io/doc/user/lua-guide.html#lua-guide-commands-create), `Prompt` currently uses:

  - `range, line1, line2` to work with [ranges](https://neovim.io/doc/user/usr_10.html#10.3)
  - `args` so instructions can be passed directly after command (`:GpRewrite something something`)

  ```lua
  params = {
        args = "",
        bang = false,
        count = -1,
        fargs = {},
        line1 = 1352,
        line2 = 1352,
        mods = "",
        name = "GpChatNew",
        range = 0,
        reg = "",
        smods = {
              browse = false,
              confirm = false,
              emsg_silent = false,
              hide = false,
              horizontal = false,
              keepalt = false,
              keepjumps = false,
              keepmarks = false,
              keeppatterns = false,
              lockmarks = false,
              noautocmd = false,
              noswapfile = false,
              sandbox = false,
              silent = false,
              split = "",
              tab = -1,
              unsilent = false,
              verbose = -1,
              vertical = false
        }
  }
  ```

- `target` specifying where to direct GPT response

  - enew/new/vnew/tabnew can be used as a function so you can pass in a filetype
    for the new buffer (`enew/enew()/enew("markdown")/..`)

  ```lua
  M.Target = {
      rewrite = 0, -- for replacing the selection, range or the current line
      append = 1, -- for appending after the selection, range or the current line
      prepend = 2, -- for prepending before the selection, range or the current line
      popup = 3, -- for writing into the popup window

      -- for writing into a new buffer
      ---@param filetype nil | string # nil = same as the original buffer
      ---@return table # a table with type=4 and filetype=filetype
      enew = function(filetype)
          return { type = 4, filetype = filetype }
      end,

      --- for creating a new horizontal split
      ---@param filetype nil | string # nil = same as the original buffer
      ---@return table # a table with type=5 and filetype=filetype
      new = function(filetype)
          return { type = 5, filetype = filetype }
      end,

      --- for creating a new vertical split
      ---@param filetype nil | string # nil = same as the original buffer
      ---@return table # a table with type=6 and filetype=filetype
      vnew = function(filetype)
          return { type = 6, filetype = filetype }
      end,

      --- for creating a new tab
      ---@param filetype nil | string # nil = same as the original buffer
      ---@return table # a table with type=7 and filetype=filetype
      tabnew = function(filetype)
          return { type = 7, filetype = filetype }
      end,
  }
  ```

- `prompt`
  - string used similarly as bash/zsh prompt in terminal, when plugin asks for user command to gpt.
  - if `nil`, user is not asked to provide input (for specific predefined commands - document this, explain that, write tests ..)
  - simple `🤖 ~ ` might be used or you could use different msg to convey info about the method which is called  
    (`🤖 rewrite ~`, `🤖 popup ~`, `🤖 enew ~`, `🤖 inline ~`, etc.)
- `model`
  - see [gpt model overview](https://platform.openai.com/docs/models/overview)
- `template`

  - template of the user message send to gpt
  - string can include variables bellow:

    | name            | Description                       |
    | --------------- | --------------------------------- |
    | `{{filetype}}`  | filetype of the current buffer    |
    | `{{selection}}` | last or currently selected text   |
    | `{{command}}`   | instructions provided by the user |

- `system_template`
  - See [gpt api intro](https://platform.openai.com/docs/guides/chat/introduction)
