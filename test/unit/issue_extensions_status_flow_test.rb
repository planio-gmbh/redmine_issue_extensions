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
  fixtures :issue_extensions_status_flows

  context 'a IssueExtensionsStatusFlow instance' do
    should "find return not nil" do
      assert_not_nil IssueExtensionsStatusFlow.find :first
    end

    should "find_or_create return project_id 5" do
      assert !IssueExtensionsStatusFlow.find(:first, :conditions => 'project_id = 5')
      setting = IssueExtensionsStatusFlow.find_or_create 5, 1
      assert_equal 5, setting.project_id
      assert IssueExtensionsStatusFlow.find :first, :conditions => 'project_id = 5'
      setting = IssueExtensionsStatusFlow.find_or_create 5, 1
      assert_equal 5, setting.project_id
    end
  end
end