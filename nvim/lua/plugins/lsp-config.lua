return {
	{
		"williamboman/mason.nvim",
		cmd = "Mason",
		config = function()
			require("mason").setup()
		end,
	},
	{
		"williamboman/mason-lspconfig.nvim",
		event = { "BufReadPre", "BufNewFile" },
		opts = {
			ensure_installed = { "bashls", "lua_ls", "cssls", "pylsp", "rust_analyzer" },
			auto_install = true,
		},
	},
	{
		"neovim/nvim-lspconfig",
		event = { "BufReadPre", "BufNewFile" },
		config = function()
			local capabilities = require("blink.cmp").get_lsp_capabilities()
			local lspconfig = require("lspconfig")

			-- Fungsi on_attach untuk mengaktifkan fitur setelah LSP terhubung
			local on_attach = function(client, bufnr)
				-- Mengaktifkan Inlay Hints
				if client.name == "rust_analyzer" then
					vim.lsp.inlay_hint.enable(true, { bufnr = bufnr })
				end

				-- Keymaps LSP (opsional, bisa dipindahkan ke sini)
				vim.keymap.set("n", "K", vim.lsp.buf.hover, { buffer = bufnr })
				vim.keymap.set("n", "<leader>gD", vim.lsp.buf.declaration, { buffer = bufnr, desc = "Declaration" })
				vim.keymap.set("n", "<leader>gd", vim.lsp.buf.definition, { buffer = bufnr, desc = "Definitions" })
				vim.keymap.set("n", "<leader>gr", vim.lsp.buf.references, { buffer = bufnr, desc = "References" })
				vim.keymap.set("n", "<leader>ca", vim.lsp.buf.code_action, { buffer = bufnr, desc = "Code action" })
			end

			-- Setup untuk setiap LSP
			lspconfig.bashls.setup({ capabilities = capabilities, on_attach = on_attach })
			lspconfig.cssls.setup({ capabilities = capabilities, on_attach = on_attach })
			lspconfig.lua_ls.setup({ capabilities = capabilities, on_attach = on_attach })
			lspconfig.pylsp.setup({ capabilities = capabilities, on_attach = on_attach })

			-- Konfigurasi khusus untuk rust_analyzer
			lspconfig.rust_analyzer.setup({
				capabilities = capabilities,
				on_attach = on_attach, -- Menggunakan fungsi on_attach
				settings = {
					["rust-analyzer"] = {
						inlayHints = {
							bindingModeHints = {
								enable = true,
							},
							chainingHints = {
								enable = true,
							},
							closureReturnTypeHints = {
								enable = "always",
							},
							typeHints = {
								enable = true,
							},
						},
					},
				},
			})
		end,
	},
}
