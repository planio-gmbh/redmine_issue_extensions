# Issue Extensions plugin for Redmine
# Copyright (C) 2010  Takashi Takebayashi
#
# This program is free software; you can redistribute it and/or
# modify it under the terms of the GNU General Public License
# as published by the Free Software Foundation; either version 2
# of the License, or (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program; if not, write to the Free Software
# Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.
require File.dirname(__FILE__) + '/../test_helper'
require 'issues_controller'

# Re-raise errors caught by the controller.
class IssuesController; def rescue_action(e) raise e end; end

class IssuesControllerTest < ActionController::TestCase
  fixtures :projects,
            :users,
            :roles,
            :members,
            :issues,
            :issue_statuses,
            :versions,
            :trackers,
            :projects_trackers,
            :issue_categories,
            :enabled_modules,
            :enumerations,
            :attachments,
            :workflows,
            :custom_fields,
            :custom_values,
            :custom_fields_trackers,
            :time_entries,
            :journals,
            :journal_details,
            :watchers,
            :issue_extensions_status_flows

  def setup
    @controller = IssuesController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
    User.current = nil
    EnabledModule.generate! :project_id => 1, :name => 'issue_extensions'
  end

  test "edit issue_status_assigned" do
    @request.session[:user_id] = 2
    spent_hours_before = Issue.find(1).spent_hours
    assert_difference 'TimeEntry.count' do
      post :edit,
        :id => 1,
        :issue => {:status_id => 1, :assigned_to_id => 3},
        :notes => '5 hours added',
        :time_entry => {:hours => '5', :comments => '', :activity_id => TimeEntryActivity.first}
    end
    assert_redirected_to :action => 'show', :id => '1'

    issue = Issue.find 1

    j = Journal.find :first, :order => 'id DESC'
    assert_equal '5 hours added', j.notes
    assert_equal 1, j.details.size

    t = issue.time_entries.find :first, :order => 'id DESC'
    assert_not_nil t
    assert_equal 5, t.hours
    assert_equal spent_hours_before + 5, issue.spent_hours
  end

  test "bulk edit issue_status_closed" do
    @request.session[:user_id] = 2

    post :bulk_edit,
      :ids => [1,2],
      :issue => {:status_id => 4, :assigned_to_id => 3, :done_ratio => 0},
      :fixed_version_id => 4

    assert_response :redirect
    issues = Issue.find [1,2]
    issues.each do |issue|
#      assert_equal 4, issue.fixed_version_id
      assert_nil issue.fixed_version_id
    end
  end

  test "edit issue_added_watcher" do
    @request.session[:user_id] = 3
    spent_hours_before = Issue.find(1).spent_hours
    assert_difference 'TimeEntry.count' do
      post :edit,
        :id => 1,
        :issue => {:status_id => 1, :assigned_to_id => 3},
        :notes => '2.5 hours added',
        :time_entry => {:hours => '2.5', :comments => '', :activity_id => TimeEntryActivity.first}
    end
    assert_redirected_to :action => 'show', :id => '1'

    issue = Issue.find 1

    j = Journal.find :first, :order => 'id DESC'
    assert_equal '2.5 hours added', j.notes
    assert_equal 1, j.details.size

    t = issue.time_entries.find :first, :order => 'id DESC'
    assert_not_nil t
    assert_equal 2.5, t.hours
    assert_equal spent_hours_before + 2.5, issue.spent_hours
  end

  test "issue_added_relation success" do
    @request.session[:user_id] = 1
    get :new, :project_id => 1, :relation_issue => 1
    assert_response :success
    post :new, :project_id => 1,
      :issue => {:tracker_id => 1, :status_id => 1, :subject => 'test issue001'},
      :relation_issue_id => 1
#    assert_response :redirect
    assert_response 200
  end

  test "issue_added_relation skip because invalid issue id" do
    @request.session[:user_id] = 1
    get :new, :project_id => 1, :relation_issue => 100
    assert_response :success
    post :new, :project_id => 1,
      :issue => {:tracker_id => 1, :status_id => 1, :subject => 'test issue002'},
      :relation_issue_id => 100
#    assert_response :redirect
    assert_response 200
  end

  test "view_issues_show_description_bottom" do
    @request.session[:user_id] = 1
    issue = Issue.find 1
    get :show, :id => issue.id
  end
end
