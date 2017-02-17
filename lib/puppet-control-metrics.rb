#!/usr/bin/env ruby

# Outer JSON bracket
puts "{"

file='Puppetfile'

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

ary = []
File.readlines(file).each do |line|
  if line =~ /mod /
    test = line.split(' ')
    test = test[1]
    test = test.chomp(',')
    test = test.gsub(/'/,'')
    if test =~ /\//
      test = test.split('/')
      test = test[1]
    end
    ary.push(test)
  end
end
modules = ary.sort.join('","')
output = "\"modules\": [" + '"' + modules + '"' + '],'
puts output

# modules
missingmodulesarray = []
missingmodulesarray = `ls modules/`.split("\n")
missingmodulesarray = missingmodulesarray.sort

missingmodules = ary - missingmodulesarray
missingmodulesoutput = missingmodules.join('","')
output = "\"missingmodules\": [ " + '"' + missingmodulesoutput + '"' + "],"
puts output

# r10k version
r10k_version = `r10k version`
r10k_version = r10k_version.split(' ')
r10k_version = r10k_version[1]
output = "\"r10k_version\": " + '"' + r10k_version + '",'
puts output


# Number of Puppet Modules
number_of_modules = ary.count()
output = "\"number_of_modules\": " + '"' + number_of_modules.to_s + '",'
puts output

# Number of Puppet Modules
number_of_missing_modules = missingmodules.count()
output = "\"number_of_missing_modules\": " + '"' + number_of_missing_modules.to_s + '",'
puts output

# Get Control Repo Name
control_repo = `git config --get remote.origin.url`
control_repo = control_repo.split('/')
control_repo = control_repo[-1].to_s.chomp.split('.')
control_repo = control_repo[0]
output = "\"control_repo\": " + '"' + control_repo + '",'
puts output

# Get Commit Author
commit_author = `git show -s --format=%aN`
commit_author = commit_author.to_s.strip
output = "\"commit_author\": " + '"' + commit_author + '",'
puts output

# Get commit hash
commit_hash = `git log --pretty=oneline --abbrev-commit -n 1`
commit_hash = commit_hash.split()
commit_hash = commit_hash[0]
output = "\"commit_hash\": " + '"' + commit_hash + '",'
puts output


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

# Outer JSON bracket
puts "}"
