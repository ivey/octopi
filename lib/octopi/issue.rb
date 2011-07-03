module Octopi
  class Issue < V3Class
    class User < V3Class
      property :login
      property :id,            :transformer => SMART_NUMBER_TRANSFORMER
      property :gravatar_url
      property :url
    end
    
    class PullRequest < V3Class
      property :html_url
      property :diff_url
      property :patch_url
    end
    
    attr_accessor :repo
    
    class Comment < V3Class
      property :url
      property :body
      property :user,        :transformer => User
      property :created_at
      property :updated_at
    end
    
    class Label < V3Class
      property :url
      property :name
      property :color
    end
    
    class Milestone < V3Class
      property :url
      property :number,      :transformer => SMART_NUMBER_TRANSFORMER
      property :state
      property :title
      property :description
      property :creator,     :transformer => User
      property :open_issues, :transformer => SMART_NUMBER_TRANSFORMER
      property :closed_issues, :transformer => SMART_NUMBER_TRANSFORMER
      property :created_at
      property :due_on
    end
    
    property :url
    property :html_url
    property :number,        :transformer => SMART_NUMBER_TRANSFORMER
    property :state
    property :title
    property :body
    property :user,          :transformer => User
    property :labels,        :transformer => Label
    property :assignee,      :transformer => User
    property :milestone,     :transformer => Milestone
    property :comments,      :transformer => SMART_NUMBER_TRANSFORMER
    property :pull_request,  :transformer => PullRequest
    property :closed_at
    property :created_at
    property :updated_at
    
    def self.search(options={ })
      raise "No longer available in V3 API. Bug technoweenie about this."
    end
    
    # Finds all issues for a given Repository
    #
    # You can provide the user and repo parameters as
    # String or as User and Repository objects. When repo
    # is provided as a Repository object, user is superfluous.
    # 
    # If no state is given, "open" is assumed.
    #
    # Sample usage:
    #
    #   find_all(repo, :state => "closed") # repo must be an object
    #   find_all("octopi", :user => "fcoury") # user must be provided
    #   find_all(:user => "fcoury", :repo => "octopi") # state defaults to open
    #
    def self.find_all(*args)
      user, repo, rest = extract_repo(*args)
      if rest.is_a?(Hash)
        options = rest
      else
        options = rest.shift || { }
      end
      puts "Hey! GitHub API v3 no longer returns all issues, and defaults state = 'open'" unless options[:state]
      issues = get "/repos/#{user}/#{repo}/issues", :transform => self, :extra_query => options
      issues.each { |i| i.repo = [user,repo] }
      issues
    end

    def self.find(*args)
      user, repo, rest = extract_repo(*args)
      if rest.is_a?(Hash)
        num = rest.delete(:id)
        num ||= rest.delete(:number)
        options = rest
      else
        num = rest.shift
        options = rest.shift || { }
      end
      issue = get "/repos/#{user}/#{repo}/issues/#{num}", :transform => self, :extra_query => options
      issue.repo = [user, repo]
      issue
    end
    
    def self.open(*args)
      user, repo, rest = extract_repo(*args)
      if rest.is_a?(Hash)
        options = rest
      else
        options = rest.shift || { }
      end
      options[:state] ||= "open"
      find_all(user, repo, options)
    end
    
    def edit(options)
      patch "/repos/#{repo[0]}/#{repo[1]}/issues/#{number}", options
    end
    
    def reopen!
      edit :state => 'open'
      self.state = 'open'
    end
    
    def close!
      edit :state => 'closed'
      self.state = 'closed'
    end
    
    def save
      edit :title => title, :body => body, :state => state
      self
    end
    
    def add_label(*new_labels)
      new_labels.each do |label|
        self.labels << Label.new(:name => label)
      end
      edit :labels => labels.collect(&:name) 
    end
    
    def remove_label(*old_labels)
      old_labels.each do |label|
        self.labels.reject! { |l| l.name == label }
      end
      edit :labels => labels.collect(&:name)
    end
    
    def comments
      get "/repos/#{repo[0]}/#{repo[1]}/issues/#{number}/comments", :transform => Comment
    end
    
    def find_comment
      get "/repos/#{repo[0]}/#{repo[1]}/issues/comments/#{number}", :transform => Comment
    end
    
    def comment(comment)
      post "/repos/#{repo[0]}/#{repo[1]}/issues/#{number}/comments", :extra_query => {:comment => comment}, :transform => Comment
    end
    
  end
end
