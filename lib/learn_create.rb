require 'json'
require 'require_all'
require 'odyssey'
require 'awesome_print'
require 'faraday'
require 'uri'
require 'byebug'

class LearnCreate
  def initialize
    puts 'Note: You must have write access to the learn-co-curriculum org on GitHub to use this tool'

    # Checks to see if chosen name already exists as a repository
    @repo_name = ''

    loop do
      puts 'What is the name of the repository you would like to create?'
      @repo_name = gets.chomp
      url = 'https://api.github.com/repos/learn-co-curriculum/' + @repo_name
      encoded_url = URI.encode(url).slice(0, url.length)

      # Will hit rate limint on github is used too much
      check_existing = Faraday.get URI.parse(encoded_url)
      puts URI.parse(encoded_url)
      puts check_existing.body
      break if check_existing.body.include? '"Not Found"'

      puts 'A repository with that name already exists:'
      puts 'https://github.com/learn-co-curriculum/' + @repo_name
      puts ''
    end

    readme = ''
    loop do
      puts 'Is this a Readme? (Y/n)'
      readme = gets.chomp.downcase
      break if readme =~ /^(y|n)/
      puts 'Please enter yes or no'
      puts ''
    end

    # If not a readme, create language specific lab, otherwise create a standard readme
    if readme =~ /^n$/

      language = choose_language

      case language
      when /^ru/
        create_local_lesson('lab', 'Ruby')

      when /^j/
        create_local_lesson('lab', 'JavaScript')

      when /^re/
        create_local_lesson('lab', 'React')

      else
        puts 'I am sorry, something went wrong, please start over'

      end

    else

      create_local_lesson('readme')

    end

    cd_into
    create_new_repo
  end

  private

  def choose_language
    language = ''
    loop do
      puts 'What lab template would you like to use? (Ruby/JavaScript/React)'
      language = gets.chomp.downcase
      break if language =~ /^(ru|j|re)/
      puts 'Please enter Ruby, JavaScript or React, or at minimum, the first two letters:'
      puts ''
    end
    language
  end

  def create_local_lesson(type = 'readme', language)
    puts "Creating #{language} #{type}"
    gem_template_location = File.dirname(__FILE__)
    template_folder = "/templates/#{type}_template"
    template_folder = "/templates/#{language}_#{type}_template" if ARGV.length == 2
    gem_template_path = File.expand_path(template_file) + template_folder
    copy_template(gem_template_path)
  end

  def create_ruby_lab
    puts 'Creating Ruby Lab...'
    template_file = File.dirname(__FILE__)
    gem_template_path = File.expand_path(template_file) + '/templates/readme_template'
  end

  # shell commands turned into methods
  def copy_template(gem_template_path)
    cmd = "cp -r #{gem_template_path} #{Dir.pwd}/#{@repo_name}"
    `#{cmd}`
  end

  def cd_into
    cmd = "cd #{repo_name}"
    `#{cmd}`
  end

  def git_int
    cmd = 'git init'
    `#{cmd}`
  end

  def git_add
    cmd = 'git add .'
    `#{cmd}`
  end

  def git_commit
    cmd = 'git commit -m "automated initial commit"'
    `#{cmd}`
  end

  def git_create
    cmd = "hub create learn-co-curriculum/#{@repo_name}"
    `#{cmd}`
  end

  def git_set_remote
    cmd = "git remote set-url origin https://github.com/learn-co-curriculum/#{@repo_name}"
    `#{cmd}`
  end

  def git_push
    cmd = 'git push -u origin master'
    `#{cmd}`
  end

  def create_new_repo
    git_init
    git_add
    git_commit
    git_create
    git_set_remote
    git_push
  end
end
