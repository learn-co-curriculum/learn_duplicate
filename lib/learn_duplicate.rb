require 'faraday'
require 'uri'
require 'open3'

class LearnDuplicate
  def initialize(opts={})
    # For non-interactive mode
    if opts[:ni]
      puts :inside
    end

    @repo_name = ''
    @old_repo = ''
    @ssh_configured = check_ssh_config

    puts 'Note: You must have write access to the learn-co-curriculum org on GitHub to use this tool'

    loop do
      puts 'What is the name of the repository you would like to copy? Paste exactly as is shown in the URL (i.e. advanced-hashes-hashketball)'
      @old_repo = gets.strip

      url = 'https://api.github.com/repos/learn-co-curriculum/' + @old_repo
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
        url = 'https://api.github.com/repos/learn-co-curriculum/' + @repo_name
        encoded_url = URI.encode(url).slice(0, url.length)
        check_existing = Faraday.get URI.parse(encoded_url)


        if check_existing.body.include? '"Not Found"'
          break
        else
          puts 'A repository with that name already exists or you may have hit a rate limit'
          puts 'https://github.com/learn-co-curriculum/' + @repo_name
          puts ''
        end
      end
    end

    create_new_repo
    puts ''
    puts 'To access local folder, change directory into ' + @repo_name + '/'
    puts 'Repository available at https://github.com/learn-co-curriculum/' + @repo_name
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
    `#{cmd}`
  end

  def git_create
    cmd = cd_into_and("hub create learn-co-curriculum/#{@repo_name}")
    `#{cmd}`
  end

  def git_set_remote
    remote = @ssh_configured ? "git@github.com:learn-co-curriculum/#{@repo_name}.git" : "https://github.com/learn-co-curriculum/#{@repo_name}"
    cmd = cd_into_and("git remote set-url origin #{remote}")
    `#{cmd}`
  end

  def git_push
    cmd = cd_into_and('git push -u origin master')
    `#{cmd}`
  end

  def check_ssh_config
    result = Open3.capture2e('ssh -T git@github.com').first
    result.include?("You've successfully authenticated")
  end

  def create_new_repo
    # 'cd' doesn't work the way it would in the shell, must be used before every command
    puts 'Cloning old repository'
    git_clone
    puts 'Renaming old repository with new name'
    rename_repo
    puts ''
    puts 'Creating new remote learn-co-curriculum repository'
    git_create
    puts ''
    puts 'Setting new git remote'
    git_set_remote
    puts ''
    puts 'Pushing to new remote'
    git_push
  end
end
