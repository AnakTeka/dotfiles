-- Auto-switch between Speaker and Headphones profiles based on jack detection.
-- For Intel SOF cards where Speaker/Headphones are on separate profiles.

cutils = require ("common-utils")
log = Log.open_topic ("s-autoswitch-headphones")

SimpleEventHook {
  name = "device/autoswitch-headphones-profile",
  interests = {
    EventInterest {
      Constraint { "event.type", "=", "device-params-changed" },
      Constraint { "event.subject.param-id", "c", "EnumRoute" },
    },
  },
  execute = function (event)
    local device = event:get_subject ()

    -- Only handle ALSA devices
    if device.properties["device.api"] ~= "alsa" then
      return
    end

    -- Check headphone route availability
    local hp_available = false
    for p in device:iterate_params ("EnumRoute") do
      local route = cutils.parseParam (p, "EnumRoute")
      if route and route.direction == "Output"
          and string.find (route.name, "Headphone") then
        if route.available == "yes" then
          hp_available = true
        end
        break
      end
    end

    -- Get current profile
    local current_profile = nil
    for p in device:iterate_params ("Profile") do
      current_profile = cutils.parseParam (p, "Profile")
    end

    if not current_profile then
      return
    end

    -- Check if we're already on the correct profile
    local on_hp_profile = string.find (current_profile.name, "Headphone") ~= nil
    if hp_available == on_hp_profile then
      return
    end

    -- Find the target profile
    local target_keyword = hp_available and "Headphone" or "Speaker"
    local target_profile = nil

    for p in device:iterate_params ("EnumProfile") do
      local profile = cutils.parseParam (p, "EnumProfile")
      if profile and profile.available ~= "no"
          and string.find (profile.name, target_keyword) then
        target_profile = profile
        break
      end
    end

    if target_profile then
      log:info (device, string.format (
          "Auto-switching to profile '%s' (headphones %s)",
          target_profile.name,
          hp_available and "plugged in" or "unplugged"))

      local param = Pod.Object {
        "Spa:Pod:Object:Param:Profile", "Profile",
        index = tonumber (target_profile.index),
      }
      device:set_param ("Profile", param)
    end
  end
}:register ()
