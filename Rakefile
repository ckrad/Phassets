$:.unshift File.expand_path("../lib", __FILE__)

require 'bundler/setup'
Bundler.require
require 'json'
require 'phassets'

@ph = Phassets::App.new(File.dirname(__FILE__), true)

desc 'change environment'
task :environment do

  begin  
    @ph.environment_selection
  rescue Interrupt
    STDOUT.puts "Cancelled."
  end

end

namespace :assets do

  @assets_path  = File.expand_path(File.join('..', Phassets.config.assets_path))
  @digests      = {}

  desc 'compile all assets'
  task :compile => [:do_compile_js, :do_compile_css, :do_write_digests]

  desc 'compile only javascripts'
  task :compile_js => [:do_compile_js, :do_write_digests]

  desc 'compile only stylesheets'
  task :compile_css => [:do_compile_css, :do_write_digests]

  # ----------------------------------

  task :do_compile_js do
    puts ""

    Phassets.config.js_manifests.each do |manifest_file|
      # asset.digest_path
      asset = @ph.sprockets[manifest_file]
      outfile  = Pathname.new(@assets_path).join(manifest_file)
      FileUtils.mkdir_p outfile.dirname
      asset.write_to(outfile)
      @digests[manifest_file] = asset.digest
    end

    Phassets.done("Javascripts compiled.\n")
  end

  task :do_compile_css do
    puts ""

    Phassets.config.css_manifests.each do |manifest_file|
      asset    = @ph.sprockets[manifest_file]
      outfile  = Pathname.new(@assets_path).join(manifest_file)
      FileUtils.mkdir_p outfile.dirname
      asset.write_to(outfile)
      @digests[manifest_file] = asset.digest
    end

    Phassets.done("Stylesheets compiled.\n")
  end

  task :do_write_digests do
    puts ""
    @ph.write_digests_file(@digests)
    Phassets.done("Digests exported.\n")
  end

end

task :default do
  puts "\nAvailable Tasks:\n--------------------"
  puts %x[rake -T]
end