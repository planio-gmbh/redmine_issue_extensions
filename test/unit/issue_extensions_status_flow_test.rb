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

class IssueExtensionsStatusFlowTest < ActiveSupport::TestCase
  def a_issue_extensions_status_flow
    IssueExtensionsStatusFlow.generate! :project_id => 1,
                                        :tracker_id => 0,
                                        :old_status_id => 1,
                                        :new_status_id => 2,
                                        :updated_by => 1
  end

  context "#find" do
    should "return nil" do
      assert_nil IssueExtensionsStatusFlow.first
    end

    context "with a IssueExtensionsStatusFlow record" do
      setup do
        a_issue_extensions_status_flow
      end

      should "return not nil" do
        assert_not_nil IssueExtensionsStatusFlow.first
      end
    end
  end

  context "#find_or_create" do
    should "return create record" do
      assert !IssueExtensionsStatusFlow.where(project_id: 5).first
      create = IssueExtensionsStatusFlow.find_or_create 5, 1
      assert_equal 5, create.project_id
      assert IssueExtensionsStatusFlow.where(projectd_id: 5).first
    end

    should "create equal find" do
      assert !IssueExtensionsStatusFlow.where(project_id: 5).first
      create = IssueExtensionsStatusFlow.find_or_create 5, 1
      find = IssueExtensionsStatusFlow.find_or_create 5, 1
      assert_equal 5, find.project_id
      assert_equal create, find
    end
  end

  teardown do
    IssueExtensionsStatusFlow.delete_all
  end
end
