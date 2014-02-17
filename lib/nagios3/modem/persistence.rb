################################################################################
# Author: Brian J Reath
# Date: April 8, 2010
#
# Copyright (c) CCI Systems, Inc. 2010
################################################################################

module Nagios3
  class Modem
    module Persistence

      def state
        state = nil
        regexp = /hoststatus\s*\{\s*host_name=#{self.host_name}(.*?)current_state=(\d)(.*?)\}/m

        File.read(Nagios3.status_path).scan(regexp) { |match| state = $2 }

        case state
        when "0"
          "UP"
        when "1"
          "DOWN"
        else
          "UNKNOWN"
        end
      end

      def save
        if Nagios3::Modem.configured?(self.host_name); raise DuplicateModemError; end
        File.open(Nagios3.modems_path, "a") { |f| f.puts(self.to_config) }
        self
      end

      def update
        unless Nagios3::Modem.configured?(self.host_name); raise ModemNotFoundError; end
        new_config = File.read(Nagios3.modems_path).gsub(
          self.class.object_regexp(self.host_name), self.to_config
        )
        File.open(Nagios3.modems_path, "w") { |f| f.puts(new_config) }
        self
      end

      def update_attributes(params = {})
        params.each do |key, value|
          method = (key.to_s + "=").to_sym
          self.send(method, value) if self.respond_to?(method)
        end
        self.update
      end

      def destroy
        unless Nagios3::Modem.configured?(self.host_name); raise ModemNotFoundError; end
        new_config = File.read(Nagios3.modems_path).gsub(
          self.class.object_regexp(self.host_name), ""
        )
        File.open(Nagios3.modems_path, "w") { |f| f.puts(new_config) }
        self
      end

      def self.included(klass)
        klass.extend(ClassMethods)
      end

      module ClassMethods
        def configured?(address)
          if File.read(Nagios3.modems_path).match(object_regexp(address))
            true
          else
            false
          end
        end

        def find(*args)
          case args.first
          when :all then find_every
          when :cmts then find_by_cmts(args.last)
          when :address then find_by_address(args.last)
          else           find_by_name(args.last)
          end
        end

        def object_regexp(mac_address)
          /define host\s*\{([^\{]*?host_name\s#{mac_address}\n[^\}]*?)\}\s/m
        end

        def address_regexp(ip_address)
          /define host\s*\{([^\{]*?address\s#{ip_address}\n[^\}]*?)\}\s/m
        end

        def cmts_regexp(ip_address)
          /define host\s*\{([^\{]*?_CMTS\s#{ip_address}\n[^\}]*?)\}\s/m
        end

      private
        def find_every
          object_cache, modems = File.read(Nagios3.modems_path), []
          object_cache.scan(/define host\s*\{(.*?)\}/m) do |match|
            modems << parse($1)
          end
          modems
        end

        def find_by_name(mac_address)
          objects, modem = File.read(Nagios3.modems_path), nil
          if objects.match(object_regexp(mac_address))
            modem = parse($1)
          end
          modem
        end

        def find_by_address(ip_address)
          objects, modem = File.read(Nagios3.modems_path), nil
          if objects.match(address_regexp(ip_address))
            modem = parse($1)
          end
          modem
        end

        def find_by_cmts(ip_address)
          objects, modems = File.read(Nagios3.modems_path), []
          objects.scan(cmts_regexp(ip_address)) do |match|
            modems << parse($1)
          end
          modems
        end

        def parse(config)
          params = {}
          params[:id] = $1.strip if config.match param_regexp("_ID")
          params[:host_name] = $1.strip if config.match param_regexp("host_name")
          params[:alias] = $1.strip if config.match param_regexp("alias")
          params[:address] = $1.strip if config.match param_regexp("address")
          params[:check_interval] = $1.strip if config.match param_regexp("check_interval")
          params[:use] = $1.strip if config.match param_regexp("use")
          params[:snmp_community] = $1 if config.match param_regexp("_SNMPCOMMUNITY")
          params[:cmts_address] = $1 if config.match param_regexp("_CMTS")

          Nagios3::Modem.new(params)
        end

        def param_regexp(name)
          /\s#{name}\s+(.+?)[\n;]/
        end

      end

    end
  end
end
