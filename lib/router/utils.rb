# Copyright (c) 2009-2011 VMware, Inc.
def create_pid_file(pidfile)
  # Make sure dirs exist.
  begin
    FileUtils.mkdir_p(File.dirname(pidfile))
  rescue => e
     Router.log.fatal "Can't create pid directory, exiting: #{e}"
  end
  File.open(pidfile, 'w') { |f| f.puts "#{Process.pid}" }
end

def stop(pidfile)
  # Double ctrl-c just terminates
  exit if Router.shutting_down?
  Router.shutting_down = true
  Router.log.info 'Signal caught, shutting down..'
  Router.log.info 'waiting for pending requests to complete.'
  EM.stop_server(Router.server) if Router.server
  EM.stop_server(Router.local_server) if Router.local_server

  exit_router(pidfile)
end

def exit_router(pidfile)
  NATS.stop { EM.stop }
  Router.log.info "Bye"
  FileUtils.rm_f(pidfile)
  exit
end
