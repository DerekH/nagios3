################################################################################
# Author: Brian J Reath
# Date: April 8, 2010
#
# Copyright (c) CCI Systems, Inc. 2010
################################################################################

module Nagios3
  class Modem
    module Attributes

      attr_accessor :id, :host_name, :alias, :address, :use
      attr_accessor :check_interval, :snmp_community, :cmts_address

      def self.included(klass)
        klass.extend(ClassMethods)
      end

      module ClassMethods
      end

    end
  end
end
