#!/usr/bin/env ruby

require 'net/http'
require 'json'
require 'uri'

class GitHubUserActivity
  API_BASE_URL = 'https://api.github.com'
  
  def initialize
    @events = []
  end
  
  def fetch_user_events(username)
    uri = URI("#{API_BASE_URL}/users/#{username}/events")
    
    begin
      response = Net::HTTP.get_response(uri)
      
      case response.code
      when '200'
        @events = JSON.parse(response.body)
        format_and_display_events
      when '404'
        puts "Error: User '#{username}' not found."
      when '403'
        puts "Error: API rate limit exceeded. Please try again later."
      else
        puts "Error: Unable to fetch data (HTTP #{response.code})"
      end
    rescue StandardError => e
      puts "Error: #{e.message}"
    end
  end
  
  private
  
  def format_and_display_events
    if @events.empty?
      puts "No recent activity found for this user."
      return
    end
    
    puts "Recent GitHub Activity:"
    puts "-" * 40
    
    @events.each do |event|
      message = format_event(event)
      puts "- #{message}" if message
    end
  end
  
  def format_event(event)
    type = event['type']
    repo = event['repo']['name']
    
    case type
    when 'PushEvent'
      commit_count = event['payload']['commits'].size
      "Pushed #{commit_count} commit#{'s' if commit_count != 1} to #{repo}"
    
    when 'IssuesEvent'
      action = event['payload']['action']
      issue_title = event['payload']['issue']['title']
      case action
      when 'opened'
        "Opened a new issue in #{repo}: \"#{truncate_text(issue_title)}\""
      when 'closed'
        "Closed an issue in #{repo}: \"#{truncate_text(issue_title)}\""
      when 'reopened'
        "Reopened an issue in #{repo}: \"#{truncate_text(issue_title)}\""
      else
        "#{action.capitalize} an issue in #{repo}"
      end
    
    when 'WatchEvent'
      "Starred #{repo}"
    
    when 'ForkEvent'
      "Forked #{repo}"
    
    when 'CreateEvent'
      ref_type = event['payload']['ref_type']
      case ref_type
      when 'repository'
        "Created repository #{repo}"
      when 'branch'
        branch_name = event['payload']['ref']
        "Created branch '#{branch_name}' in #{repo}"
      when 'tag'
        tag_name = event['payload']['ref']
        "Created tag '#{tag_name}' in #{repo}"
      else
        "Created #{ref_type} in #{repo}"
      end
    
    when 'DeleteEvent'
      ref_type = event['payload']['ref_type']
      ref_name = event['payload']['ref']
      "Deleted #{ref_type} '#{ref_name}' in #{repo}"
    
    when 'PullRequestEvent'
      action = event['payload']['action']
      pr_title = event['payload']['pull_request']['title']
      case action
      when 'opened'
        "Opened a new pull request in #{repo}: \"#{truncate_text(pr_title)}\""
      when 'closed'
        merged = event['payload']['pull_request']['merged']
        if merged
          "Merged a pull request in #{repo}: \"#{truncate_text(pr_title)}\""
        else
          "Closed a pull request in #{repo}: \"#{truncate_text(pr_title)}\""
        end
      when 'reopened'
        "Reopened a pull request in #{repo}: \"#{truncate_text(pr_title)}\""
      else
        "#{action.capitalize} a pull request in #{repo}"
      end
    
    when 'ReleaseEvent'
      action = event['payload']['action']
      release_name = event['payload']['release']['name'] || event['payload']['release']['tag_name']
      "#{action.capitalize} release '#{release_name}' in #{repo}"
    
    when 'IssueCommentEvent'
      "Commented on an issue in #{repo}"
    
    when 'PullRequestReviewEvent'
      action = event['payload']['action']
      "#{action.capitalize} a pull request review in #{repo}"
    
    when 'MemberEvent'
      action = event['payload']['action']
      member = event['payload']['member']['login']
      "#{action.capitalize} #{member} as a collaborator to #{repo}"
    
    else
      # For unknown event types, show a generic message
      "Performed #{type.gsub('Event', '').downcase} action in #{repo}"
    end
  end
  
  def truncate_text(text, max_length = 50)
    return text if text.length <= max_length
    "#{text[0...max_length]}..."
  end
end

# Main execution
if __FILE__ == $0
  if ARGV.empty?
    puts "Usage: ruby main.rb <username>"
    puts "Example: ruby main.rb octocat"
    exit 1
  end
  
  username = ARGV[0]
  activity_tracker = GitHubUserActivity.new
  activity_tracker.fetch_user_events(username)
end
