shell.execute("delete", "vault_config")
shell.execute("delete", "vault_core")
shell.execute("delete", "vault_items")
shell.execute("delete", "vault_interface")
shell.execute("wget", "https://raw.githubusercontent.com/Swedz/Vault-Storage/master/vault_config.lua", "vault_config")
shell.execute("wget", "https://raw.githubusercontent.com/Swedz/Vault-Storage/master/vault_core.lua", "vault_core")
shell.execute("wget", "https://raw.githubusercontent.com/Swedz/Vault-Storage/master/vault_items.lua", "vault_items")
shell.execute("wget", "https://raw.githubusercontent.com/Swedz/Vault-Storage/master/vault_interface.lua", "vault_interface")
shell.execute("vault_interface")