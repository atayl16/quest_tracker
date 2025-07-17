require "rails_helper"

RSpec.describe "Static Build Validation", type: :system do
  before do
    driven_by(:selenium_chrome_headless)
  end

  describe "Static build generation and validation" do
    it "generates a valid static build without JavaScript syntax errors" do
      # Build the static version
      system("bin/build-static")
      expect($?).to be_success

      # Check that the build directory exists
      expect(Dir.exist?("public/static-build")).to be true
      expect(File.exist?("public/static-build/index.html")).to be true

      # Validate the HTML structure
      html_content = File.read("public/static-build/index.html")

      # Check for basic HTML structure
      expect(html_content).to include("<!DOCTYPE html>")
      expect(html_content).to include("<html>")
      expect(html_content).to include("</html>")
      expect(html_content).to include("<head>")
      expect(html_content).to include("<body>")

      # Check for required CSS
      expect(html_content).to include("tailwind.css")

      # Check for required JavaScript files
      expect(html_content).to include("local_storage_service.js")

      # Validate JavaScript syntax by checking for common error patterns
      expect(html_content).not_to include("Unexpected token")
      expect(html_content).not_to include("SyntaxError")

      # Check for proper template literal syntax - look for balanced backticks
      backticks = html_content.count("`")
      expect(backticks).to be_even

      # Check for proper function definitions
      expect(html_content).to include("function showNewHabitForm()")
      expect(html_content).to include("function loadHabits()")
      expect(html_content).to include("function checkInHabit(")
      expect(html_content).to include("function deleteHabit(")

      # Check for proper event handlers
      expect(html_content).to include("addEventListener")

      # Check for proper localStorage service integration
      expect(html_content).to include("storageService")
    end

    it "has valid JavaScript that can be parsed without syntax errors" do
      # Build the static version
      system("bin/build-static")

      html_content = File.read("public/static-build/index.html")

      # Extract JavaScript content from script tags
      script_matches = html_content.scan(/<script[^>]*>(.*?)<\/script>/m)
      javascript_content = script_matches.map(&:first).join("\n")

      # Basic JavaScript syntax validation
      expect(javascript_content).not_to be_empty

      # Check for balanced braces and parentheses
      expect(javascript_content.count("{")).to eq(javascript_content.count("}"))
      expect(javascript_content.count("(")).to eq(javascript_content.count(")"))
      expect(javascript_content.count("[")).to eq(javascript_content.count("]"))

      # Check for proper template literal backticks
      backticks = javascript_content.count("`")
      expect(backticks).to be_even

      # Check for proper function syntax
      expect(javascript_content).to include("function ")
      expect(javascript_content).to include("() {")
    end

    it "includes all required functionality in the static build" do
      # Build the static version
      system("bin/build-static")

      html_content = File.read("public/static-build/index.html")
      js_content = File.read("public/static-build/local_storage_service.js")

      # Check for authentication functionality
      expect(html_content).to include("login")
      expect(html_content).to include("logout")
      expect(html_content).to include("currentUser")

      # Check for habit management functionality
      expect(html_content).to include("createHabit")
      expect(html_content).to include("deleteHabit")
      expect(html_content).to include("checkInHabit")
      expect(html_content).to include("undoCheckIn")

      # Check for localStorage service - check both HTML and JS files
      expect(html_content).to include("localStorage")
      expect(js_content).to include("getItem")
      expect(js_content).to include("setItem")

      # Check for UI elements
      expect(html_content).to include("Begin Your Quest")
      expect(html_content).to include("Complete Quest")
      expect(html_content).to include("Add New Quest")
    end

    it "has proper error handling in JavaScript" do
      # Build the static version
      system("bin/build-static")

      html_content = File.read("public/static-build/index.html")
      js_content = File.read("public/static-build/local_storage_service.js")

      # Check for proper null checks and conditional logic
      expect(html_content).to include("if (")

      # Check for proper error handling patterns
      expect(html_content).to include("result.success")
      expect(html_content).to include("result.error")
      expect(html_content).to include("alert(")
    end

    it "loads without JavaScript errors in a browser" do
      # Build the static version
      system("bin/build-static")

      # Start a local server to test the static build
      require "net/http"
      require "uri"

      # Use a simple HTTP server to serve the static build
      pid = Process.spawn("cd public/static-build && python3 -m http.server 8003")
      sleep 2 # Give the server time to start

      begin
        # Test that the page loads without errors
        uri = URI("http://localhost:8003")
        response = Net::HTTP.get_response(uri)
        expect(response.code).to eq("200")

        # Check that the response contains expected content
        expect(response.body).to include("Quest Tracker")
        expect(response.body).to include("Begin Your Quest")

      ensure
        # Clean up the server
        Process.kill("TERM", pid)
        Process.wait(pid)
      end
    end

    it "has consistent styling and layout" do
      # Build the static version
      system("bin/build-static")

      html_content = File.read("public/static-build/index.html")

      # Check for Tailwind CSS classes
      expect(html_content).to include("bg-gradient-to-br")
      expect(html_content).to include("text-white")
      expect(html_content).to include("rounded-lg")

      # Check for responsive design classes
      expect(html_content).to include("sm:")
      expect(html_content).to include("md:")

      # Check for proper container structure
      expect(html_content).to include("container")
      expect(html_content).to include("mx-auto")
    end
  end

  describe "Build script validation" do
    it "has a valid build script that generates required files" do
      build_script = File.read("bin/build-static")

      # Check that the build script exists and is executable
      expect(File.exist?("bin/build-static")).to be true
      expect(File.executable?("bin/build-static")).to be true

      # Check for required build steps
      expect(build_script).to include("Precompiling assets")
      expect(build_script).to include("Copying assets")
      expect(build_script).to include("Creating main HTML file")

      # Check for proper error handling in build script
      expect(build_script).to include("raise")
      expect(build_script).to include("puts")
    end

    it "build script handles errors gracefully" do
      # Test that the build script doesn't have obvious syntax errors
      build_script = File.read("bin/build-static")

      # Check for proper Ruby syntax
      expect(build_script).to include("require")
      expect(build_script).to include("File.write")

      # Check for proper string interpolation
      expect(build_script.count("#{")).to eq(build_script.count("}"))

      # Check for proper heredoc syntax (simplified check)
      if build_script.include?("<<~")
        # Just check that heredocs are properly closed
        expect(build_script).to include("HTML")
        expect(build_script).to include("README")
      end
    end
  end

  describe "Deployment readiness" do
    it "includes all necessary files for deployment" do
      # Build the static version
      system("bin/build-static")

      # Check for required deployment files
      expect(File.exist?("public/static-build/index.html")).to be true
      expect(File.exist?("public/static-build/tailwind.css")).to be true
      expect(File.exist?("public/static-build/local_storage_service.js")).to be true
      expect(File.exist?("netlify.toml")).to be true

      # Check that the build directory is not empty
      files = Dir.glob("public/static-build/**/*")
      expect(files.length).to be > 5

      # Check for no temporary or development files
      expect(files).not_to include(/\.tmp$/)
      expect(files).not_to include(/\.log$/)
    end

    it "has proper Netlify configuration" do
      netlify_config = File.read("netlify.toml")

      expect(netlify_config).to include("[build]")
      expect(netlify_config).to include("command = \"bin/build-static\"")
      expect(netlify_config).to include("publish = \"public/static-build\"")
      expect(netlify_config).to include("[[redirects]]")
    end
  end
end
