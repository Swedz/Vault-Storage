shell.execute("delete", "vault/main")
shell.execute("wget", "https://swedz.net/cc/vault/main.lua", "vault/main")

shell.execute("delete", "vault/config")
shell.execute("wget", "https://swedz.net/cc/vault/config.lua", "vault/config")

shell.execute("delete", "vault/items")
shell.execute("wget", "https://swedz.net/cc/vault/items.lua", "vault/items")

shell.execute("delete", "vault/core")
shell.execute("wget", "https://swedz.net/cc/vault/core.lua", "vault/core")

shell.execute("delete", "vault/depositor")
shell.execute("wget", "https://swedz.net/cc/vault/depositor.lua", "vault/depositor")

shell.execute("delete", "vault/interface/index/index")
shell.execute("wget", "https://swedz.net/cc/vault/interface/index/index.lua", "vault/interface/index/index")
shell.execute("delete", "vault/interface/index/request")
shell.execute("wget", "https://swedz.net/cc/vault/interface/index/request.lua", "vault/interface/index/request")
shell.execute("delete", "vault/interface/details")
shell.execute("wget", "https://swedz.net/cc/vault/interface/details.lua", "vault/interface/details")
shell.execute("delete", "vault/interface/interfaces")
shell.execute("wget", "https://swedz.net/cc/vault/interface/interfaces.lua", "vault/interface/interfaces")
shell.execute("delete", "vault/interface/interfaceutils")
shell.execute("wget", "https://swedz.net/cc/vault/interface/interfaceutils.lua", "vault/interface/interfaceutils")
shell.execute("delete", "vault/interface/manual")
shell.execute("wget", "https://swedz.net/cc/vault/interface/manual.lua", "vault/interface/manual")

shell.execute("vault/main")