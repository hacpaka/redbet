namespace :test do
	desc 'Measures test coverage'
	task :coverage do
		rm_f "coverage"
		ENV["COVERAGE"] = "1"
		Rake::Task["test"].invoke
	end

	task(:routing) do |t|
		$: << "test"
		Rails::TestUnit::Runner.rake_run FileList['test/integration/routing/*_test.rb'] + FileList['test/integration/api_test/*_routing_test.rb']
	end
	Rake::Task['test:routing'].comment = "Run the routing tests"
end
