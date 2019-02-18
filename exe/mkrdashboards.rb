#!/usr/bin/env ruby

require 'dotenv'
require 'mkrdashboards'
Dotenv.load
Mkrdashboards::Command.start(ARGV)
