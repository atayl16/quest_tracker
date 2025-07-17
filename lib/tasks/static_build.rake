namespace :static_build do
  desc "Validate static build for JavaScript syntax errors and deployment readiness"
  task validate: :environment do
    puts "🔍 Validating static build..."

    # Build the static version
    puts "📦 Building static version..."
    unless system("bin/build-static")
      puts "❌ Static build failed!"
      exit 1
    end

    # Check that required files exist
    puts "📁 Checking required files..."
    required_files = [
      "public/static-build/index.html",
      "public/static-build/tailwind.css",
      "public/static-build/local_storage_service.js"
    ]

    required_files.each do |file|
      unless File.exist?(file)
        puts "❌ Missing required file: #{file}"
        exit 1
      end
    end

    # Validate HTML structure
    puts "🔍 Validating HTML structure..."
    html_content = File.read("public/static-build/index.html")

    # Check for basic HTML structure
    unless html_content.include?("<!DOCTYPE html>")
      puts "❌ Missing DOCTYPE declaration"
      exit 1
    end

    unless html_content.include?("<html>") && html_content.include?("</html>")
      puts "❌ Invalid HTML structure"
      exit 1
    end

    # Validate JavaScript syntax
    puts "🔍 Validating JavaScript syntax..."

    # Extract JavaScript content from script tags
    script_matches = html_content.scan(/<script[^>]*>(.*?)<\/script>/m)
    javascript_content = script_matches.map(&:first).join("\n")

    # Check for balanced braces and parentheses
    if javascript_content.count("{") != javascript_content.count("}")
      puts "❌ Unbalanced braces in JavaScript"
      exit 1
    end

    if javascript_content.count("(") != javascript_content.count(")")
      puts "❌ Unbalanced parentheses in JavaScript"
      exit 1
    end

    if javascript_content.count("[") != javascript_content.count("]")
      puts "❌ Unbalanced brackets in JavaScript"
      exit 1
    end

    # Check for proper string quotes
    if javascript_content.count("'").odd?
      puts "❌ Unbalanced single quotes in JavaScript"
      exit 1
    end

    if javascript_content.count('"').odd?
      puts "❌ Unbalanced double quotes in JavaScript"
      exit 1
    end

    # Check for proper template literal backticks
    backticks = javascript_content.count("`")
    if backticks.odd?
      puts "❌ Unbalanced backticks in JavaScript"
      exit 1
    end

    # Check for the specific issue we just fixed (malformed template literals)
    if html_content.include?("`;") || html_content.include?("`;`")
      puts "❌ Detected malformed template literal syntax"
      exit 1
    end

    # Check for required JavaScript functions
    puts "🔍 Checking required JavaScript functions..."
    required_functions = [
      "function showNewHabitForm()",
      "function loadHabits()",
      "function checkInHabit(",
      "function deleteHabit("
    ]

    required_functions.each do |func|
      unless html_content.include?(func)
        puts "❌ Missing required function: #{func}"
        exit 1
      end
    end

    # Check for proper error handling
    unless html_content.include?("catch") && html_content.include?("error")
      puts "⚠️  Warning: Missing error handling in JavaScript"
    end

    # Validate CSS inclusion
    puts "🎨 Validating CSS inclusion..."
    unless html_content.include?("tailwind.css")
      puts "❌ Missing Tailwind CSS"
      exit 1
    end

    # Check for responsive design classes
    unless html_content.include?("sm:") || html_content.include?("md:")
      puts "⚠️  Warning: Missing responsive design classes"
    end

    # Test HTTP server functionality
    puts "🌐 Testing HTTP server functionality..."
    require "net/http"
    require "uri"

    # Use a simple HTTP server to test the static build
    pid = Process.spawn("cd public/static-build && python3 -m http.server 8004")
    sleep 2 # Give the server time to start

    begin
      uri = URI("http://localhost:8004")
      response = Net::HTTP.get_response(uri)

      unless response.code == "200"
        puts "❌ HTTP server test failed: #{response.code}"
        exit 1
      end

      unless response.body.include?("Quest Tracker")
        puts "❌ Missing expected content in HTTP response"
        exit 1
      end

    rescue => e
      puts "❌ HTTP server test failed: #{e.message}"
      exit 1
    ensure
      # Clean up the server
      Process.kill("TERM", pid)
      Process.wait(pid)
    end

    puts "✅ Static build validation passed!"
    puts "📊 Build size: #{Dir.glob('public/static-build/**/*').length} files"
    puts "📏 HTML size: #{File.size('public/static-build/index.html')} bytes"
  end

  desc "Clean static build directory"
  task clean: :environment do
    puts "🧹 Cleaning static build directory..."
    if Dir.exist?("public/static-build")
      FileUtils.rm_rf("public/static-build")
      puts "✅ Static build directory cleaned"
    else
      puts "ℹ️  Static build directory doesn't exist"
    end
  end

  desc "Build and validate static build"
  task build_and_validate: [ :clean, :validate ] do
    puts "🎉 Static build completed and validated successfully!"
  end
end
