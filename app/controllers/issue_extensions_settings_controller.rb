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
class IssueExtensionsSettingsController < ApplicationController
  before_filter :find_project
  before_filter :authorize

  def update
    @user = User.current
    @issue_extension_status_flow = IssueExtensionsStatusFlow.find_or_create(@project.id, @user.id)
    @issue_extension_status_flow.attributes = issue_extension_settings_params
    @issue_extension_status_flow.updated_by = @user.id
    @issue_extension_status_flow.save!
    flash[:notice] = l(:notice_successful_update)
    redirect_to :controller => 'projects', :action => "settings", :id => @project, :tab => 'issue_extensions'
  end

  def issue_extension_settings_params
    params.require(:setting).permit :old_status_id, :new_status_id
  end

end
