task :default => "rcov"

desc "Test All Test files"
task "rcov" do
  here = File.dirname(__FILE__)
  railshome = File.join(here, '../../..')
  system("rcov", "-I", File.join(railshome, 'lib'), 'test/*/*test.rb', '-x', 'redmine')
  $?
end