local Path = require("plenary.path")

local _checks = {}


local isInstalled = function ()
    -- check if ros is isInstalled
    -- this only work if ros was installed
    -- from binary
    -- TODO: what about if ros is installed from source
    if Path:new("/opt/ros/").is_dir then
        return true
    else
        return false
    end
end

local isSourced = function ()
    local sourced_ros_distro = vim.env.ROS_DISTRO
    _checks.distro = sourced_ros_distro

    if sourced_ros_distro then
        return true
    else
        -- error("ROS is not sourced")
        return false
    end
end

local checkVersion = function ()
    local ros_version = vim.env.ROS_VERSION
    _checks.ros_version = ros_version

    if ros_version == 1 then
        error("ROS 1 is not supported (or at least not yet).")
    end
end

local runChecks = function ()

    if not isSourced() then
        if isInstalled() then
            error("ROS appears to be installed but has not been sourced.")
        else
            error("It seems that ROS is not installed")
            -- TODO if ROS was installed from source add the directory to the "source" option in setup
        end
    end

    checkVersion()
end

runChecks()

return _checks
