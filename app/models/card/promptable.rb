module Card::Promptable
  extend ActiveSupport::Concern

  included do
    include Rails.application.routes.url_helpers
  end

  def to_prompt
    <<~PROMPT
      BEGIN OF CARD #{id}

      **Title:** #{title.first(1000)}
      **Description:**

      #{description.to_plain_text.first(10_000)}

      #### Metadata

      * Id: #{id}
      * Created by: #{creator.name}}
      * Assigned to: #{assignees.map(&:name).join(", ")}}
      * Workflow stage: #{stage&.name}
      * Created at: #{created_at}}
      * Closed: #{closed?}
      * Closed by: #{closed_by&.name}
      * Closed at: #{closed_at}
      * Collection id: #{collection_id}
      * Collection name: #{collection.name}
      * Number of comments: #{comments.count}
      * Path: #{collection_card_path(collection, self, script_name: Account.sole.slug)}

      END OF CARD #{id}
    PROMPT
  end
end
