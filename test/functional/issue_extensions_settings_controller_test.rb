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

class IssueExtensionsSettingsControllerTest < ActionController::TestCase
  fixtures :issue_extensions_status_flows, :projects, :users, :trackers, :projects_trackers,
    :issues, :issue_statuses, :enumerations, :roles, :members, :member_roles, :enabled_modules, :attachments, :versions

  def setup
    @controller = IssueExtensionsSettingsController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
    @request.env["HTTP_REFERER"] = '/'

    EnabledModule.generate! :project_id => 1, :name => 'issue_extensions'

    User.current = nil
    roles = Role.find :all
    roles.each {|role|
      role.permissions << :manage_issue_extensions
      role.save
    }
  end

  # 匿名ユーザの update アクション
  test "update unauthorized user" do
    @request.session[:user_id] = User.anonymous.id
    get :update, :id => 1
    assert_response 302
  end

  # 認定ユーザの update アクション
  test "update authorized user" do
    @request.session[:user_id] = 1
    IssueExtensionsStatusFlow.find_or_create 1, 1

    post :update, :id => 1, :setting => {:old_status_id => 1, :new_status_id => 2}
    assert_response :redirect
    project = Project.find(1)
    assert_redirected_to :controller => 'projects', :action => 'settings', :id => project, :tab => 'issue_extensions'
  end
end
