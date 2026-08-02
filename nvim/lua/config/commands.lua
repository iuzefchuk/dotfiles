return {
  Close = {
    desc = "close",
    run = function()
      Snacks.bufdelete.all()
    end,
  },
  Docker = {
    desc = "docker",
    run = function()
      Snacks.terminal("lazydocker")
    end,
  },
  Explore = {
    desc = "explorer",
    run = function()
      Snacks.explorer({ cwd = LazyVim.root() })
    end,
  },
  Git = { desc = "git", from = " gg" },
  Grep = {
    desc = "search",
    run = function()
      Snacks.picker.grep({ cwd = LazyVim.root() })
    end,
  },
  GrugFar = {
    desc = "replace",
    run = function()
      local ext = vim.bo.buftype == "" and vim.fn.expand("%:e")
      require("grug-far").open({
        transient = true,
        prefills = { filesFilter = ext and ext ~= "" and "*." .. ext or nil },
      })
    end,
  },
}
