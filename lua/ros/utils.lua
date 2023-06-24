local Path = require("plenary.path")

local utils = {}

local isInstalled = function ()
    -- check if ros is isInstalled
    if Path:new("/opt/ros/").is_dir then
        print("ROS is intalled")
        return true
    else
        return false
    end
end

local isSourced = function ()
    local sourced_ros_distro = vim.env.ROS_DISTRO

    if sourced_ros_distro then
        -- print("The current sourced ros distro is: " .. sourced_ros_distro)
        return true
    else
        error("ROS is not sourced")
        return false
    end
end

local checkVersion = function ()
    local ros_version = vim.env.ROS_VERSION

    print("The current istalled ROS version is: " .. ros_version)
end

local precheck = function ()
    isInstalled()
    isSourced()
    checkVersion()
end

precheck()

return utils
