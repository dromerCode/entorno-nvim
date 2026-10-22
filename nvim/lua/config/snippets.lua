local M = {}

function M.expand()
  local snippets = require("mini.snippets")
  local ft = vim.bo.filetype
  if ft == "html" or ft == "css" then
    local col = vim.api.nvim_win_get_cursor(0)[2]
    local token = vim.api.nvim_get_current_line():sub(1, col):match("%S+$")
    -- Las plantillas propias exactas tienen prioridad (!, main, centrar...).
    -- El resto se interpreta como Emmet, sin coincidencias difusas parciales.
    local exact = token == nil
    for _, item in ipairs(snippets.expand({ match = false, insert = false }) or {}) do
      if item.prefix == token then exact = true; break end
    end
    if not exact then
      require("lazy").load({ plugins = { "emmet-vim" } })
      local keys = "<C-r>=emmet#util#closePopup()<CR><C-r>=emmet#expandAbbr(0, '')<CR>"
      vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes(keys, true, false, true), "in", false)
      return
    end
  end
  snippets.expand()
end

function M.setup()
  local snippets = require("mini.snippets")
  snippets.setup({
    mappings = { expand = "" },
    snippets = {
      snippets.gen_loader.from_lang({
        lang_patterns = {
          -- sh y bash comparten plantillas; Compose tiene las suyas.
          sh = { "**/bash.json" },
          bash = { "**/bash.json" },
          ["yaml.docker-compose"] = { "**/docker-compose.json" },
        },
      }),
    },
    expand = {
      insert = function(snippet)
        local ft = vim.bo.filetype
        if snippet.prefix == "docfn" and (ft == "typescript" or ft == "typescriptreact"
          or ft == "javascript" or ft == "javascriptreact") then
          require("config.jsdoc").generate(snippet)
          return
        end
        snippets.default_insert(snippet, { empty_tabstop = "", empty_tabstop_final = "" })
      end,
      select = function(items, insert)
        if #items == 0 then return end
        if #items == 1 then
          insert(items[1])
          return
        end
        vim.ui.select(items, {
          prompt = "Snippets > ",
          format_item = function(item)
            return item.prefix .. " | " .. (item.desc or item.description or "")
          end,
        }, vim.schedule_wrap(function(item)
          if item then insert(item) end
        end))
      end,
    },
  })

  vim.keymap.set("i", "<C-j>", M.expand, {
    desc = "Expandir plantilla o Emmet (HTML/CSS)", silent = true,
  })

  vim.api.nvim_create_user_command("DocumentarFuncion", function()
    require("config.jsdoc").generate()
  end, { desc = "Generar JSDoc con los parametros de la funcion" })
  vim.keymap.set("n", "<leader>lj", "<cmd>DocumentarFuncion<cr>", {
    desc = "Documentar funcion (JSDoc)", silent = true,
  })

  local group = vim.api.nvim_create_augroup("entorno_nvim_snippets", { clear = true })
  vim.api.nvim_create_autocmd("InsertLeave", {
    group = group,
    desc = "Terminar las plantillas al salir de insertar",
    callback = function()
      while snippets.session.get() do snippets.session.stop() end
    end,
  })
end

return M
