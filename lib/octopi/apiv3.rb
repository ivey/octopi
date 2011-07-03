require 'api_smith'

module Octopi
  SMART_NUMBER_TRANSFORMER = lambda { |v| v =~ /^\d+$/ ? Integer(v) : v }

  class ApiV3
    include APISmith::Client
    base_uri 'https://api.github.com'
    
    @auth = { }
    class << self
      attr_accessor :auth

      def login
        @auth[:login]
      end

      def password
        @auth[:password]
      end

      def client
        @client ||= new
      end

      def patch(path, options={})
        perform_request Net::HTTP::Patch, path, options
      end
    end

    def patch(path, options = {})
      request! :patch, path, options, :query, :body
    end

    private
    def base_request_options
      if ApiV3.login
        puts "HEY! GitHub API v3 requests no longer use token auth. You'll need to pass in a password." unless ApiV3.password
        {:basic_auth => {:username => ApiV3.login, :password => ApiV3.password}}
      else
        { }
      end
    end

  end

  class V3Class < APISmith::Smash
    class Repository ;  end

    def get(*args)
      self.class.get(*args)
    end
    
    def post(path, options={})
      self.class.post(path, options)
    end
    
    def patch(*args)
      self.class.patch(*args)
    end
    
    class << self
      def get(*args)
        ApiV3.client.get(*args)
      end
      
      def post(path, options={})
        ApiV3.client.post(path, options)
      end
      
      def patch(path, options={})
        ApiV3.client.patch(path, options)
      end
      
      def extract_repo(*args)
        if args[0].is_a?(Repository)
          repo = args.shift
        [repo.owner.login, repo.name, args]
        elsif args[0].is_a?(Hash)
          h = args[0]
          repo = h.delete(:repository)
          repo ||= h.delete(:repo)
          repo ||= h.delete(:name)
          user = h.delete(:user)
          [user, repo, h]
        else
          user = args.shift
          repo = args.shift
          [user, repo, args]
        end
      end
    end
  end
end
