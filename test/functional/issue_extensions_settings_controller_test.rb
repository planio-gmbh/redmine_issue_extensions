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
  fixtures :projects,
            :users,
            :trackers,
            :projects_trackers,
            :issues,
            :issue_statuses,
            :enumerations,
            :roles,
            :members,
            :member_roles,
            :enabled_modules,
            :attachments,
            :versions

  def setup
    @controller = IssueExtensionsSettingsController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
    EnabledModule.generate! :project_id => 1, :name => 'issue_extensions'
  end

  context '#update' do
    context "by anonymous" do
      setup do
        @request.session[:user_id] = User.anonymous.id
      end

      should "302 get" do
        get :update, :id => 1
        assert_response 302
      end

      should "302 post" do
        post :update, :id => 1, :setting => {:old_status_id => 1, :new_status_id => 2}
        assert_response 302
      end

      context "with permission" do
        setup do
          Role.anonymous.add_permission! :manage_issue_extensions
        end

        should "302 get" do
          get :update, :id => 1
          assert_response 302
        end

        should "302 post" do
          post :update, :id => 1, :setting => {:old_status_id => 1, :new_status_id => 2}
          assert_response 302
        end
      end
    end

    context "by non member" do
      setup do
        @request.session[:user_id] = 9
      end

      should "403 get" do
        get :update, :id => 1
        assert_response 403
      end

      should "403 post" do
        post :update, :id => 1, :setting => {:old_status_id => 1, :new_status_id => 2}
        assert_response 403
      end

      context "with permission" do
        setup do
          Role.non_member.add_permission! :manage_issue_extensions
        end

        should "redirect get" do
          get :update, :id => 1
          assert_response :redirect
          project = Project.find 1
          assert_redirected_to :controller => 'projects', :action => 'settings', :id => project, :tab => 'issue_extensions'
        end

        should "redirect post" do
          post :update, :id => 1, :setting => {:old_status_id => 1, :new_status_id => 2}
          assert_response :redirect
          issue_extensions_status_flow = IssueExtensionsStatusFlow.find :first, :conditions => 'project_id = 1'
          assert_equal 1, issue_extensions_status_flow.old_status_id
          assert_equal 2, issue_extensions_status_flow.new_status_id
          project = Project.find 1
          assert_redirected_to :controller => 'projects', :action => 'settings', :id => project, :tab => 'issue_extensions'
        end
      end
    end

    context "by member" do
      setup do
        @request.session[:user_id] = 2
      end

      should "403 get" do
        get :update, :id => 1
        assert_response 403
      end

      should "403 post" do
        post :update, :id => 1, :setting => {:old_status_id => 1, :new_status_id => 2}
        assert_response 403
      end

      context "with permission" do
        setup do
          Role.find(1).add_permission! :manage_issue_extensions
        end

        should "redirect get" do
          get :update, :id => 1
          assert_response :redirect
          project = Project.find 1
          assert_redirected_to :controller => 'projects', :action => 'settings', :id => project, :tab => 'issue_extensions'
        end

        should "redirect post" do
          post :update, :id => 1, :setting => {:old_status_id => 1, :new_status_id => 2}
          assert_response :redirect
          issue_extensions_status_flow = IssueExtensionsStatusFlow.find :first, :conditions => 'project_id = 1'
          assert_equal 1, issue_extensions_status_flow.old_status_id
          assert_equal 2, issue_extensions_status_flow.new_status_id
          project = Project.find 1
          assert_redirected_to :controller => 'projects', :action => 'settings', :id => project, :tab => 'issue_extensions'
        end
      end
    end

    teardown do
      IssueExtensionsStatusFlow.delete_all
    end
  end
end
