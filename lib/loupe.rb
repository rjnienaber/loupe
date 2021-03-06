require 'rubygems'
require 'thor'
require 'bundler'
require 'yaml'

unless Kernel.respond_to?(:require_relative)
  module Kernel
    def require_relative(path)
      require File.join(File.dirname(caller[0]), path.to_str)
    end
  end
end

Bundler.ui = Bundler::UI::Shell.new({})

require_relative 'loupe/version'
require_relative 'loupe/gemset'
require_relative 'loupe/advisory'
require_relative 'loupe/advisory_repository'
