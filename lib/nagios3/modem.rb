################################################################################
# Author: Brian J Reath
# Date: April 7, 2010
#
# Copyright (c) CCI Systems, Inc. 2010
################################################################################

require 'nagios3/modem/attributes'
require 'nagios3/modem/persistence'
require 'nagios3/modem/format'

module Nagios3
  class Modem

    include Nagios3::Modem::Attributes
    include Nagios3::Modem::Format
    include Nagios3::Modem::Persistence

    def initialize(params = {})
      options = {
        :use => 'generic-host'
      }.merge(params)

      options.each do |key, value|
        method = (key.to_s + "=").to_sym
        if self.respond_to?(method)
          self.send(method, value)
        end
      end
    end

  end
end
