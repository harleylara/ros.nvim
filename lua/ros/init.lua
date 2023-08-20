local Job = require "plenary.job"
local pickers = require "telescope.pickers"
local finders = require "telescope.finders"
local previewers = require "telescope.previewers"

local previewers_utils = require 'telescope.previewers.utils'

local conf = require("telescope.config").values
local actions = require "telescope.actions"
local action_state = require "telescope.actions.state"

local checks = require("ros.checks")

local M = {}

M._checks = checks;

M.setup = function(opts)
    print("Options: ", opts)
end

-- A generic function to retrieve list of topics, node, param, others...
-- @param command ros command to list
local get_list = function (command)

    -- default get list of topics
    command = command or "topic"

    Job:new {
        command = "ros2",
        args = {command, "list"},
        on_exit = function (j, return_val)
            list = j:result()
        end
    }:sync()

    return list
end

-- generic function to show a list of stuff
-- @param opts for future use
-- @param command ros command to list
local generic_list = function (opts, command)
    opts = opts or {}
    -- default list topic
    command = command or "topic"

    pickers.new(opts,{
        prompt_title = "search " .. command,
        finder = finders.new_table {
            results = get_list(command)
        },
        sorter = conf.generic_sorter(opts),
        attach_mappings = function(prompt_bufnr, map)
            actions.select_default:replace(function()
                actions.close(prompt_bufnr)
                local selection = action_state.get_selected_entry()
                -- do nothing
            end)
            return true
        end
    }):find()
end

-- generic function to show Information in previewer
-- @param opts for future use
-- @param command ros command (e.g. topic, node, param)
-- @param verb action to execute with command (e.g. list, info, show, echo)
local generic_previwer = function(opts, command, verb, args)

    opts = opts or {}
    -- default get topic Information
    command = command or "topic"
    verb = verb or "list"

    pickers.new(opts,{
        prompt_title = "search " .. command,
        finder = finders.new_table {
            results = get_list(command)
        },
        sorter = conf.generic_sorter(opts),
        attach_mappings = function(prompt_bufnr, map)
            actions.select_default:replace(function()
                actions.close(prompt_bufnr)
                local selection = action_state.get_selected_entry()
                -- do nothing
            end)
            return true
        end,
        previewer = previewers.new_termopen_previewer {
            title = "Information",
            get_command = function (entry, status)
                local current_selection = entry[1]:gsub("%s+", "")
                return { 'ros2', command, verb, current_selection, args}
            end,
        },
    }):find()

end

M.interface_show = function ()
    generic_previwer({}, "interface", "show")
end

M.topic_list = function ()
    generic_list({}, "topic")
end

M.topic_info = function ()
    generic_previwer({}, "topic", "info", "-v")
end

return M
