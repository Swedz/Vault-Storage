shell.execute("delete", "vault/main")
shell.execute("delete", "vault/config")
shell.execute("delete", "vault/items")
shell.execute("delete", "vault/core")
shell.execute("delete", "vault/utils")
shell.execute("delete", "vault/turtle_inventory")
shell.execute("delete", "vault/interface/index")
shell.execute("delete", "vault/interface/request")
shell.execute("wget", "https://swedz.net/cc/vault/main.lua", "vault/main")
shell.execute("wget", "https://swedz.net/cc/vault/config.lua", "vault/config")
shell.execute("wget", "https://swedz.net/cc/vault/items.lua", "vault/items")
shell.execute("wget", "https://swedz.net/cc/vault/core.lua", "vault/core")
shell.execute("wget", "https://swedz.net/cc/vault/turtle_inventory.lua", "vault/turtle_inventory")
shell.execute("wget", "https://swedz.net/cc/vault/interface/index.lua", "vault/interface/index")
shell.execute("wget", "https://swedz.net/cc/vault/interface/request.lua", "vault/interface/request")
shell.execute("vault/main")