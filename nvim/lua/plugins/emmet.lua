return {
  {
    "mattn/emmet-vim",
    commit = "92ef2f74f4093edc99db5e9e4cf7e40116a85bd6",
    ft = { "html", "css" },
    init = function()
      -- Ctrl+j se comparte con mini.snippets; no instalar otros atajos.
      vim.g.user_emmet_install_global = 0
      vim.g.user_emmet_install_command = 0
    end,
  },
}
