require 'phassets/support'

module Phassets

  autoload :App, "phassets/app"

  class << self
    attr_accessor :config
  end

  def self.configure
    self.config ||= Configuration.new
    yield(config)
  end

  class Configuration
    attr_reader   :config_filename, :digests_filename, :local_env_filename
    attr_accessor :js_manifests, :css_manifests, :default_environment, :environment,
                  :silent, :phassets_root, :project_root, :config_file, :digests_file,
                  :base_url, :assets_path, :static_assets, :assets_full_path

    def initialize
      @config_filename      = 'settings.json'
      @digests_filename     = 'digests.json'
      @local_env_filename   = 'local_environment'
      @environment          = nil
    end
  end

  def self.die message
    abort "Error:".red + " #{message}"
  end

  def self.notice message
    puts "Notice:".brown + " #{message}" unless config.silent
  end

  def self.done message
    puts "Done:".green + " #{message}"
  end

  def self.load_configuration
    parse_json(config.config_file).each_pair do |name, val|
      config.method("#{name}=").call(val)
    end
  end

  def self.load_environment
    read_local_environment
    load_environment_configuration config.environment
  end

  private

  def self.load_environment_configuration env_name
    env_file_path = File.join(config.phassets_root, 'config', 'environments', "#{env_name}.json")
    parse_json(env_file_path).each_pair do |name, val|
      config.method("#{name}=").call(val)
    end
    config.assets_full_path = File.join(config.project_root, config.assets_path);
  end

  def self.available_environments
    pattern = File.join(config.phassets_root, 'config', 'environments', '*.json')
    Dir.glob(pattern).map do |path|
      File.basename(path, '.json')
    end
  end

  def self.read_local_environment    
    local_env_file  = File.join(config.phassets_root, 'support', config.local_env_filename)

    if File.exist? local_env_file
      config.environment = File.read(local_env_file).strip
    else
      notice "Environment not set. Using '#{config.default_environment}'(default). Run 'rake environment' to hide this message."
      config.environment = config.default_environment
    end

    if config.environment.empty?
      die "Your current environment is invalid. Run 'rake environment' or add a valid 'default_environment' value to the 'settings.json' file to fix this."
    end

    unless available_environments.include? config.environment
      die "The config file for the '#{config.environment}' environment doesn't exist."
    end
  end

  def self.read_file file_path
    File.read(file_path).strip
  rescue Errno::ENOENT
    die "The file '#{file_path}' doesn't exist."
  end

  def self.parse_json file_path
    config_file_contents = read_file(file_path)
    JSON.parse(config_file_contents)
  rescue
    die "The config file '#{file_path}' contains invalid JSON syntax."
  end

end