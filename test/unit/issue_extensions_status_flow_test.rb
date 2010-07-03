require File.dirname(__FILE__) + '/../test_helper'

class IssueExtensionsStatusFlowTest < ActiveSupport::TestCase
  fixtures :issue_extensions_status_flows

  def test_is_issue_extensions_status_flows_should_return_nil
    assert_nil IssueExtensionsStatusFlow.find :first
  end

  def test_find_or_create
    assert(IssueExtensionsStatusFlow.find(:first, :conditions => 'project_id = 5'))
    status_flow = IssueExtensionsStatusFlow.find_or_create(5, 1)
    assert_equal(5, status_flow.project_id)
    assert(IssueExtensionsStatusFlow.find(:first, :conditions => 'project_id = 5'))
    status_flow = IssueExtensionsStatusFlow.find_or_create(5, 1)
    assert_equal(5, status_flow.project_id)
  end
end
