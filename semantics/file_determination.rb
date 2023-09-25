=begin
  Ruby script to determine what file type is recieved.
  Two methods are used:
    1. file_endings -> parses file type from ending of file name
    2. file_mime -> Unix library used to determine file type
=end

def file_endings
  File.extname(FILE)
end

def file_mime
  IO.popen(
    ['file', '--brief', '--mime-type', FILE],
    in: :close, err: :close
  ) { |io| io.read.chomp }
end

FILE = '/home/adam/Desktop/FIIT/DP/files/Heureka/mensie.xml'
puts file_endings
puts file_mime
