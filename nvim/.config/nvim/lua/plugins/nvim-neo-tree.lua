return {
  "neo-tree.nvim",
  lazy = false,
  opts = {
    window = {
      mappings = {
        -- unbind 's' as its used for movement
        ["<bs>"] = false,
        ["u"] = "navigate_up",
        -- ["/"] = "filter_on_submit",
        -- ["T"] = "clear_filter",
      },
    },
    filesystem = {
      filtered_items = {
        -- show hidden files and filtered items
        visible = true,
      },
    },
    event_handlers = {
      {
        event = "neo_tree_buffer_enter",
        handler = function()
          vim.cmd [[
                setlocal number
                setlocal relativenumber
              ]]
        end,
      },
    },
  },
}
