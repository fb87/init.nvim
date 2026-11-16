-- vim: tabstop=2 autoindent tabstop=2 shiftwidth=2 expandtab colorcolumn=80
vim.g.mapleader = " "

function _install_packages()
  local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
  if not vim.loop.fs_stat(lazypath) then
    vim.fn.system({
      "git",
      "clone",
      "--filter=blob:none",
      "https://github.com/folke/lazy.nvim.git",
      "--branch=stable", -- latest stable release
      lazypath,
    })
  end
  vim.opt.rtp:prepend(lazypath)

  local opts = { lockfile = vim.fn.stdpath("data") .. "/lazy-lock.json", }
  local plugins = {
    {
      "ggml-org/llama.vim"
    },
    { 
      "rose-pine/neovim", name = "rose-pine",
      config = function()
        require("rose-pine").setup({
          variant = "main",
          styles = {
            bold = true,
            italic = false,
            transparency = false,
          }
        })
      end
    },
    {
      'akinsho/toggleterm.nvim', version = "*", config = true,
      keys = {
        {  "<leader>jk", "<cmd> ToggleTerm size=45 direction=horizontal<cr>" },
        { "1<leader>jk", "<cmd>1ToggleTerm size=45 direction=horizontal<cr>" },
        { "2<leader>jk", "<cmd>2ToggleTerm size=45 direction=horizontal<cr>" },
        -- terminal 9 belongs to agent.nvim (below): the coding agent
        { "9<leader>jk", "<cmd>9ToggleTerm size=45 direction=horizontal<cr>" },
      }
    },
    {
      'nvim-telescope/telescope.nvim',
      dependencies = { 'nvim-lua/plenary.nvim' },
      keys = {
        { "<leader>pf", "<cmd>Telescope find_files<cr>" },
        { "<leader>pg", "<cmd>Telescope git_files<cr>" },
        { "<leader>ps", "<cmd>Telescope grep_string<cr>" },

        -- map pb for telescope on buffer list
        { "<leader>pb", "<cmd>Telescope buffers<cr>" },
      }
    },
    {
      'theprimeagen/harpoon',
      keys = {
        { "<leader>a", "<cmd>:lua require('harpoon.mark').add_file()<cr>" },
        { "<leader>j", "<cmd>:lua require('harpoon.ui').nav_next()<cr>" },
        { "<leader>k", "<cmd>:lua require('harpoon.ui').nav_prev()<cr>" },
        {
          "<leader>m",
          "<cmd>:lua require('harpoon.ui').toggle_quick_menu()<cr>",
        },
      }
    },

    { 'vimwiki/vimwiki' },
    { 'stevearc/oil.nvim', dependencies = {
        { "echasnovski/mini.icons", opts = {} }
      },
      config = function() require("oil").setup({
        columns = {
          "icon",
          "permissions",
          "size",
          "mtime",
        },

        float = {
          -- Padding around the floating window
          padding = 2,
          max_width = 0,
          max_height = 0,
          win_options = {
            winblend = 0,
          },
          get_win_title = nil,
          preview_split = "right",
          override = function(conf)
            return conf
          end,
        },

        -- Configuration for the file preview window
        preview_win = {
          update_on_cursor_moved = true,
          preview_method = "fast_scratch",
          disable_preview = function(filename)
            return false
          end,
          win_options = {},
        },
      }
    ) end },
    {
      -- zilch.nvim ships with the zilch agent; the Nix configuration links it
      -- into the site packpath and this entry loads it through lazy.
      dir = vim.fn.stdpath("data") .. "/site/pack/zilch/start/zilch",
      cond = function()
        local dir = vim.fn.stdpath("data") .. "/site/pack/zilch/start/zilch"
        return vim.loop.fs_stat(dir) ~= nil
      end,
      config = function()
        require("zilch").setup({
          keymaps = {
            send = "<leader>zs",
            code = "<leader>zc",
            spec = "<leader>zp",
          },
        })
      end,
    },
  }

  require("lazy").setup(plugins, opts)
end

