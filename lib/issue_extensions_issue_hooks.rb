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

class IssueExtensionsIssueHooks < Redmine::Hook::Listener
# TODO: 新規作成の際も動作できないか調査が必要
#  def controller_issues_new_before_save(context)
#    issue = context[:issue]
#    project = Project.find(issue[:project_id].to_i)
#    unless (project.module_enabled?(:issue_extensions) == nil)
#      issue_status_assigned(context)
#      issue_status_closed(context)
#    end
#  end

  def controller_issues_edit_before_save context
    issue = context[:issue]
    project = Project.find issue[:project_id].to_i
    if IssueExtensionsUtil.is_enabled?(project)
      issue_status_assigned context
      issue_status_closed context
      issue_added_watcher context
    end
  end

  def controller_issues_bulk_edit_before_save context
    issue = context[:issue]
    params = context[:params]
    project = Project.find issue[:project_id].to_i
    if IssueExtensionsUtil.is_enabled?(project)
      # Redmine 0.9.3 では、呼び元で issue[:status_id] に params[:status_id] の値を設定しない為、対応
      issue[:status_id] = params[:status_id].blank? ? issue[:status_id] : params[:status_id]
      context[:issue] = issue
      issue_status_closed context
    end
  end

  def controller_issues_new_after_save context
    issue = context[:issue]
    project = Project.find issue[:project_id].to_i
    if IssueExtensionsUtil.is_enabled?(project)
      issue_added_relation context
    end
  end

  private
  # チケットに担当者が設定されている && 状態が新規の場合、担当に変更する
  def issue_status_assigned context
    issue = context[:issue]
    issue_status = IssueExtensionsStatusFlow.where(project_id: issue[:project_id].to_i).first

    if issue_status.old_status_id == issue[:status_id]
        issue[:status_id] = issue_status.new_status_id
        context[:issue] = issue
      end if issue[:assigned_to_id] != nil && issue_status != nil
  end

  # チケットがクローズされている場合、進捗を100%に変更する
  def issue_status_closed context
    issue = context[:issue]
    issue_status_closed = IssueStatus.where(is_closed: true).all

    issue_status_closed.each {|closed|
      if closed.id == issue[:status_id].to_i && issue[:done_ratio] != 100
          issue[:done_ratio] = 100
          context[:issue] = issue
        end if issue[:status_id] != nil && issue[:done_ratio] != nil
    } unless issue_status_closed.length == 0
  end

  # チケットを更新した場合、更新者をウォッチャーに追加する
  def issue_added_watcher context
    issue = context[:issue]
    # TODO: journal がなくなった影響で動作しなくなっているので、調査が必要
    journal = context[:journal]

    if Watcher.where(watchable_type: journal[:journalized_type], watchable_id: issue[:id].to_i, user_id:  journal[:user_id].to_i).first == nil
        hash_watcher = HashWithIndifferentAccess.new
        hash_watcher[:user_id]  = journal[:user_id].to_s
        watcher = Watcher.new(hash_watcher)
        watcher.watchable_type  = journal[:journalized_type].to_s
        watcher.watchable_id    = issue[:id].to_i
        watcher.save
      end if journal != nil && journal[:journalized_type] != nil && issue[:id] != nil && journal[:user_id] != nil
  end

  # 関連チケットを指定している場合、関連付けする
  def issue_added_relation context
    issue = context[:issue]
    params = context[:params]
    from_issue = Issue.where(id: params[:relation_issue_id].to_i).first
    unless from_issue == nil
      relation = IssueRelation.new
      relation.relation_type = IssueRelation::TYPE_RELATES
      relation.issue_from_id = params[:relation_issue_id]
      relation.issue_to_id = issue.id
      relation.save!
    end
  end

  class IssueExtensionsIssueViewListener < Redmine::Hook::ViewListener
    # 関連したチケットの作成ページへのリンクとチケット検索表示を追記する
    render_on :view_issues_show_description_bottom, :partial => 'issues/issue_extensions_form', :multipart => true
    # 関連元のチケットのID埋め込みと「自分を選ぶ」ボタンを追記する
    render_on :view_issues_form_details_bottom, :partial => 'issues/issue_extensions_view_issues_form_details_bottom', :multipart => true
  end
end
