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
  # A copy of ApplicationController has been removed from the module tree but is still active!対策
  unloadable
  # アクションが呼ばれる前に呼ぶメソッド
  before_filter :find_project, :find_user, :authorize

  def update
    @issue_extension_status_flow = IssueExtensionsStatusFlow.find_or_create(@project.id, @user.id)
    @issue_extension_status_flow.attributes = params[:setting]
    @issue_extension_status_flow.updated_by = @user.id
    @issue_extension_status_flow.save!
    flash[:notice] = l(:notice_successful_update)
    redirect_to :controller => 'projects', :action => "settings", :id => @project, :tab => 'issue_extensions'
  end

  def add_relation_issue

  end

  private
  # プロジェクト情報を取得する。
  # タブ消滅対策
  def find_project
    @project = Project.find(params[:id])
  end

  # ユーザ情報を取得する。
  def find_user
    @user = User.current
  end
end
