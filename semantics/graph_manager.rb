require 'active_graph'
require 'neo4j-ruby-driver'
Dir['./models/*.rb'].each { |file| require file }

# ActiveGraph::Base.driver = Neo4j::Driver::GraphDatabase.driver('bolt://localhost:7687', Neo4j::Driver::AuthTokens.basic('neo4j','postgres'))
ActiveGraph::Base.driver = Neo4j::Driver::GraphDatabase.driver('bolt://neo4j:7687', Neo4j::Driver::AuthTokens.basic('neo4j','postgres'))

# Define a lambda function for the recursive traversal
TRAVERSE = lambda do |node, current_path, paths|
  current_path.push(node)
  if node.endpoints.empty?
    paths.push(current_path.dup)
  else
    node.endpoints.each do |endpoint|
      TRAVERSE.call(endpoint, current_path, paths)
    end
  end
  current_path.pop
end

# Define a method to find all possible paths
def find_all_paths(start_node)
  paths = []
  current_path = []
  TRAVERSE.call(start_node, current_path, paths)

  paths.each do |path|
    print_workflow(path)
  end

  paths
end

def print_workflow(nodes)
  puts '                                  | GENERATED WORKFLOW PIPELINE/S |'
  puts '---------------------------------------------------------------------------------------------------------------'
  nodes.each do |node|
    print "(#{node.rdfs__label})--->"
  end
  puts '(Saver)'
  puts '---------------------------------------------------------------------------------------------------------------'
end

def get_path_conditions(paths, request_conditions)
  conditions = []

  paths.each do |path|
    path_conditions = []
    path.each do |node|
      path_conditions << node.ns0__condition if node.respond_to?(:ns0__condition) && !node.ns0__condition.nil?
    end

    conditions << path_conditions
  end

  max_hits_percentage = 0
  max_hits = 0
  best_index = 0


  conditions.each_with_index do |path_conditions, index|
    next if path_conditions.empty?

    hits = 0

    request_conditions.each do |req_cond|
      hits += 1 if path_conditions.include?(req_cond)
    end

    hits_percentage = (hits.to_f / path_conditions.size) * 100

    if hits_percentage > max_hits_percentage
      max_hits_percentage = hits_percentage
      max_hits = hits
      best_index = index
    # if same percentage but more conditions met - 100% conditions fix
    elsif hits_percentage == max_hits_percentage && hits > max_hits
      max_hits_percentage = hits_percentage
      max_hits = hits
      best_index = index
    end

    puts "Percentage of hits for #{hits_percentage}% path: #{index} -> number of hits #{max_hits}"
    puts '-------------------------------------------------------------------'
  end

  print conditions

  puts "Max number of hits was: #{max_hits_percentage} for array index: #{best_index} -> number of hits #{max_hits}"
  print_workflow(paths[best_index])

  paths[best_index]
end

def get_urls(path)
  urls = []
  path.each do |node|
    next unless node.respond_to?(:ns0__url)

    urls << node.ns0__url
  end

  urls
end
