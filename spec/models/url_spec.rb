# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Url, type: :model do
  describe 'validations' do
    it 'validates original URL is a valid URL' do
      url = Url.new(original_url: "invalid url")
      refute url.valid_url?
      url = Url.new(original_url: "http://google.com")
      assert url.valid_url?
    end

    it 'validates short URL format' do
      slug = Url.pick_slug
      assert slug, slug.upcase # check uppercase
      assert 5 , slug.length
    end


  end
end
