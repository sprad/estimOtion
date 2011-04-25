require 'settingslogic'

class EstimotionConfig < Settingslogic
  source "#{Dir.pwd}/estimotion_config.yml"
  load!
end
