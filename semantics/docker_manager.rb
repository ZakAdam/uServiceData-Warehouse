require 'docker'
require 'yaml'

Docker.url = 'tcp://172.17.0.1:2375'

# Load docker-compose file and create hash with names
# Kuk ChatGPT

def start_image(name, index)
  puts "Starting container: #{name}"
  image = images[name]
  container = Docker::Container.create('Image' => image,
                                       'name' => "#{name}-#{index}",
                                       'Network' => 'uservicedata-warehouse_default')
  container.start

  "#{name}-#{index}"
end

def stop_image(name)
  puts "Stopping container: #{name}"
  container = Docker::Container.get(name)
  container.stop

  name
end

def get_process(name)
  container = Docker::Container.get(name)
  container.top
end
