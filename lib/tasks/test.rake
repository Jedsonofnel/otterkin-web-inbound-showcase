namespace :test do
  desc "Run tests that call the Gemini API for prompt evaluation"
  task :prompts do
    prompt_test_dir = File.expand_path("../../test/prompts", __dir__)
    test_files = Dir.glob("#{prompt_test_dir}/**/*_prompt.rb")

    if test_files.empty?
      puts "No prompt tests found in #{prompt_test_dir}"
      exit 0
    end

    puts "\nRunning API-calling prompt tests from #{prompt_test_dir}..."
    system("ruby -Itest #{test_files.join(' ')}")

    unless $?.success?
      raise "API-calling prompt tests failed!"
    end
  end
end
