require 'faraday'
require 'uri'
require 'open3'

class LearnDuplicate
  GITHUB_ORG = 'https://api.github.com/repos/learn-co-curriculum/'

  def initialize(opts={})
    # For non-interactive mode
    if opts[:ni]
      validate_repo = ->(repo_name) do
        url = GITHUB_ORG + repo_name
        encoded_url = URI.encode(url).slice(0, url.length)
        check_existing = Faraday.get URI.parse(encoded_url)
        if check_existing.body.include? '"Not Found"'
          raise IOError, "Could not connect to #{url}"
        end
        repo_name
      end

      de_apiify_url = ->(api_url) do
        api_url.gsub(/(api\.|repos\/)/, '')
      end

      @old_repo = validate_repo.call(opts[:source_name])

      if opts[:destination].length >= 100
        raise ArgumentError, 'Repository names must be shorter than 100 characters'
      end

      @repo_name = opts[:destination]

      if (!opts[:dryrun])
        begin
          create_new_repo
          puts ''
          puts 'To access local folder, change directory into ' + @repo_name + '/'
          puts "Repository available at #{de_apiify_url.call(GITHUB_ORG + @repo_name)}"
        rescue => e
          STDERR.puts(e.message)
        end
      else
        puts "DRY RUN: Would execute copy of: #{de_apiify_url.call(@old_repo)} to #{@repo_name}"
      end

      exit
    end

    @repo_name = ''
    @old_repo = ''

    puts 'Note: You must have write access to the learn-co-curriculum org on GitHub to use this tool'

    loop do
      puts 'What is the name of the repository you would like to copy? Paste exactly as is shown in the URL (i.e. advanced-hashes-hashketball)'
      @old_repo = gets.strip

      url = GITHUB_ORG + @old_repo
      encoded_url = URI.encode(url).slice(0, url.length)
      check_existing = Faraday.get URI.parse(encoded_url)

      # careful - will hit rate limit on GitHub if abused
      if check_existing.body.include? '"Not Found"'
        puts 'Provided repository name is not a valid learn-co-curriculum repository. Please try again.'
      else
        break
      end
    end

    loop do
      puts ''
      puts 'Old repository: ' + @old_repo
      puts 'What is the name of the repository you would like to create?'

      @repo_name = gets.strip.gsub(/\s+/, '-').downcase
      if @repo_name.length >= 100
        puts 'Repository names must be shorter than 100 characters'
      else
        url = GITHUB_ORG + @repo_name
        encoded_url = URI.encode(url).slice(0, url.length)
        check_existing = Faraday.get URI.parse(encoded_url)


        if check_existing.body.include? '"Not Found"'
          break
        else
          puts 'A repository with that name already exists or you may have hit a rate limit'
          puts GITHUB_ORG + @repo_name
          puts ''
        end
      end
    end

    create_new_repo
    puts ''
    puts 'To access local folder, change directory into ' + @repo_name + '/'
    puts "Repository available at #{GITHUB_ORG}" + @repo_name
  end

  private


  def create_local_lesson(type = 'readme', language = nil)
    if !language
      puts "Creating #{type}..."
      template_folder = "/templates/#{type}_template"
    else
      puts "Creating #{language} #{type}..."
      template_folder = "/templates/#{language}_#{type}_template"
    end

    gem_template_location = File.dirname(__FILE__)
    template_path = File.expand_path(gem_template_location) + template_folder

    copy_template(template_path)
    create_dot_learn_file(type, language)
    create_dot_gitignore_file()
  end


  def cd_into_and(command)
    "cd #{@repo_name} && #{command}"
  end

  def git_clone
    cmd = "git clone https://github.com/learn-co-curriculum/#{@old_repo}"
    `#{cmd}`
  end

  def rename_repo
    cmd = "mv -f #{@old_repo} #{@repo_name}"
    cd_into_and("git remote rename origin origin-old")
    `#{cmd}`
  end

  def git_create_and_set_new_origin
    # Creates repo **and** assigns new remote to 'origin' shortname
    cmd = cd_into_and("hub create learn-co-curriculum/#{@repo_name}")
    `#{cmd}`
  end

  def git_set_remote
    remote = check_ssh_config ? "git@github.com:learn-co-curriculum/#{@repo_name}.git" : "https://github.com/learn-co-curriculum/#{@repo_name}"
    cmd = cd_into_and("git remote set-url origin #{remote}")
    `#{cmd}`
  end

  def git_push
    # Copy `master`, attempt to copy `solution`, but if it's not there, no
    # complaints
    cmds = [
      %q|git push origin 'refs/remotes/origin/master:refs/heads/master' > /dev/null 2>&1|,
      %q|git push origin 'refs/remotes/origin/solution:refs/heads/solution' > /dev/null 2>&1|
    ]
    cmds.each { |cmd| `#{cd_into_and(cmd)}` }
  end

  def check_ssh_config
    result = Open3.capture2e('ssh -T git@github.com').first
    result.include?("You've successfully authenticated")
  end

  def create_new_repo
    # 'cd' doesn't work the way it would in the shell, must be used before every command
    puts 'Cloning old repository'
    git_clone
    puts "Renaming old directory with new name: #{@repo_name}"
    rename_repo
    puts ''
    puts 'Creating new remote learn-co-curriculum repository'
    git_create_and_set_new_origin
    puts ''
    puts 'Setting new git remote based on SSH settings'
    git_set_remote
    puts ''
    puts 'Pushing all old-remote branches to new remote'
    git_push
  end
end
