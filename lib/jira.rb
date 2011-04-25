require 'rubygems'
require 'jira4r/jira4r'

class Jira
  SERVER = EstimotionConfig.jira.server
  USERNAME = EstimotionConfig.jira.user
  PASSWORD = EstimotionConfig.jira.password
  RESULTS_LIMIT = EstimotionConfig.jira.result_limit

  # Soap:
  #   http://docs.atlassian.com/software/jira/docs/api/rpc-jira-plugin/latest/index.html?com/atlassian/jira/rpc/soap/JiraSoapService.html
  #
  def self.get_issues(jql)
    issues = []

    begin 
      jira = Jira4R::JiraTool.new(2, SERVER)
      jira.login(USERNAME, PASSWORD)

      jira.getIssuesFromJqlSearch(jql, RESULTS_LIMIT).collect do |issue|
        issues << issue
      end
    rescue => e
      puts e.message
    end

    issues
  end
end
