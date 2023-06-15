local Job = require "plenary.job"
local pickers = require "telescope.pickers"
local finders = require "telescope.finders"
local conf = require("telescope.config").values

local M = {}

M.setup = function(opts)
    print("Options: ", opts)
end

local get_topics = function()
    local topics = {}

    local job = Job:new{
        command = "ros2",
        args = {"topic", "list"},
        on_stdout = function (_, line)
            table.insert(topics, line)
        end
    }

    job:sync()

    return topics
end

M.topic_list = function(opts)
    opts = opts or {}

    pickers.new(opts, {
        prompt_title = "topic",
        finder = finders.new_table {
            results = get_topics()
        },
        sorted = conf.generic_sorter(opts),
        attach_mappings = function(_, map)
            return true
        end,
    }):find()
end

M.topic_list()

return M
