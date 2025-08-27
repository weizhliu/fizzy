class Ai::Quota < ApplicationRecord
  class UsageExceedsQuotaError < StandardError; end

  belongs_to :user

  before_create -> { reset }

  validates :limit, presence: true, numericality: { only_integer: true, greater_than_or_equal_to: 0 }
  validates :used, presence: true, numericality: { only_integer: true, greater_than_or_equal_to: 0 }

  def spend(cost)
    cost = Money.wrap(cost)

    transaction do
      reset_if_due
      increment!(:used, cost.in_microcents)
    end
  end

  def ensure_not_depleted
    reset_if_due

    if depleted?
      raise UsageExceedsQuotaError
    end
  end

  private
    def reset_if_due
      reset if due_for_reset?
    end

    def reset
      attributes = { used: 0, reset_at: 7.days.from_now }

      if persisted?
        update(**attributes)
      else
        assign_attributes(**attributes)
      end
    end

    def due_for_reset?
      reset_at.before?(Time.current)
    end

    def depleted?
      used >= limit
    end
end
