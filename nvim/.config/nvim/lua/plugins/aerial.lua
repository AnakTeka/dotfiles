-- Override AstroNvim's pinned aerial.nvim.
-- AstroNvim v5 pins aerial to v2.7.0, which calls the treesitter `node:start()`
-- method that was removed in Neovim 0.12. On 0.12 that errors with
-- "attempt to call method 'start' (a nil value)" on every buffer attach.
-- v4.0.0 switched to `node:range()` and supports Neovim 0.12.
return {
  "stevearc/aerial.nvim",
  version = false,
  pin = false,
  commit = "ac583c330f95bc9731c7cdf71123c0f76d1b0385", -- v4.0.0
}
