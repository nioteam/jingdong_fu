require 'jingdong_fu'

require 'yaml'
YAML::ENGINE.yamler = 'syck'

config_file = File.join(Rails.root, "config", "jingdong.yml")
JingdongFu.load(config_file) if FileTest::exists?(config_file)