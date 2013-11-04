module Phassets
  class App

    def initialize phassets_root, silent=false
      Phassets.configure do |config|
        config.silent         = silent
        config.phassets_root  = phassets_root
        config.project_root   = File.expand_path(File.join(phassets_root, '..'))
        config.config_file    = File.join(phassets_root, 'config', Phassets.config.config_filename)
        config.digests_file   = File.join(phassets_root, 'support', Phassets.config.digests_filename)
      end

      puts "\nPhassets loading..." unless Phassets.config.silent
      Phassets.load_configuration
      Phassets.load_environment
    end

    def assets_url
      Phassets.config.assets_path.chomp('/')
    end

    def sprockets
      @sprockets ||= Sprockets::Environment.new(Phassets.config.project_root) do |env|
        # env.logger = DummyLogger.new
        env.logger = Logger.new(STDOUT)
        env.append_path(File.join(Phassets.config.assets_full_path, 'javascripts'))
        env.append_path(File.join(Phassets.config.assets_full_path, 'stylesheets'))
        env.append_path(File.join(Phassets.config.assets_full_path, 'images'))
        env.js_compressor  = Uglifier.new({ :output => { comments: :none }, mangle: true })
        env.css_compressor = YUI::CssCompressor.new
        # p env.inspect
        env.context_class.class_eval do
          def asset_path(path, options = {})
            # p environment
            "images/" + path
          end
        end
      end
    end

    def read_digests_file
      if File.exists? Phassets.config.digests_file
        file_data = File.read(Phassets.config.digests_file).strip
        unless file_data.empty?
          return JSON.parse(file_data)
        end
      end
      Hash.new
    end

    def write_digests_file new_data
      current_data = read_digests_file
      if (current_data.to_a - new_data.to_a).empty? and not current_data.empty?
        puts "file digests did not change since last compilation."
      else
        File.open(Phassets.config.digests_file, 'w') {|f| f.write(current_data.merge(new_data).to_json) }
        puts "file digests updated."
      end
    end

    def environment_selection
      env_list = Phassets.available_environments
      
      STDOUT.puts "\n> Select environment:"
      env_list.each_with_index do |env, index|
        puts "#{index+1}. #{env}"
      end
      puts "0. Cancel"

      print "\n> "
      input = STDIN.gets.strip.to_i

      if (1..(env_list.size)).include? input
        local_env_file  = File.join(Phassets.config.phassets_root, 'support', Phassets.config.local_env_filename)
        File.open(local_env_file, 'w') do |f|
          f.write(env_list[input-1])
          Phassets.done("Environment '#{env_list[input-1]}' configured.\n")
        end
      else
        raise Interrupt
      end
    end

  end
end