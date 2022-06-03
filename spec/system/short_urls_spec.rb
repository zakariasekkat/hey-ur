# frozen_string_literal: true

require 'rails_helper'
require 'webdrivers'

# WebDrivers Gem
# https://github.com/titusfortner/webdrivers
#
# Official Guides about System Testing
# https://api.rubyonrails.org/v5.2/classes/ActionDispatch/SystemTestCase.html

RSpec.describe 'Short Urls', type: :system do
  before do
    driven_by :selenium, using: :chrome
    # If using Firefox
    # driven_by :selenium, using: :firefox
    #
    # If running on a virtual machine or similar that does not have a UI, use
    # a headless driver
    # driven_by :selenium, using: :headless_chrome
    # driven_by :selenium, using: :headless_firefox
  end

  describe 'index' do
    it 'shows a list of short urls' do
      # Create 10 records
      10.times do |index|
        Url.create(original_url: "http://google/#{index}", short_url: Url.pick_slug)
      end
      visit root_path
      # expect page to show 10 urls
      Url.order('created_at desc').limit(10).each do |url|
        expect(page).to have_text(url.original_url)
        expect(page).to have_text(url.short_url)
      end

    end
  end

  describe 'show' do
    it 'shows a panel of stats for a given short url' do
      slug = Url.pick_slug
      Url.create(original_url: 'http://url.com', short_url: slug)
      visit url_path(slug)

      # expect page to show the short url
      expect(page).to have_text(slug)
    end

    context 'when not found' do
      it 'shows a 404 page' do
        visit url_path('NOTFOUND')
        expect(page).to have_text("Not found 404")
      end
    end
  end

  describe 'create' do
    context 'when url is valid' do
      it 'creates the short url' do
        visit '/'

        find('#url_original_url').send_keys "https://someurl.com/somepath"
        find("#submit_form").click
        assert "https://someurl.com/somepath", find("#original_url_0").text

        # redirects to the home page
        assert_equal "/", URI.parse(Capybara.current_session.driver.frame_url).path

      end

    end

    context 'when url is invalid' do
      it 'does not create the short url and shows a message' do
        visit '/'
        # add more expections
        visit '/'
        find('#url_original_url').send_keys "somepath"
        find("#submit_form").click
        assert "invalid Url", find(".card-panel.notice.deep-orange").text.strip
        # redirects to the home page
        assert_equal "/", URI.parse(Capybara.current_session.driver.frame_url).path
      end

    end
  end

  describe 'visit' do
    it 'redirects the user to the original url' do
      slug = Url.pick_slug
      Url.create(original_url: "http://localhost:#{Capybara.current_session.server.port}", short_url: slug)
      count_click = Click.count
      visit visit_path(slug)
      assert count_click + 1, Click.count

      assert_equal  "http://localhost:#{Capybara.current_session.server.port}/", Capybara.current_session.driver.frame_url
    end

    context 'when not found' do
      it 'shows a 404 page' do
        visit visit_path('NOTFOUND')
        # expect page to be a 404
        expect(page).to have_text("Not found 404")
      end
    end
  end
end