-- agent.nvim, bundled: drives agent.sh through ToggleTerm terminal 9.
-- Registered as a module so `require("agent")` works with `nvim -u init.lua`.
-- It types one-line prompts into the REPL ("<file> lines <a>-<b>: <text>");
-- the agent reads the code itself with its read tool.
package.preload["agent"] = function()
  local M = {}

  M.config = {
    -- command (list) that starts the REPL; extra flags go here ("--plan")
    cmd = { "agent.sh" },
    -- start with -c; on "no saved session" restart without it
    continue_session = true,
    -- ToggleTerm id of the agent terminal (9<leader>jk toggles it)
    count = 9,
    -- vertical | horizontal | float | tab
    direction = "horizontal",
    -- columns (vertical) or lines (horizontal); ignored by float/tab
    size = 45,
    -- e.g. { send = "<leader>as", toggle = "<leader>at" }
    keymaps = {},
  }

  local term = nil -- the single ToggleTerm terminal running agent.sh

  local function notify(msg, level)
    vim.notify("agent: " .. msg, level or vim.log.levels.INFO)
  end

  local function alive()
    return term and term.job_id
      and vim.fn.jobwait({ term.job_id }, 0)[1] == -1
  end

  local function root()
    local file = vim.api.nvim_buf_get_name(0)
    local from = file ~= "" and vim.fs.dirname(file) or vim.uv.cwd()
    local git = vim.fs.find(".git", { path = from, upward = true })[1]
    return git and vim.fs.dirname(git) or vim.uv.cwd()
  end

  local function shell_cmd(with_c)
    -- The plugin owns -c: drop one given in cmd so the fallback can
    -- really start without it.
    local args = vim.tbl_filter(function(a)
      return a ~= "-c"
    end, M.config.cmd)
    if with_c then table.insert(args, 2, "-c") end
    return table.concat(vim.tbl_map(vim.fn.shellescape, args), " ")
  end

  local function buf_lines(bufnr)
    if bufnr and vim.api.nvim_buf_is_valid(bufnr) then
      return vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)
    end
    return {}
  end

  -- Create the terminal (not opened yet; ToggleTerm spawns the job on
  -- first open).
  local function create(with_c)
    local Terminal = require("toggleterm.terminal").Terminal
    local t
    t = Terminal:new({
      cmd = shell_cmd(with_c),
      count = M.config.count,
      dir = "git_dir", -- git root of the current buffer, at job start
      direction = M.config.direction,
      close_on_exit = false, -- keep the output if the agent dies
      on_open = function(self)
        -- the agent prompt must always be able to hide itself
        vim.keymap.set("t", "<leader>jk", function()
          self:close()
        end, { buffer = self.bufnr, desc = "agent: hide" })
      end,
      on_exit = function(_, _, code)
        vim.schedule(function()
          local lines = buf_lines(t.bufnr)
          local text = table.concat(lines, "\n"):lower()
          if term == t then term = nil end
          if code == 0 then return end
          if with_c and text:find("no saved session", 1, true) then
            -- fresh workspace: nothing to continue, start a new session
            pcall(function() t:shutdown() end)
            term = create(false)
            term:open(M.config.size)
            return
          end
          local tail = {}
          for i = #lines, 1, -1 do
            if lines[i]:match("%S") then table.insert(tail, 1, lines[i]) end
            if #tail >= 5 then break end
          end
          local out = table.concat(tail, "\n")
          notify(
            ("exited with status %d\n%s"):format(code, out),
            vim.log.levels.ERROR
          )
        end)
      end,
    })
    return t
  end

  -- Show the agent terminal, starting agent.sh if it is not running.
  function M.open()
    if not pcall(require, "toggleterm") then
      notify("toggleterm.nvim is required", vim.log.levels.ERROR)
      return false
    end
    if vim.fn.executable(M.config.cmd[1]) ~= 1 then
      notify(
        M.config.cmd[1] .. " not found; set cmd in setup()",
        vim.log.levels.ERROR
      )
      return false
    end
    if not term then
      term = create(M.config.continue_session)
    end
    if not term:is_open() then
      term:open(M.config.size)
    end
    return true
  end

  -- Move into the agent terminal in insert mode.
  local function focus_term()
    local w = term and term.bufnr and vim.fn.bufwinid(term.bufnr) or -1
    if w > 0 then
      vim.api.nvim_set_current_win(w)
      vim.cmd("startinsert")
    end
  end

  function M.toggle()
    if alive() and term:is_open() then
      term:close()
    elseif M.open() then
      focus_term() -- so you can type to the agent right away
    end
  end

  -- The terminal's last non-empty line ("" when there is none).
  local function last_line()
    local lines = buf_lines(term and term.bufnr)
    for i = #lines, 1, -1 do
      if lines[i]:match("%S") then return lines[i] end
    end
    return ""
  end

  -- True when that line is agent.sh's input prompt
  -- ("build ~/dir (branch) abcd1234$ " or "plan ...") with nothing typed
  -- after it.
  local function prompt_visible()
    local l = last_line()
    return l:match("%$%s*$") ~= nil
      and (l:match("^%s*build%s") ~= nil or l:match("^%s*plan%s") ~= nil)
  end

  local function warn(msg)
    -- one echo only (kept in :messages); a second notify would add a
    -- hit-enter prompt
    vim.api.nvim_echo({ { "agent: " .. msg, "WarningMsg" } }, true, {})
  end

  -- Type a line into the REPL and press Enter. Without `force`, only when
  -- the agent's prompt is showing (a freshly started agent gets a few
  -- seconds to reach it); otherwise warn and send nothing, because text
  -- typed mid-turn is queued, and at an approval question it would answer
  -- it.
  function M.say(text, force)
    text = text:gsub("[\r\n]+", " ")
    -- Focus the terminal after vim.ui.input has closed: it restores the
    -- previous window on close, which would undo an immediate switch.
    local function into_terminal()
      vim.defer_fn(focus_term, 50)
    end
    local fresh = not alive()
    if not M.open() then return end
    -- A freshly opened terminal spawns its job asynchronously.
    vim.wait(2000, function() return term.job_id ~= nil end, 20)
    if not term.job_id then
      into_terminal()
      return notify("agent did not start", vim.log.levels.ERROR)
    end
    local wait = fresh and 8000 or 300
    if not force and not vim.wait(wait, prompt_visible, 100) then
      into_terminal() -- show what the agent is waiting on
      return warn(
        ("agent busy? prompt not showing (saw %q); nothing sent, "
          .. ":AgentSend! forces"):format(last_line():sub(1, 40))
      )
    end
    vim.api.nvim_chan_send(term.job_id, text .. "\r")
    into_terminal()
  end

  -- opts: { line1, line2, comment, force }. Without lines: just the
  -- comment (or a slash command).
  function M.send(opts)
    opts = opts or {}
    local file = vim.api.nvim_buf_get_name(0)
    local function go(comment)
      if not comment or comment == "" then
        return notify("cancelled", vim.log.levels.WARN)
      end
      local text = comment
      if opts.line1 and file ~= "" then
        -- the agent reads the file on disk
        if vim.bo.modified then vim.cmd("silent update") end
        local r = root()
        local rel = file
        if file:sub(1, #r + 1) == r .. "/" then rel = file:sub(#r + 2) end
        local range = tostring(opts.line1)
        if opts.line1 ~= opts.line2 then
          range = opts.line1 .. "-" .. opts.line2
        end
        text = ("%s lines %s: %s"):format(rel, range, comment)
      end
      M.say(text, opts.force)
    end
    if opts.comment and opts.comment ~= "" then
      go(opts.comment)
    else
      vim.ui.input({ prompt = "agent ← " }, go)
    end
  end

  function M.define_commands()
    if vim.g.loaded_agent_nvim then return end
    vim.g.loaded_agent_nvim = true
    local cmd = vim.api.nvim_create_user_command
    cmd("AgentSend", function(o)
      M.send({
        line1 = o.line1,
        line2 = o.line2,
        comment = o.args,
        force = o.bang,
      })
    end, {
      range = true,
      nargs = "*",
      bang = true,
      desc = "agent: send line/selection + comment (! = even if busy)",
    })
    cmd("AgentAsk", function(o)
      M.send({ comment = o.args, force = o.bang })
    end, {
      nargs = "*",
      bang = true,
      desc = "agent: send a prompt or /command (! = even if busy)",
    })
    cmd("AgentToggle", function()
      M.toggle()
    end, { desc = "agent: show/hide the terminal" })
  end

  function M.setup(opts)
    M.config = vim.tbl_deep_extend("force", M.config, opts or {})
    M.define_commands()
    -- Register the terminal now (no job yet) so 9<leader>jk starts the
    -- agent, not a plain shell.
    if pcall(require, "toggleterm")
      and vim.fn.executable(M.config.cmd[1]) == 1 then
      term = create(M.config.continue_session)
    end
    local km = M.config.keymaps
    if km.send then
      vim.keymap.set({ "n", "x" }, km.send, ":AgentSend<CR>", {
        silent = true,
        desc = "agent: send line/selection",
      })
    end
    if km.toggle then
      vim.keymap.set("n", km.toggle, M.toggle, {
        desc = "agent: toggle terminal",
      })
    end
  end

  return M
end

function _setup_agent()
  local agent = require("agent")
  agent.setup({ count = 9, size = 45, direction = "horizontal" })

  -- 9<leader>jk also toggles the agent terminal (see toggleterm keys)
  -- NOTE: <leader>a is harpoon's add_file; it still fires after timeoutlen
  local keys = vim.keymap
  keys.set("n", "<leader>aa", "<cmd>AgentAsk<cr>", { desc = "agent: ask" })
  keys.set({ "n", "x" }, "<leader>as", ":AgentSend<cr>", {
    silent = true,
    desc = "agent: send line/selection",
  })
  keys.set("n", "<leader>at", "<cmd>AgentToggle<cr>", {
    desc = "agent: toggle terminal",
  })
end

function _setup_key_binding()
  local keys = vim.keymap

  -- toggle the terminal we are in (1, 2, 9 = agent), not just the default one
  keys.set("t", "<leader>jk", function()
    vim.cmd((vim.b.toggle_number or "") .. "ToggleTerm")
  end)
  keys.set("t", "jk", [[<C-\><C-n>]])

  keys.set("n", "<leader>c", vim.cmd.bd)
  keys.set("n", "<leader>e", "<cmd>lua require('oil').toggle_float()<CR>")
  keys.set("n", "<leader><leader>", function()
    vim.cmd("so")
  end)
end

function _setup_vim_options()
  local opts = vim.opt

  vim.cmd [[colorscheme rose-pine-main]]

  opts.rnu = true
  -- reduce timeout between leader key to action
  opts.timeoutlen = 500 -- or 500 (Default: 1000)
end

function _setup_autocmd()
  vim.api.nvim_create_autocmd("TermOpen", {
    callback = function()
      local function open_from_terminal()
        local word = vim.fn.expand("<cWORD>")
        if word == "" then return end

        -- extract file, line, col (supports file:line:col)
        local file, line, col = word:match("([^:]+):(%d+):?(%d*)")
        if not file then file = word end

        local fullpath = vim.fn.fnamemodify(file, ":p")
        local is_file = vim.fn.filereadable(fullpath) == 1
        local is_dir  = vim.fn.isdirectory(fullpath) == 1

        if not is_file and not is_dir then
          vim.notify("Not a file/folder: " .. fullpath, vim.log.levels.WARN)
          return
        end

        -- normalize path (important for logs outside cwd)
        file = vim.fn.fnamemodify(file, ":p")

        -- switch to previous window (exit floating terminal)
        -- which terminal we are in (the agent is 9)
        local term_id = vim.b.toggle_number
        vim.cmd("wincmd p")
        vim.cmd((term_id or "") .. "ToggleTerm")

        if is_dir then
          require("oil").open_float(fullpath)
          return
        end

        if line then
          vim.cmd("edit +" .. line .. " " .. file)
          if col and col ~= "" then
            vim.cmd("normal! " .. col .. "|")
          end
        else
          vim.cmd("edit " .. file)
        end
      end

      vim.keymap.set("n", "gf", open_from_terminal, { buffer = true })
      vim.keymap.set("n", "<CR>", open_from_terminal, { buffer = true })
    end,
  })
end

function main()
  _install_packages()
  _setup_vim_options()
  _setup_key_binding()
  _setup_agent()
  _setup_autocmd()
end

-- run everything
main()
