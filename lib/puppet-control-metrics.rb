#!/usr/bin/env ruby

require 'git'
require 'logger'
require 'puppet'
require 'r10k'
require 'r10k/puppetfile'
require 'r10k/cli'

def missingdependencies
  module_dependencies = `puppet module list --modulepath ./modules > /dev/null 2> modulestemp.txt && cat modulestemp.txt | col -b > modules.txt && sed -i 's/1;33m//g' modules.txt && sed -i 's/0m//g' modules.txt`
  File.readlines('modules.txt').each do |line|
    if line =~ /Warning: Missing dependency /
      tester = line.split
      tester = tester[3]
      $dependency = tester.gsub(/'/,'').gsub(/:/,'')
    end
    if line =~ /requires /
      puppetmodule = line.split
      $puppetmodule = puppetmodule[0].gsub(/'/,'')
      $modulestuff = $modulestuff.to_s + "{" + "\"puppetmodule\": " + '"' + $puppetmodule.to_s + '",' + "\"dependency\": " + '"' + $dependency.to_s + '"' + "},"
    end
  end

  output = "\"missingdependencies\": [ " + $modulestuff.to_s.chomp(',') + "],"
  puts output
end
missingdependencies()

def modules
  @ary = []
  puppetfile = R10K::Puppetfile.new('.')
  puppetfile.load!
  puppetfile.modules.each do |puppet_module|
    @ary.push(puppet_module.title)
  end
  $modules = @ary.sort
end
modules()

# modules
def missingmodules
  missingmodulesarray = []
  missingmodulesarray = `ls modules/`.split("\n")
  missingmodulesarray = missingmodulesarray.sort

  @missingmodules = @ary - missingmodulesarray
  $missingmodulesoutput = @missingmodules
end
missingmodules()

# r10k version
def r10kversion
  version = `r10k version`
  $r10k_version = version.split(' ')[1]
end
r10kversion()

# Number of Puppet Modules
def modulecount
  $number_of_modules = @ary.count().to_s
end
modulecount()

# Number of Puppet Modules
def missingmodulecount
  $number_of_missing_modules = @missingmodules.count().to_s
end
missingmodulecount()

# Get Control Repo Name
def gitreponame
  g = Git.open(Dir.pwd)
  control_repo = g.config('remote.origin.url').to_s
  control_repo = control_repo.split('/')
  control_repo = control_repo[-1].chomp.split('.')
  control_repo = control_repo[0]
  output = "\"control_repo\": " + '"' + control_repo + '",'
  puts output
end
gitreponame()

# Get Commit Author
def gitcommitauthor
  g = Git.open(Dir.pwd)
  commit = g.gcommit('HEAD')
  $commit_author = commit.author.name
end
gitcommitauthor()

def gitcommithash
  g = Git.open(Dir.pwd)
  commit = g.gcommit('HEAD')
  $commit_hash = commit.sha
end
gitcommithash()

def puppetfilecheck
  puppetfile_check = `r10k puppetfile check 2> puppetfile.txt`
  File.readlines('puppetfile.txt').each do |line|
    if line =~ /OK/
      puppetfile_syntax = "pass"
      output = "\"puppetfile_syntax\": " + '"' + puppetfile_syntax + '",'
      puts output
      output = "\"puppetfile_debug\": " + '"N/A"'
      puts output
    end
    if line =~ /error/
      puppetfile_syntax = "fail"
      puppetfile_error = line.split(':')
      puppetfile_error = puppetfile_error[2].strip
      output = "\"puppetfile_syntax\": " + '"' + puppetfile_syntax + '",'
      puts output
      output = "\"puppetfile_debug\": " + '"' + puppetfile_error + '"'
      puts output
    end
  end
end
puppetfilecheck()


    # Public: Create a JSON file on disk
    # The Puppetfile will be called 'Puppetfile' in the current working directory
    def create_json(json_contents)
      File.open('Puppetfile', 'w') do |file|
        file.write json_contents
      end
    end

# Log output to a json file
  def jsonlogger()
    tempHash = {
      "commit_hash" => $commit_hash,
      "commit_author" => $commit_author,
      "r10k_version"  => $r10k_version,
      "number_of_modules" => $number_of_modules,
      "number_of_missing_modules" => $number_of_missing_modules,
      "modules" => $modules,
      "missingmodules" => $missingmodulesoutput
    }
    File.open('test.json',"a") do |f|
      f.puts(tempHash.to_json)
    end
  end
jsonlogger()
