################################################################################
# Author: Brian J Reath
# Date: April 8, 2010
#
# Copyright (c) CCI Systems, Inc. 2010
################################################################################

require 'nagios3/service_escalation/attributes'
require 'nagios3/service_escalation/persistence'
require 'nagios3/service_escalation/format'

module Nagios3
  class ServiceEscalation
    
    include Nagios3::ServiceEscalation::Attributes
    include Nagios3::ServiceEscalation::Format
    include Nagios3::ServiceEscalation::Persistence
    
    def initialize(params = {})
      options = {}.merge(params)
      
      options.each do |key, value|
        method = (key.to_s << "=").to_sym
        if self.respond_to?(method)
          self.send(method, value)
        end
      end
    end
    
  end
end
