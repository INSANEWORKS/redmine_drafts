require_dependency 'issue'

module RedmineDrafts
  module IssuePatch
    extend ActiveSupport::Concern

    included do
      has_many :drafts, as: :element

      after_create :clean_drafts_after_create
      after_update :clean_drafts_after_update
    end

    def clean_drafts_after_create
      draft = Draft.find_for_issue(element_id: 0, user_id: User.current.id)
      draft.destroy if draft
    end

    def clean_drafts_after_update
      self.drafts.where(user_id: User.current.id).destroy_all
    end
  end
end

Issue.include RedmineDrafts::IssuePatch
