local command = require("commands/main")
--!! symbolic import denoting an interface with your usual global state object or an object with the levers
-- you can use it in any way you want
local State = require("state")
-- uncomment to dismiss all the pompery
--[[State = {
    fetchAvailableStorageNames = function() end,
    fetchFromStorage = function () end,
    fetchFromBackups = function () end,
    loadNewGame = function () end,
    showGame = function () end,
    killMany = function () end
}]]

-- custom node that just creates a predefined node and adds something to it
-- nothing prevents creating nodes from scratch though, you should watch how the builtin ones are created
local function ExampleCustomNode(arg)
    return command.str(arg)
    -- autocompletion for figuraextras support
    :suggests(function()
        local s = {}
        for name, storage in pairs(State:fetchAvailableStorageNames()) do
            table.insert(s, {name = name, tooltip = storage})
        end
        return s
    end)
end

-- by convention template-like functions are pascal case
-- a template is assumed to be a function that accepts a node for the first argument so it can be used with :with
-- and it adds non-trivial pathways
local function ExampleTemplate(node, callback)
    return node:append(
        command.literal("default")
        :executes(
            function(context)
                callback(context, "nnnnnnnnn")
            end
        )
    )
    :append(
        command.literal("from")
        :append(
            command.literal("storage")
            :append(
                ExampleCustomNode("storage_name")
                :executes(function(context)
                    callback(context, State:fetchFromStorage(context.args.storage_name))
                end)
            )
        )
        :append(
            command.literal("backup")
            :append(
                ExampleCustomNode("backup_name")
                :executes(function(context)
                    callback(context, State:fetchFromBackups(context.args.backup_name))
                end)
            )
        )
    )
end

-- add new root with a blueish color
return command.withPrefix(">", vec(0.3, 0.6, 0.9))
-- inject help command
    :addHelp()
    -- add new route to the root command
    :append(
        command.literal("load")
        -- self:with(func, ...) == func(self, ...)
        :with(ExampleTemplate, function(context, storage)
            State:loadNewGame(storage)
        end)
    )
    :append(
        command.literal("show")
        -- same template is used for a different context
        :with(ExampleTemplate, function(context, storage)
            State:showGame(storage)
        end)
    )
    :append(
        command.literal("kill")
        :append(
            -- integer argument
            command.integer("many")
            :executes(function(context)
                State:killMany(context.args.many)
            end)
        )
    )

-- and more features; look at the code to know more