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
            :member_roles,
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
            :custom_fields_projects,
            :custom_fields_trackers,
            :time_entries,
            :journals,
            :journal_details,
            :queries

  def setup
    @controller = IssuesController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
    EnabledModule.generate! :project_id => 1, :name => 'issue_extensions'
    @request.session[:user_id] = 2
  end

  context "#create" do
    should "accept post with relation issue" do
      assert_difference 'Issue.count' do
        post :create, :project_id => 1,
          :issue => {:tracker_id => 3,
                     :status_id => 2,
                     :subject => 'This is the test_new issue',
                     :description => 'This is the description',
                     :priority_id => 5,
                     :estimated_hours => ''}
      end
      assert_difference 'Issue.count' do
        post :create, :project_id => 1,
          :relation_issue_id => Issue.last.id,
          :issue => {:tracker_id => 3,
                     :status_id => 2,
                     :subject => 'This is the test relation issue',
                     :description => 'This is the description',
                     :priority_id => 5,
                     :estimated_hours => ''}
      end
      assert_redirected_to :controller => 'issues', :action => 'show', :id => Issue.last.id
      issue_relation = IssueRelation.find IssueRelation.last.id
      assert_not_nil issue_relation
      assert_equal issue_relation.relation_type, IssueRelation::TYPE_RELATES
      assert_equal Issue.last.id - 1, issue_relation.issue_from_id
      assert_equal Issue.last.id, issue_relation.issue_to_id
    end
  end

  context "#update" do
    should "accept post with done_ratio 100 and watcher" do
      assert_difference 'Issue.count' do
        post :create, :project_id => 1,
          :issue => {:tracker_id => 3,
                     :status_id => 2,
                     :subject => 'This is the test_new issue',
                     :description => 'This is the description',
                     :priority_id => 5,
                     :estimated_hours => ''}
      end
      put :update, :id => Issue.last.id,
        :issue => {:status_id => 5,
                   :priority_id => 4}
      assert_redirected_to :action => 'show', :id => Issue.last.id
      issue = Issue.find Issue.last.id
      assert_not_nil issue
      assert_equal 5, issue.status_id
      assert_equal 4, issue.priority_id
      assert_equal 100, issue.done_ratio
    end
  end
end
