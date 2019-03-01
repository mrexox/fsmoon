require_relative './rpm'
require 'sysmoon/log'
require 'sysmoon/ipc/data/package'

module Sysmoon
  class RhelPackageWatcher

    attr_reader :thread # FIXME: remove

    def initialize(queue)
      @queue = queue
      @rpm_packages = Rpm.new
      @ignore = []
      @thread = nil
    end

    def run
      @thread = Thread.new do
        loop {
          sleep 10 # FIXME: don't use magic numbers
          @rpm_packages.changes.each do |pkg|
            if procedd_or_ignore(pkg)
              @queue << pkg
              Log.debug pkg
            end
          end
        }
      end

      @thread
    end

    def ignore(package)
      @ignore << package if
        package.is_a? Sysmoon::IPC::Data::Package
    end

    private

    def process_or_ignore(package)
      index = -1
      Log.debug("Ignore aray: #{@ignore}")

      @ignore.each_with_index do |ignpkg, i|
        if ignpkg.name == package.name and ignpkg.version == package.version
          index = i
          break
        end
      end

      if index != -1
        Log.debug("Igored package #{package}")
        @ignore.delete_at(index)
        return nil
      end

      true
    end
  end
end
