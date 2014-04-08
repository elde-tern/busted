--interface:
--  output.short_status
--  output.descriptive_status
--  output.currently_executing

local ansicolors = require "ansicolors"
local s = require 'say'

local output = function()
  local pending_description = function(status, options)
    return "\n\n"..ansicolors("%{yellow}"..s('output.pending')).." → "..
    ansicolors("%{cyan}"..status.info.short_src).." @ "..
    ansicolors("%{cyan}"..status.info.linedefined)..
    "\n"..ansicolors("%{bright}"..status.description)
  end

  local dryrun_description = function(status, options)
    return "\n\n"..ansicolors("%{magenta}"..s('output.dryrun')).." → "..
    ansicolors("%{cyan}"..status.info.short_src).." @ "..
    ansicolors("%{cyan}"..status.info.linedefined)..
    "\n"..ansicolors("%{bright}"..status.description)
  end

  local error_description = function(status, options)
    return "\n\n"..ansicolors("%{red}"..s('output.failure')).." → "..
    ansicolors("%{cyan}"..status.info.short_src).." @ "..
    ansicolors("%{cyan}"..status.info.linedefined)..
    "\n"..ansicolors("%{bright}"..status.description)..
    "\n"..status.err
  end

  local success_string = function()
    return ansicolors('%{green}●')
  end

  local failure_string = function()
    return ansicolors('%{red}●')
  end

  local pending_string = function()
    return ansicolors('%{yellow}●')
  end

  local dryrun_string = function()
    return ansicolors('%{magenta}●')
  end
  local running_string = function()
    return ansicolors('%{blue}○')
  end

  local status_string = function(short_status, descriptive_status, successes, failures, pendings, dryruns, ms, options)
    local success_str = s('output.success_plural')
    local failure_str = s('output.failure_plural')
    local pending_str = s('output.pending_plural')

    local dryrun_str = s('output.dryrun_plural')

    if successes == 0 then
      success_str = s('output.success_zero')
    elseif successes == 1 then
      success_str = s('output.success_single')
    end

    if failures == 0 then
      failure_str = s('output.failure_zero')
    elseif failures == 1 then
      failure_str = s('output.failure_single')
    end

    if pendings == 0 then
      pending_str = s('output.pending_zero')
    elseif pendings == 1 then
      pending_str = s('output.pending_single')
    end

    if dryruns == 0 then
      dryrun_str = s('output.dryrun_zero')
    elseif dryruns ==1 then
      dryrun_str = s('output.dryrun_single')
    end

    if not options.defer_print then
      io.write("\08 ")
      short_status = ""
    end

    local formatted_time = ("%.6f"):format(ms):gsub("([0-9])0+$", "%1")

    return short_status.."\n"..
    ansicolors('%{green}'..successes).." "..success_str.." / "..
    ansicolors('%{red}'..failures).." "..failure_str.." / "..
    ansicolors('%{yellow}'..pendings).." "..pending_str.." : "..
    ansicolors('%{magenta}'..dryruns).." "..dryrun_str.." : "..
    ansicolors('%{bright}'..formatted_time).." "..s('output.seconds').."."..descriptive_status
  end

  local format_statuses = function (statuses, options)
    local short_status = ""
    local descriptive_status = ""
    local successes = 0
    local failures = 0
    local pendings = 0
    local dryruns = 0

    for i,status in ipairs(statuses) do
      if status.type == "description" then
        local inner_short_status, inner_descriptive_status, inner_successes, inner_failures, inner_pendings, inner_dryruns = format_statuses(status, options)
        short_status = short_status..inner_short_status
        descriptive_status = descriptive_status..inner_descriptive_status
        successes = inner_successes + successes
        failures = inner_failures + failures
        pendings = inner_pendings + pendings
        dryruns = inner_dryruns + dryruns
      elseif status.type == "success" then
        short_status = short_status..success_string(options)
        successes = successes + 1
      elseif status.type == "failure" then
        short_status = short_status..failure_string(options)
        descriptive_status = descriptive_status..error_description(status, options)

        if options.verbose then
          descriptive_status = descriptive_status.."\n"..status.trace
        end

        failures = failures + 1
      elseif status.type == "pending" then
        short_status = short_status..pending_string(options)
        pendings = pendings + 1

        if not options.suppress_pending then
          descriptive_status = descriptive_status..pending_description(status, options)
        end
      elseif status.type == "dryrun" then
        short_status = short_status..dryrun_string(options)
        dryruns = dryruns + 1
        if options.dry_run then
          descriptive_status = descriptive_status..dryrun_description(status, options)
        end
      end
    end

    return short_status, descriptive_status, successes, failures, pendings, dryruns
  end

  local strings = {
    failure = failure_string,
    success = success_string,
    pending = pending_string,
    dryrun = dryrun_string,
  }

  local on_first

  return {
    options = {},
    name = "utf_whatever",

    header = function(desc, test_count)
      on_first = true
    end,


    formatted_status = function(statuses, options, ms)
      local short_status, descriptive_status, successes, failures, pendings, dryruns = format_statuses(statuses, options)
      return status_string(short_status, descriptive_status, successes, failures, pendings, dryruns, ms, options)
    end,

    currently_executing = function(test_status, options)
      if on_first then
        on_first = false
      else
        io.write("\08")
      end

      io.write(strings[test_status.type](options)..running_string(options))
      io.flush()
    end
  }
end

return output
