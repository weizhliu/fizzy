class My::PinsController < ApplicationController
  def index
    @pins = Current.user.pins.includes(:bubble).ordered.limit(20)
  end
end
