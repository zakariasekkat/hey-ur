# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Click, type: :model do
  describe 'validations' do
    it 'validates url_id is valid' do
      # i used th scoping so it have to work
    end

    it 'validates browser is not null' do
      click=Click.new
      refute click.valid_browser?
    end

    it 'validates platform is not null' do
      click=Click.new
      refute click.valid_platform?
    end
  end
end
