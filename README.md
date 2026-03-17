# MyNvimConfig

Personal Neovim configuration based on [kickstart.nvim](https://github.com/nvim-lua/kickstart.nvim), customized for Unity game development (C# and shaders) and general-purpose editing. Uses Nerd Fonts, the gruvbox-material colorscheme, and coq_nvim for autocompletion.

The leader key is `<Space>`.


## Directory Structure

```
~/.config/nvim/
  init.lua                          -- Main config: options, keymaps, plugin manager, core plugins
  after/
    lsp/
      roslyn.lua                    -- Roslyn LSP settings (completion, inlay hints, analysis scope)
  lua/
    custom/
      plugins/
        bufferline.lua              -- Tab bar display (akinsho/bufferline.nvim)
        coq.lua                     -- Completion engine (ms-jpq/coq_nvim), disables nvim-cmp
        dashboard.lua               -- Start screen (nvimdev/dashboard-nvim)
        diagflow.lua                -- Inline diagnostics (dgagn/diagflow.nvim)
        fidget.lua                  -- LSP progress notifications + Roslyn progress bridge
        neo-tree.lua                -- File browser sidebar (nvim-neo-tree/neo-tree.nvim)
        theme.lua                   -- Gruvbox Material colorscheme
        unity-csharp.lua            -- C# / Roslyn LSP / Mason custom registry
        unity-shaders.lua           -- Shader filetype detection, treesitter grammars, syntax
    kickstart/
      plugins/                      -- Stock kickstart optional plugins (not currently loaded)
```


## Installed Plugins

### Core (from kickstart)

| Plugin | Purpose |
|---|---|
| `folke/lazy.nvim` | Plugin manager |
| `tpope/vim-sleuth` | Auto-detect tabstop and shiftwidth |
| `lewis6991/gitsigns.nvim` | Git change signs in the gutter (+, ~, _) |
| `folke/which-key.nvim` | Popup showing pending keybinds (delay set to 0) |
| `nvim-telescope/telescope.nvim` | Fuzzy finder for files, grep, LSP symbols, buffers, help, etc. Tracks master branch (not 0.1.x) to stay compatible with Neovim 0.11+ |
| `neovim/nvim-lspconfig` | LSP client configuration |
| `williamboman/mason.nvim` | LSP/tool installer |
| `williamboman/mason-lspconfig.nvim` | Bridges Mason and lspconfig |
| `WhoIsSethDaniel/mason-tool-installer.nvim` | Ensures specified tools are installed |
| `stevearc/conform.nvim` | Autoformatting (format on save, `<leader>f` to format manually) |
| `folke/lazydev.nvim` | Lua LSP config for editing Neovim config files |
| `folke/todo-comments.nvim` | Highlights TODO, FIXME, HACK, WARN, NOTE, TEST in comments |
| `echasnovski/mini.nvim` | mini.ai (better text objects), mini.surround, mini.statusline |
| `nvim-treesitter/nvim-treesitter` | Syntax highlighting and code parsing |

### Custom Additions

| Plugin | Purpose |
|---|---|
| `ms-jpq/coq_nvim` | Completion engine (replaces nvim-cmp). Has ghost text, snippets via coq.artifacts, math evaluation via coq.thirdparty. Tuned timeouts for Roslyn. |
| `sainnhe/gruvbox-material` | Colorscheme. Hard background, material foreground, italic + bold enabled. |
| `akinsho/bufferline.nvim` | Visual tab bar at the top, configured in tabs mode (not buffers). |
| `nvimdev/dashboard-nvim` | Start screen with "HasteVim" ASCII art and shortcut hints. |
| `dgagn/diagflow.nvim` | Shows diagnostics inline as virtual text near the cursor rather than at end of line. |
| `j-hui/fidget.nvim` | LSP progress spinner in the bottom-right. Custom integration bridges Roslyn-specific events (solution loading, NuGet restore progress) into fidget's progress API. |
| `nvim-neo-tree/neo-tree.nvim` | File tree sidebar. Toggle with `\`. |
| `seblyng/roslyn.nvim` | Manages the Roslyn C# language server. Loads on `.cs` files. Uses broad_search to find `.sln` files up the directory tree. |
| `kalvinpearce/ShaderHighlight` | Vim regex syntax for ShaderLab, HLSL, GLSL, Cg files. Needed because no treesitter parser exists for ShaderLab. |


## LSP Servers

Servers are installed and managed through Mason. The Mason config includes a custom registry (`Crashdummyy/mason-registry`) to provide the Roslyn LSP binary.

| Server | Language(s) | Notes |
|---|---|---|
| `lua_ls` | Lua | Default from kickstart, for editing nvim config |
| `glsl_analyzer` | GLSL | For shader development |
| `roslyn` | C# | Managed by roslyn.nvim, not directly in the Mason servers table. Loads when a `.cs` file is opened. Settings are in `after/lsp/roslyn.lua`. |

### Roslyn LSP Settings (after/lsp/roslyn.lua)

The Roslyn config enables completion from unimported namespaces (helpful for Unity APIs like `UnityEngine.UI`), inlay hints for implicit types and lambda parameters, references code lens, and background analysis scoped to open files (change to `fullSolution` for project-wide diagnostics at the cost of higher resource usage).

### Known Roslyn Quirk

Roslyn can take 15-30+ seconds to fully index a Unity project after attaching. LSP features like go-to-definition and find-references may not work until indexing finishes, even after fidget reports that Roslyn has attached. If things are not responding, give it more time. Ensure Unity has been opened at least once so the `.sln` and `.csproj` files exist and are up to date.


## Completion Engine: coq_nvim

This config uses coq_nvim instead of nvim-cmp. The `coq.lua` custom plugin explicitly disables the entire nvim-cmp ecosystem (nvim-cmp, cmp-nvim-lsp, cmp-path, cmp_luasnip, LuaSnip) and loads coq_nvim with `auto_start = 'shut-up'`. The Mason lspconfig handler wraps each server with `coq.lsp_ensure_capabilities()` so all LSP servers feed into coq.

coq provides completions from LSP, treesitter, buffer words, file paths, and its built-in snippet library (9000+ snippets including C#). Ghost text previews are enabled.

### coq Default Keybinds (in insert mode)

| Key | Action |
|---|---|
| `<C-Space>` | Manual trigger completion |
| `<C-n>` / `<C-p>` | Navigate completion menu |
| `<C-e>` | Dismiss completion |
| `<leader>j` | Evaluate snippets |


## Unity Shader Setup

Unity shader files use two languages: ShaderLab (the outer DSL for Shader/SubShader/Pass blocks) and HLSL (the actual shader programs inside CGPROGRAM/ENDCG blocks).

Filetype detection is configured in `unity-shaders.lua`:
- `.shader` files are mapped to `shaderlab` filetype (vim regex syntax from ShaderHighlight, since no treesitter parser exists)
- `.cginc`, `.hlsli`, `.compute`, `.cg` files are mapped to `hlsl` (treesitter highlighting)
- `.glsl`, `.vert`, `.frag`, `.geom`, `.tesc`, `.tese`, `.comp` files are mapped to `glsl` (treesitter highlighting)

All shader files get 4-space indentation and `// %s` comment strings set automatically.


## Keybindings Reference

### General / Custom

These are mappings added or changed from the kickstart defaults. The leader key is `<Space>`.

| Shortcut | Mode | Action |
|---|---|---|
| `jj` | Insert, Visual, Command | Escape (exit to Normal mode) |
| `<leader>ww` | Normal | Save buffer (`:w`) |
| `<leader>wq` | Normal | Save and quit (`:wq`) |
| `<leader>tn` | Normal | Open new tab |
| `<leader>tl` | Normal | Next tab |
| `<leader>th` | Normal | Previous tab |
| `<leader>tc` | Normal | Save and close current tab |
| `<leader>t0` | Normal | Go to first tab |
| `<leader>t$` | Normal | Go to last tab |
| `<leader>rv` | Normal | Rename in file using vim substitute (all occurrences). Puts cursor in command line with the word under cursor pre-filled -- type the replacement name over `NEW_NAME`. |
| `<leader>rV` | Normal | Same as above but with confirmation for each occurrence (`/gc`) |
| `\` | Normal | Toggle Neo-tree file browser |
| `<leader>f` | Any | Format buffer with conform.nvim |

### Telescope (Fuzzy Finding)

| Shortcut | Action |
|---|---|
| `<leader>sf` | Search files |
| `<leader>sg` | Search by grep (live grep across project) |
| `<leader>sw` | Search current word under cursor |
| `<leader>sh` | Search help tags |
| `<leader>sk` | Search keymaps |
| `<leader>ss` | Search Telescope pickers (meta-search) |
| `<leader>sd` | Search diagnostics |
| `<leader>sr` | Resume last Telescope search |
| `<leader>s.` | Search recent files |
| `<leader>s/` | Live grep in open files only |
| `<leader>sn` | Search Neovim config files |
| `<leader>/` | Fuzzy search in current buffer |
| `<leader><leader>` | Find existing buffers |

### LSP (active when a language server is attached)

| Shortcut | Action |
|---|---|
| `gd` | Go to definition (opens in new tab if in a different file, via `jump_type = 'tab drop'`) |
| `g0` | Find references (opens in new tab via `jump_type = 'tab drop'`) |
| `gI` | Go to implementation |
| `gD` | Go to declaration |
| `<leader>D` | Go to type definition |
| `<leader>ds` | Document symbols (fuzzy list of functions, variables, etc. in current file) |
| `<leader>ws` | Workspace symbols (same but across entire project) |
| `<leader>rn` | Rename symbol (LSP rename across files) |
| `<leader>ca` | Code action (quick fixes, refactors) |
| `<leader>lh` | Toggle LSP inlay hints |

### Window Navigation

| Shortcut | Action |
|---|---|
| `<C-h>` | Move focus to left window |
| `<C-l>` | Move focus to right window |
| `<C-j>` | Move focus to lower window |
| `<C-k>` | Move focus to upper window |

### Other Defaults Worth Remembering

| Shortcut | Action |
|---|---|
| `<Esc>` | Clear search highlights (in Normal mode) |
| `<Esc><Esc>` | Exit terminal mode |
| `<leader>q` | Open diagnostic quickfix list |

### mini.nvim Text Objects and Surround

| Example | Action |
|---|---|
| `va)` | Visually select around parentheses |
| `yinq` | Yank inside next quote |
| `ci'` | Change inside single quotes |
| `saiw)` | Surround add inner word with parentheses |
| `sd'` | Surround delete single quotes |
| `sr)'` | Surround replace `)` with `'` |


