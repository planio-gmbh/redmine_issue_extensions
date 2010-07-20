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
            :issue_extensions_status_flows

  def setup
    @controller = IssuesController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
    User.current = nil
    EnabledModule.generate! :project_id => 1, :name => 'issue_extensions'
  end

  test "issue_added_relation success" do
    @request.session[:user_id] = 1
    get :new, :project_id => 1, :relation_issue => 1
    assert_response :success
    post :new, :project_id => 1,
      :issue => {:tracker_id => 1, :status_id => 1, :subject => 'test issue001'},
      :relation_issue_id => 1
    assert_response :redirect
  end

  test "issue_added_relation error because invalid issue id" do
    @request.session[:user_id] = 1
    get :new, :project_id => 1, :relation_issue => 100
    assert_response :success
    post :new, :project_id => 1,
      :issue => {:tracker_id => 1, :status_id => 1, :subject => 'test issue002'},
      :relation_issue_id => 100
    assert_response :redirect
  end
end
