# Issue Extensions plugin for Redmine
# Copyright (C) 2010-2011  Takashi Takebayashi
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
  include ApplicationHelper
  include ActionView::Helpers::TextHelper

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
            :queries,
            :watchers

  def setup
    @controller = IssuesController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
    @request.session[:user_id] = 2
  end

  def a_issue
    assert_difference 'Issue.count' do
      post :create, :project_id => 1,
        :issue => {:tracker_id => 3,
                   :status_id => 1,
                   :subject => 'This is the test_new issue',
                   :description => 'This is the description',
                   :priority_id => 4,
                   :estimated_hours => ''}
    end
  end

  def a_issue_extensions_status_flow
    IssueExtensionsStatusFlow.generate! :project_id => 1,
                                        :tracker_id => 0,
                                        :old_status_id => 1,
                                        :new_status_id => 2,
                                        :updated_by => 1
  end

  context "#new" do
    context "by member" do
      context "and module" do
        setup do
          EnabledModule.generate! :project_id => 1, :name => 'issue_extensions'
        end

        should "accept get" do
          get :new, :project_id => 1
          assert_response :success
          assert_template 'new.rhtml'
          assert_select "div[id='issue_extensions_form'] input[id='relation_issue_id']"
        end

        context "with relation issue" do
          should "accept get" do
            a_issue
            get :new, :project_id => 1,
              :relation_issue => Issue.last.id
            assert_response :success
            assert_template 'new.rhtml'
            assert_select "input[id='relation_issue_id']" do
              assert_select "[value=" + Issue.last.id.to_s + "]"
            end
          end
        end
      end

      should "accept get" do
        get :new, :project_id => 1
        assert_response :success
        assert_template 'new.rhtml'
        assert_select "div.issue_extensions_form", false
      end

      context "with relation issue" do
        should "accept get" do
          a_issue
          get :new, :project_id => 1,
            :relation_issue => Issue.last.id
          assert_response :success
          assert_template 'new.rhtml'
          assert_select "div.issue_extensions_form", false
        end
      end
    end
  end

  context "#create" do
    context "and module" do
      setup do
        EnabledModule.generate! :project_id => 1, :name => 'issue_extensions'
      end

      should "accept post with relation issue" do
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

    setup do
      a_issue
    end

    should "accept post with relation issue" do
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
      issue_relation = IssueRelation.find(:first, :conditions => ["issue_from_id = (?)", Issue.last.id])
      assert_nil issue_relation
    end
  end

  context "#show" do
    context "by member" do
      context "and module" do
        setup do
          EnabledModule.generate! :project_id => 1, :name => 'issue_extensions'
        end

        should "accept get" do
          get :show, :id => Issue.last.id
          assert_response :success
          assert_template 'show.rhtml'
          assert_select "div[id='issue_extensions_form'] div[id='issue_extensions_search'] input[id='cb_subject']" do
            assert_select "[value='']"
          end
          assert_select "div[id='issue_extensions_form'] div[id='issue_extensions_search'] fieldset.searched-issues"
          assert_select "div[id='issue_extensions_relations'] p a[class='icon icon-edit']"
        end

        should "accept get with cb_subject" do
          a_issue
          get :show, :id => Issue.last.id, :cb_subject => 'test'
          assert_response :success
          assert_template 'show.rhtml'
          assert_select "input[id='cb_subject']" do
            assert_select "[value='test']"
          end
          assert_select "ul[id='ul_searched-issues'] li div.tooltip"
        end
      end

      setup do
        a_issue
      end

      should "accept get" do
        get :show, :id => Issue.last.id
        assert_response :success
        assert_template 'show.rhtml'
        assert_select "div.issue_extensions_form", false
        assert_select "div.issue_extensions_relations", false
      end

      should "accept get with cb_subject" do
        a_issue
        get :show, :id => Issue.last.id, :cb_subject => 'test'
        assert_response :success
        assert_template 'show.rhtml'
        assert_select "div.issue_extensions_form", false
        assert_select "div.issue_extensions_relations", false
      end
    end
  end

  context "#update" do
    context "and module" do
      setup do
        EnabledModule.generate! :project_id => 1, :name => 'issue_extensions'
      end

      should "accept post with status_assigned and watcher" do
        a_issue_extensions_status_flow
        put :update, :id => Issue.last.id,
          :issue => {:assigned_to_id => 2}
        assert_redirected_to :action => 'show', :id => Issue.last.id
        issue = Issue.find Issue.last.id
        assert_not_nil issue
        assert_equal 2, issue.status_id
        watcher = Watcher.find :first, :conditions => ["watchable_id = (?)", Issue.last.id]
        assert_not_nil watcher
        assert_equal 2, watcher.user_id
        assert_equal 'Issue', watcher.watchable_type
      end

      should "accept post with done_ratio 100 and watcher" do
        put :update, :id => Issue.last.id,
          :issue => {:status_id => 5}
        assert_redirected_to :action => 'show', :id => Issue.last.id
        issue = Issue.find Issue.last.id
        assert_not_nil issue
        assert_equal 100, issue.done_ratio
        watcher = Watcher.find :first, :conditions => ["watchable_id = (?)", Issue.last.id]
        assert_not_nil watcher
        assert_equal 2, watcher.user_id
        assert_equal 'Issue', watcher.watchable_type
      end
    end

    setup do
      a_issue
    end

    should "accept post with status_assigned and watcher" do
      a_issue_extensions_status_flow
      put :update, :id => Issue.last.id,
        :issue => {:assigned_to_id => 2}
      assert_redirected_to :action => 'show', :id => Issue.last.id
      issue = Issue.find Issue.last.id
      assert_not_nil issue
      assert_not_equal 2, issue.status_id
      watcher = Watcher.find :first, :conditions => ["watchable_id = (?)", Issue.last.id]
      assert_nil watcher
    end

    should "accept post with done_ratio 100 and watcher" do
      put :update, :id => Issue.last.id,
        :issue => {:status_id => 5}
      assert_redirected_to :action => 'show', :id => Issue.last.id
      issue = Issue.find Issue.last.id
      assert_not_nil issue
      assert_not_equal 100, issue.done_ratio
      watcher = Watcher.find :first, :conditions => ["watchable_id = (?)", Issue.last.id]
      assert_nil watcher
    end
  end

  context "#bulk_edit" do
    context "and module" do
      setup do
        EnabledModule.generate! :project_id => 1, :name => 'issue_extensions'
      end

      should "accept posts with done_ratio 100" do
        issue_last_id = Issue.last.id
        post :bulk_update, :ids => [issue_last_id - 1, issue_last_id], :issue => {:status_id => '5'}
        assert_response 302
        issues = Issue.find [issue_last_id - 1, issue_last_id]
        assert_not_nil issues
        issues.each do |issue|
          assert_equal 5, issue.status_id
          assert_equal 100, issue.done_ratio
        end
      end
    end

    setup do
      a_issue
      a_issue
    end

    should "accept posts with done_ratio 100" do
      issue_last_id = Issue.last.id
      post :bulk_update, :ids => [issue_last_id - 1, issue_last_id], :issue => {:status_id => '5'}
      assert_response 302
      issues = Issue.find [issue_last_id - 1, issue_last_id]
      assert_not_nil issues
      issues.each do |issue|
        assert_equal 5, issue.status_id
        assert_not_equal 100, issue.done_ratio
      end
    end
  end

  teardown do
    IssueExtensionsStatusFlow.delete_all
  end
end
