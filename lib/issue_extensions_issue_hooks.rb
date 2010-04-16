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
class IssueExtensionsIssueHook < Redmine::Hook::Listener
  def controller_issues_edit_before_save(context)
    issue_status_assigned(context)
  end

private
  # チケットに担当者が設定されている && 状態が新規の場合、担当に変更する
  def issue_status_assigned(context)
    @issue = context[:issue]
    @issue_status_default = IssueStatus.find(:first, :conditions => ["name = (?)", '新規'])
    @issue_status_assigned = IssueStatus.find(:first, :conditions => ["name = (?)", '担当'])

    if (@issue[:assigned_to_id] != nil && @issue_status_default != nil && @issue_status_assigned != nil)
      if (@issue_status_default.id == @issue[:status_id].to_i)
        @issue[:status_id] = @issue_status_assigned.id.to_s
        context[:issue] = @issue
      end
    end
  end
end
