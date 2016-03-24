require "lighter_box/version"

module LighterBox
  # We need to subclass Rails::Engine, so that Rails adds our assets directory to its assets search path.
  if defined? Rails
    class Engine < ::Rails::Engine
    end
  end
end
