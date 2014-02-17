################################################################################
# Author: Brian J Reath
# Date: May 2, 2010
#
# Copyright (c) CCI Systems, Inc. 2010
################################################################################

module Nagios3
  class Modem
    module Format

      def to_config
        config = "define host {\n"
        config << "\t_ID #{self.id}\n"
        config << "\thost_name #{self.host_name}\n"
        config << "\tuse #{self.use}\n"
        config << "\talias #{self.alias}\n"
        config << "\taddress #{self.address}\n"
        config << "\tcheck_interval #{self.check_interval}\n" if self.check_interval
        config << "\t_CMTS #{self.cmts_address}\n"
        config << "\t_SNMPCOMMUNITY #{self.snmp_community}\n"
        config << "}\n"
      end

      def to_hash
        hash = {}
        [:host_name, :alias, :address, :use, :check_interval, :cmts_address, :snmp_community].each do |field|
          hash[field] = self.send(field)
        end
        hash
      end

      def to_s
        host = "\n"
        host << "HostName: #{@host_name}\n" unless @host_name.nil?
        host << "Alias: #{@alias}\n" unless @alias.nil?
        host << "Address: #{@address}\n" unless @address.nil?
        host << "Use: #{@use}\n" unless @use.nil?
        host << "CheckInterval: #{@check_interval}\n" unless @check_interval.nil?
        host << "CMTS: #{@cmts_address}\n" unless @cmts_address.nil?
        host << "SNMPCommunity: #{@snmp_community}\n" unless @snmp_community.nil?
        host
      end

    end
  end
end
