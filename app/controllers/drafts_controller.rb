class DraftsController < ApplicationController
  before_action :require_login

  def autosave
    params[:issue] ||= {}
    params[:notes] ||= params[:issue][:notes]
    params[:issue][:notes] ||= params[:notes]

    has_to_be_saved = !params[:notes].blank?
    has_to_be_saved ||= (params[:issue_id].to_i == 0 && !params[:issue][:subject].blank?)

    if request.xhr? && has_to_be_saved
      @draft = Draft.find_or_create_for_issue(user_id: User.current.id, element_id: params[:issue_id].to_i)

      new_content = params.slice(:issue, :notes)
      if @draft.content != new_content
        @draft.content = new_content
        if @draft.save
          render partial: 'saved', layout: false
        else
          render plain: 'Error saving draft'
        end
      end
    end

    Draft.purge_older_drafts!
    head :ok unless performed?
  end

  def restore
    @draft = Draft.find_by(id: params[:id])

    if @draft.blank? || @draft.element_id == 0
      redirect_to controller: 'issues', action: 'new', project_id: params[:project_id], draft_id: @draft
    else
      redirect_to controller: 'issues', action: 'edit', id: @draft.element_id, draft_id: @draft
    end
  end

  def destroy
    @draft = Draft.find_by(id: params[:id])
    @draft.destroy if @draft.present?

    respond_to do |format|
      format.js
    end
  end
end
