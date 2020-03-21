local avatar = "https://i.imgur.com/H4vqsCs.jpg"
webhookQuarry = "https://discordapp.com/api/webhooks/678438044663021588/qMc7WdDkptGk3zr9Y5VQIRcM_Z2h8sgbaV9OtfMzlIX7faWSDrmedXoMZVQBKixV6cjD"
webhookHiveMind = "https://discordapp.com/api/webhooks/690960628986413106/xXT9uP-bgz23uCi-DgS82eYv-IGl9dF3-x68rDk3rn47lwP_jiYoGkg6Ox2IFQJ5ouiv"

function Send(webhookUrl, message, username, avatar)
    local payload = "{\"username\": \"" .. username .. "\",\"content\": \"" .. message .. "\"}"
 
    local headers = {}
    headers["User-Agent"] = "(ComputerCraft "..os.version():sub(9).."x)"
    headers["Content-Type"] = "application/json"
 
    local success, err = http.post(webhookUrl, payload, headers)
    if not success then print("DiscordWebhook had a problem: "..err) end
end
