class RemoveAbandonedCreationsJob < ApplicationJob
  queue_as :default

  def perform
    Bubble.remove_abandoned_creations
  end
end
