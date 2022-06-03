# frozen_string_literal: true

class Click < ApplicationRecord
  belongs_to :url , counter_cache: :clicks_count


  def valid_browser?
    self .browser.present?
  end

  def valid_platform?
    self .platform.present?
  end


end