## which-key Groups

Pressing `<leader>` and waiting will show a popup with these groups:

| Prefix | Group |
|---|---|
| `<leader>c` | Code |
| `<leader>d` | Document |
| `<leader>l` | LSP |
| `<leader>r` | Rename |
| `<leader>s` | Search |
| `<leader>w` | Workspace / Write |
| `<leader>t` | Tabs |
| `<leader>h` | Git Hunk |


## Options and Behaviors

Notable vim options set in `init.lua`:
- Relative line numbers enabled
- Mouse enabled
- System clipboard synced (`unnamedplus`)
- Persistent undo history across sessions (`undofile`)
- Case-insensitive search unless capitals are used
- Splits open to the right and below
- Whitespace characters shown (tab, trailing space, nbsp)
- Live substitution preview in a split
- Cursor line highlighted
- Scroll offset of 10 lines
- Yank highlighting on copy
- Format on save enabled (disabled for C/C++)
- Unity nvim server socket (`/tmp/nvimsocket`) cleaned up on exit


## Useful Commands

| Command | Purpose |
|---|---|
| `:Lazy` | Open the plugin manager UI. Press `?` for help. |
| `:Lazy update` | Update all plugins |
| `:Lazy sync` | Sync plugin lockfile |
| `:Mason` | Open Mason UI to see/install LSP servers and tools |
| `:Telescope keymaps` | Browse all active keymaps (same as `<leader>sk`) |
| `:checkhealth` | Diagnose configuration issues |
| `:Tutor` | Built-in Neovim tutorial |
| `:ConformInfo` | See which formatters are active for the current file |
| `:TSUpdate` | Update treesitter grammars |


## Dependencies

- Neovim 0.11+ (stable or nightly)
- A [Nerd Font](https://www.nerdfonts.com/) installed and set in your terminal (`have_nerd_font = true`)
- `git`, `make`, `unzip`, a C compiler (`gcc`)
- [ripgrep](https://github.com/BurntSushi/ripgrep) (used by Telescope's live grep)
- A clipboard tool (`xclip`, `xsel`, `win32yank`, etc.)
- For Unity development: the Unity editor must have been opened at least once so it generates `.sln` and `.csproj` files for Roslyn to consume


## Repo

https://github.com/sbeitelmal/MyNvimConfig
