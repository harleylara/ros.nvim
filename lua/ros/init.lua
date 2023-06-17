local Job = require "plenary.job"
local pickers = require "telescope.pickers"
local finders = require "telescope.finders"
local previewers = require "telescope.previewers"

local previewers_utils = require 'telescope.previewers.utils'

local conf = require("telescope.config").values
local actions = require "telescope.actions"
local action_state = require "telescope.actions.state"

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

local get_topic_info = function ()

end

M.topic_list = function(opts)
    opts = opts or {}
    pickers.new(opts, {
        prompt_title = "search topic",
        finder = finders.new_table {
            results = get_topics()
        },
        sorter = conf.generic_sorter(opts),
        attach_mappings = function(prompt_bufnr, map)
            actions.select_default:replace(function()
                actions.close(prompt_bufnr)
                local selection = action_state.get_selected_entry()
                -- print(vim.inspect(selection))
                -- do nothing
            end)
            return true
        end
    }):find()
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
-- @param command ros command to list
local generic_info = function(opts, command)

    opts = opts or {}
    -- default get topic Information
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
        end,
        previewer = previewers.new_buffer_previewer {
            title = "Information",
            define_preview = function(self, entry, status)
                local preview_bufnr = self.state.bufnr
                -- local topic_name = entry[1]
                Job:new({
                    command = "ros2",
                    args = {command, "info", entry[1]},
                    on_stdout = vim.schedule_wrap(
                        function(error, line, j_self)
                            local result = j_self:result()
                            vim.api.nvim_buf_set_lines(preview_bufnr, 0, -1, false, result)
                        end
                    ),
                    on_exit = vim.schedule_wrap(
                        function(j_self, _, _)
                            local result = j_self:result()
                            vim.api.nvim_buf_set_lines(preview_bufnr, 0, -1, false, result)
                        end
                    )
                }):start()
            end
        },
    }):find()

end

--[[
-- TODO create a generic previewer
--]]

generic_info({}, "node")

M.topic_info = function (opts)
    opts = opts or {}

    Job:new {
        command = "ros2",
        args = {"topic", "list"},
        on_exit = vim.schedule_wrap(
            function (j, return_val)
                local topics = j:result()
                local picker_opts = {}
                pickers.new(picker_opts, {
                    prompt_title = "search topic",
                    finder = finders.new_table {
                        results = topics
                    },
                    sorter = conf.generic_sorter(picker_opts),
                    previewer = previewers.new_buffer_previewer {
                        title = "Information",
                        define_preview = function(self, entry, status)
                            local preview_bufnr = self.state.bufnr
                            -- local topic_name = entry[1]
                            Job:new({
                                command = "ros2",
                                args = {"topic", "info", entry[1]},
                                on_stdout = vim.schedule_wrap(
                                    function(error, line, j_self)
                                        local result = j_self:result()
                                        vim.api.nvim_buf_set_lines(preview_bufnr, 0, -1, false, result)
                                    end
                                ),
                                on_exit = vim.schedule_wrap(
                                    function(j_self, _, _)
                                        local result = j_self:result()
                                        vim.api.nvim_buf_set_lines(preview_bufnr, 0, -1, false, result)
                                    end
                                )
                            }):start()
                        end
                    },
                    attach_mappings = function(prompt_bufnr, map)
                        actions.select_default:replace(function()
                            actions.close(prompt_bufnr)
                            local selection = action_state.get_selected_entry()
                            -- print(vim.inspect(selection))
                            -- do nothing
                        end)
                        return true
                    end

            }):find()
        end
    )
    }:sync()

end

-- M.topic_info()

return M
