local runningCoroutines = {}
local coroutinesToStart = {}

function CreateTask(funct, ...)
    if type(funct) ~= "function" then
        error("Bad argument (expected function, got " .. type(funct) .. ")", 2)
    end

    local co = coroutine.create(funct)
    coroutinesToStart[co] = arg
end

function Run()
    local tFilters = {}
    local eventData = { n = 0 }

    while true do
        for key, co in pairs(runningCoroutines) do
            if co then
                if tFilters[co] == nil or tFilters[co] == eventData[1] or eventData[1] == "terminate" then
                    local ok, param = coroutine.resume(co, table.unpack(eventData, 1, eventData.n))
                    if not ok then
                        error(param, 0)
                    else
                        tFilters[co] = param
                    end
                    if coroutine.status(co) == "dead" then
                        runningCoroutines[key] = nil
                        tFilters[co] = nil
                    end
                end
            end
        end
        for co, arguments in pairs(coroutinesToStart) do
            local ok, param = coroutine.resume(co, table.unpack(arguments, 1, arguments.n))
            if not ok then
                error(param, 0)
            elseif coroutine.status(co) ~= "dead" then
                tFilters[co] = param
                table.insert(runningCoroutines, co)
            end
        end
        coroutinesToStart = {}
        eventData = table.pack(os.pullEvent())
    end
end
