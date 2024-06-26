require 'docker'
require 'yaml'

Docker.url = 'tcp://172.17.0.1:2375'

# Load docker-compose file and create hash with names
compose_data = YAML.load(File.read('docker-compose.yml'))

NAMES_AND_IMAGES = {}
NAMES_AND_PORTS = {}
PROJECT_NAME = ENV['COMPOSE_PROJECT_NAME']

if compose_data && compose_data['services']
  compose_data['services'].each do |service_name, service_info|
    container_name = service_info['container_name'] || service_name

    image_name = service_info['image']
    image_name = "#{PROJECT_NAME}_#{container_name}" if image_name.nil?
    NAMES_AND_IMAGES[container_name] = image_name

    port = service_info['ports']
    NAMES_AND_PORTS[container_name] = port
  end
else
  puts "No 'services' found in the YAML docker-compose.yml file."
end

def start_container(name)
  puts "Starting container: #{name}"
  image = NAMES_AND_IMAGES[name]
  ports = NAMES_AND_PORTS[name].first.split(':')

  container = Docker::Container.create('Image' => image,
                                       'HostConfig' => {
                                         'NetworkMode' => "#{PROJECT_NAME}_default",
                                         'PortBindings' => {
                                           "#{ports[1]}/tcp" => [{ 'HostPort' => ports[0] }]
                                         }
                                       })

  container.start!

  # return generated name
  # this secures, that name is free and container can start
  container.json['Name'][1..]
end

def stop_container(name)
  puts "Stopping container: #{name}"
  begin
    container = Docker::Container.get(name)
    container.stop
    container.delete(force: true)
  rescue Docker::Error::NotFoundError
    puts 'Not found'
  end

  name
end

def get_process(name)
  container = Docker::Container.get(name)
  container.top
end
