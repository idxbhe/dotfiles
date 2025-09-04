return {
	"akinsho/toggleterm.nvim",
	event = "VeryLazy",
	opts = {
		size = 20,
		hide_numbers = true,
		direction = "float",
		float_opts = {
			border = "curved",
			winblend = 0,
			highlights = {
				border = "Normal",
				background = "Normal",
			},
		},
	},
	config = function()
		require("toggleterm").setup({
			direction = "float",
		})

		-- Mengatur keymap <C-`> untuk mengaktifkan/menonaktifkan floating terminal
		-- Ini adalah cara yang paling stabil
		vim.keymap.set({ "n", "t" }, "<C-`>", "<cmd>ToggleTerm<CR>", {
			desc = "Toggle floating terminal",
		})
	end,
}
