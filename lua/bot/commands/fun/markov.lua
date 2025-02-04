local running = 0

bot.add_command("markov", {
    description = "Generate a random sentence using Markov",
    aliases = { "m" },
    args = {
        {
            key = "input",
            name = "INPUT",
            description = "Input for start of sentence",
        }
    },
    callback = function(ctx)
        if running >= 6 then
            return ctx.msg:reply("current running markov operations limit reached"):await()
        end

        running = running + 1

        local succ, res = pcall(function()
            local input = (ctx.args.input or "")

            if #ctx.extra_args > 0 then
                input = input .. " " .. table.concat(ctx.extra_args, " ")
            end
    
            ctx.msg.channel:send_typing()
    
            local res = http.fetch("http://127.0.0.1:3000/markov?channel=" .. ctx.msg.channel.id .. "&server=" .. ctx.msg.channel.server.id, { body = input, stream = true }):await()
            local reply
    
            while res.next_body do
                res = res.next_body:await()
    
                if not res then
                    if reply and ctx.msg.channel:supports_feature(bot.FEATURES.React) then
                        reply:react("✅")
                    end

                    return reply
                end
    
                if reply then
                    local succ, _ = pcall(function()
                        reply:edit(ctx.msg.channel:escape_text(res.body)):await()
                    end)

                    if not succ then break end
                else
                    reply = ctx.msg.channel:send(ctx.msg.channel:escape_text(res.body)):await()
                    bot.add_command_history(ctx.msg, reply)
                end
            end

            return reply
        end)

        running = math.max(running - 1, 0)

        if succ then
            return res
        -- Throw the error if it was not due to the message being deleted
        elseif string.match(res, "Unknown Message") then
            error(res)
        end
    end,
})
