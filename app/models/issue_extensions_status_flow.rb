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
class IssueExtensionsStatusFlow < ActiveRecord::Base
  belongs_to :project

  def self.find_or_create project_id, user_id
    status_flow = IssueExtensionsStatusFlow.find :first, :conditions => ['project_id = ?', project_id]
    unless status_flow
      status_flow = IssueExtensionsStatusFlow.new
      status_flow.project_id = project_id
      status_flow.updated_by = user_id
      status_flow.save!
    end
    return status_flow
  end
end
