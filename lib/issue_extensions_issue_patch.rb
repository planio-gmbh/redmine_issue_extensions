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
require_dependency 'issue'

module IssueExtensionsIssuePatch
  def self.included base
    base.extend ClassMethods
    base.send :include, InstanceMethods
    base.class_eval do
      alias_method_chain :validate, :issue_extensions
    end
  end

  module ClassMethods
  end

  module InstanceMethods
    def validate_with_issue_extensions
      validate_without_issue_extensions
      p "read_attribute(:id).to_s: " + read_attribute(:id).to_s
      p "read_attribute(:project_id).to_s: " + read_attribute(:project_id).to_s
      p "read_attribute(:tracker_id).to_s: " + read_attribute(:tracker_id).to_s
      p "read_attribute(:status_id).to_s: " + read_attribute(:status_id).to_s
      project = Project.find read_attribute :project_id
      unless project.module_enabled? :issue_extensions == nil
        tracker = Tracker.find :first, :conditions => ["name = (?)", 'バグ']
        issue_status = IssueStatus.find :first, :conditions => ["name = (?)", '終了']
        if tracker != nil && issue_status != nil
          if tracker.id == read_attribute(:tracker_id) && issue_status.id == read_attribute(:status_id)
            errors.add :fixed_version_id, :empty if read_attribute(:fixed_version_id).blank?
          end
        end
      end
    end
  end
end
Issue.send(:include, IssueExtensionsIssuePatch)
