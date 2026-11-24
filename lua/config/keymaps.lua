local keymap = vim.keymap

-- ── Editing basics ──────────────────────────────────────────────
keymap.set("n", "x", '"_x', { desc = "Delete char (no yank)" })
keymap.set("n", "<C-a>", "gg<S-v>G", { desc = "Select all" })
keymap.set("n", "+", "<C-a>", { desc = "Increment number" })
keymap.set("n", "-", "<C-x>", { desc = "Decrement number" })
keymap.set("n", "<leader>o", "o<Esc>^Da", { silent = true, desc = "Blank line below" })
keymap.set("n", "<leader>O", "O<Esc>^Da", { silent = true, desc = "Blank line above" })
keymap.set("n", "J", "mzJ`z", { desc = "Join lines (keep cursor)" })
keymap.set("n", "n", "nzzzv", { desc = "Next match (centered)" })
keymap.set("n", "N", "Nzzzv", { desc = "Prev match (centered)" })
keymap.set("x", "<leader>p", '"_dP', { desc = "Paste over selection (keep register)" })

-- ── Yank helpers: <leader>y ─────────────────────────────────────
keymap.set("n", "<leader>ya", "<cmd>%yank +<CR>", { desc = "Yank whole file" })
keymap.set("n", "<leader>yp", function()
	local p = vim.fn.expand("%:.")
	vim.fn.setreg("+", p)
	vim.notify("Copied: " .. p)
end, { desc = "Yank relative path" })
keymap.set("n", "<leader>yP", function()
	local p = vim.fn.expand("%:p")
	vim.fn.setreg("+", p)
	vim.notify("Copied: " .. p)
end, { desc = "Yank absolute path" })

-- ── Run / dev tools: <leader>r ──────────────────────────────────
-- Web
keymap.set("n", "<leader>rd", function()
	Snacks.terminal("npm run dev", { cwd = vim.fn.getcwd() })
end, { desc = "Dev server (npm run dev)" })
keymap.set("n", "<leader>rb", function()
	vim.ui.open(vim.fn.expand("%:p"))
end, { desc = "Open file in browser" })
keymap.set("n", "<leader>rl", function()
	vim.ui.open("http://localhost:3000")
end, { desc = "Open localhost:3000" })
keymap.set("n", "<leader>rv", function()
	vim.ui.open("http://localhost:5173")
end, { desc = "Open localhost:5173 (Vite)" })

-- Python / ML
keymap.set("n", "<leader>rp", function()
	if vim.bo.filetype ~= "python" then
		return vim.notify("Not a Python file", vim.log.levels.WARN)
	end
	vim.cmd("write")
	Snacks.terminal(
		{ "bash", "-c", 'python "$1"; echo; read -rp "[finished - press Enter] "', "_", vim.fn.expand("%:p") },
		{ cwd = vim.fn.expand("%:p:h") }
	)
end, { desc = "Run this Python file" })
keymap.set("n", "<leader>rP", function()
	Snacks.terminal("python")
end, { desc = "Python REPL" })
keymap.set("n", "<leader>rc", "o# %%<Esc>", { desc = "Insert # %% cell marker" })

-- Both
keymap.set("n", "<leader>rD", function()
	local w = vim.fn.expand("<cword>")
	local fmt = vim.bo.filetype == "python" and 'print("%s:", %s)' or "console.log('%s:', %s)"
	local row = vim.api.nvim_win_get_cursor(0)[1]
	local indent = vim.fn.getline(row):match("^%s*")
	vim.api.nvim_buf_set_lines(0, row, row, false, { indent .. fmt:format(w, w) })
end, { desc = "Debug-print word under cursor" })
keymap.set("n", "<leader>rw", [[:%s/\<<C-r><C-w>\>/<C-r><C-w>/gI<Left><Left><Left>]], { desc = "Replace word in file" })
keymap.set("n", "<leader>rx", "<cmd>!chmod +x %<CR>", { silent = true, desc = "Make file executable" })

-- Name the groups in the Space menu
local ok, wk = pcall(require, "which-key")
if ok then
	wk.add({
		{ "<leader>r", group = "run / dev" },
		{ "<leader>y", group = "yank" },
	})
end

-- ── Delete word backward ────────────────────────────────────────
-- (the video remaps `dw`, which breaks normal "delete word forward")
keymap.set("n", "<leader>k", 'vb"_d', { desc = "Delete word backward (no yank)" })
keymap.set("i", "<M-BS>", "<C-w>", { desc = "Delete word backward" })
keymap.set("i", "<C-BS>", "<C-w>", { desc = "Delete word backward" })

-- ── Jumplist (go back / forward to where you were) ──────────────
keymap.set("n", "<A-o>", "<C-o>", { desc = "Jump back" })
keymap.set("n", "<A-i>", "<C-i>", { desc = "Jump forward" })

-- ── Diagnostics ─────────────────────────────────────────────────
-- Copy the error message(s) on the current line to the clipboard
keymap.set("n", "<leader>yd", function()
	local row = vim.api.nvim_win_get_cursor(0)[1] - 1
	local diags = vim.diagnostic.get(0, { lnum = row })
	if #diags == 0 then
		return vim.notify("No diagnostics on this line")
	end
	local msgs = vim.tbl_map(function(d)
		return d.message
	end, diags)
	vim.fn.setreg("+", table.concat(msgs, "\n"))
	vim.notify("Copied diagnostic message")
end, { desc = "Yank line diagnostics" })
