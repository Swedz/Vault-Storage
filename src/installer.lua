local function yesOrNo()
    local char
    repeat
        local _, c = os.pullEvent("char")
        char = c
    until char == "y" or char == "n"
    return char == "y"
end

if turtle == nil or not term.isColor() then
    printError("You can only install Vault onto an Advanced Turtle.")
    return
end

local keepConfig = false
if fs.exists("vault/config") then
    term.setTextColor(colors.yellow)
    print("Would you like to keep your existing config? (y/n)")
    term.setTextColor(colors.orange)
    print("NOTE: If the config format has changed and you keep your current config, you will encounter errors.")
    keepConfig = yesOrNo()
    if not keepConfig and fs.exists("vault/config") then
        term.setTextColor(colors.yellow)
        print("Would you like to backup your existing config? (y/n)")
        term.setTextColor(colors.orange)
        print("NOTE: This will override any existing config backup you may or may not have.")
        if yesOrNo() then
            fs.delete("vault_config_backup")
            fs.copy("vault/config", "vault_config_backup")
            term.setTextColor(colors.lime)
            print("Your current config has been backed up at 'vault_config_backup'.")
        end
    end
    term.setTextColor(colors.white)
    sleep(3)
end

fs.delete("vault")
fs.delete("startup")

shell.execute("wget", "https://swedz.net/cc/vault/main.lua", "vault/main")

if keepConfig then
    fs.copy("vault_config_backup", "vault/config")
else
    shell.execute("wget", "https://swedz.net/cc/vault/config.lua", "vault/config")
end

shell.execute("wget", "https://swedz.net/cc/vault/items.lua", "vault/items")

shell.execute("wget", "https://swedz.net/cc/vault/core.lua", "vault/core")

shell.execute("wget", "https://swedz.net/cc/vault/depositor.lua", "vault/depositor")

shell.execute("wget", "https://swedz.net/cc/vault/interface/index/index.lua", "vault/interface/index/index")
shell.execute("wget", "https://swedz.net/cc/vault/interface/index/request.lua", "vault/interface/index/request")
shell.execute("wget", "https://swedz.net/cc/vault/interface/details.lua", "vault/interface/details")
shell.execute("wget", "https://swedz.net/cc/vault/interface/interfaces.lua", "vault/interface/interfaces")
shell.execute("wget", "https://swedz.net/cc/vault/interface/interfaceutils.lua", "vault/interface/interfaceutils")
shell.execute("wget", "https://swedz.net/cc/vault/interface/manual.lua", "vault/interface/manual")

local startup = fs.open("startup", "w")
startup.writeLine("shell.execute(\"vault/main\")")
startup.close()

term.setTextColor(colors.lime)
print("Successfully installed Vault onto your computer!")
print("Reboot to start your Vault.")
term.setTextColor(colors.white)