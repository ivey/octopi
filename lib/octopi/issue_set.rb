require File.join(File.dirname(__FILE__), "issue")
class Octopi::IssueSet < Array
  include Octopi
  attr_accessor :user, :repository
  
  def initialize(array)
    self.user = array.first.repo[0]
    self.repository = array.first.repo[1]
    super(array)
  end
  
  def find(number)
    issue = detect { |issue| issue.number == number }
    raise NotFound, Issue if issue.nil?
    issue
  end
  
  def search(options={})
    Issue.search(options.merge(:user => user, :repo => repository))
  end
end
