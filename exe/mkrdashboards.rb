#!/usr/bin/env ruby

require 'dotenv'
require 'thor'
require 'mkrdashboards'
Dotenv.load
Mkrdashboards::Command.start(ARGV)
