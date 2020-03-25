local webhookUrl = "https://discordapp.com/api/webhooks/690960628986413106/xXT9uP-bgz23uCi-DgS82eYv-IGl9dF3-x68rDk3rn47lwP_jiYoGkg6Ox2IFQJ5ouiv"

function Send(...)
    local message = ""
    for i = 1, arg.n do
        message = message .. tostring(arg[i]) .. " "
    end
 
    local payload = "{\"content\": \"" .. message .. "\"}"
 
    local headers = {}
    headers["User-Agent"] = "(ComputerCraft "..os.version():sub(9).."x)"
    headers["Content-Type"] = "application/json"
 
    local success, err = http.post(webhookUrl, payload, headers)
    if not success then print("Discord webhook had a problem: "..err) end
end
