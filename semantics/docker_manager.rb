require 'docker'
require 'yaml'

Docker.url = 'tcp://172.17.0.1:2375'

# Load docker-compose file and create hash with names
# Kuk ChatGPT
compose_data = YAML.load(File.read('docker-compose.yml'))

NAMES_AND_IMAGES = {}
NAMES_AND_PORTS = {}

if compose_data && compose_data['services']
  compose_data['services'].each do |service_name, service_info|
    container_name = service_info['container_name'] || service_name

    image_name = service_info['image']
    image_name = "uservicedata-warehouse_#{container_name}" if image_name.nil?
    NAMES_AND_IMAGES[container_name] = image_name

    port = service_info['ports']
    NAMES_AND_PORTS[container_name] = port
  end
else
  puts "No 'services' found in the YAML docker-compose.yml file."
end

puts NAMES_AND_IMAGES
puts NAMES_AND_PORTS

def start_container(name, index)
  puts "Starting container: #{name}"
  puts NAMES_AND_IMAGES
  image = NAMES_AND_IMAGES[name]
  ports = NAMES_AND_PORTS[name].first.split(':')
  container = Docker::Container.create('Image' => image,
                                       'name' => "#{name}-#{index}",
                                       'HostConfig' => {
                                         'NetworkMode' => 'uservicedata-warehouse_default',
                                         'PortBindings' => {
                                           "#{ports[1]}/tcp" => [{ 'HostPort' => ports[0] }]
                                         }
                                       })
  container.start

  "#{name}-#{index}"
end

def stop_container(name)
  puts "Stopping container: #{name}"
  container = Docker::Container.get(name)
  container.stop

  name
end

def get_process(name)
  container = Docker::Container.get(name)
  container.top
end
