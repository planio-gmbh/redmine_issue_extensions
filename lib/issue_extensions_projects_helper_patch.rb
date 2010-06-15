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
require_dependency 'projects_helper'

module IssueExtensionsProjectsHelperPatch
  def self.included base # :nodoc:
    base.send :include, ProjectsHelperMethodsIssueExtensions
    base.class_eval do
      alias_method_chain :project_settings_tabs, :issue_extensions
    end
  end
end

module ProjectsHelperMethodsIssueExtensions
  # 設定タブの追加
  def project_settings_tabs_with_issue_extensions
    tabs = project_settings_tabs_without_issue_extensions
    action = {:name => 'issue_extensions', :controller => 'issue_extensions_settings', :action => :show, :partial => 'issue_extensions_settings/show', :label => :issue_extensions}
    tabs << action if User.current.allowed_to?(action, @project)
    tabs
  end
end
ProjectsHelper.send(:include, IssueExtensionsProjectsHelperPatch)
