# frozen_string_literal: true

class UrlsController < ApplicationController
  def index
    # new form
    @url = Url.new

    # recent 10 short urls
    @urls = Url.order('created_at desc').limit(10)
  end

  def create
    # create a new URL record

    # I use trailblaizer gem for steps , diagram bpmn

    # step 1 read params and set model
    allowed = params.require(:url).permit(:original_url)
    model = Url.new(allowed)

    # step 2 validate
    unless model.valid_url?
      flash[:notice] = "invalid Url"
      return redirect_to "/"
    end

    # step 3
    model.short_url = Url.pick_slug
    model.save
    redirect_to "/"

  end

  def show

    @url = Url.find_by(short_url: params[:url])
    if @url.blank?
      return render plain: "Not found 404", status: :not_found
    end

    # implement queries

    sql = <<SQL
select extract(day from created_at)::text as day , count(id) as count  from clicks
where created_at >= :day_1 and created_at<= :day_2 and url_id=:url_id
group by day order by day
SQL

    result = ActiveRecord::Base.connection.execute(
      ApplicationRecord.sanitize_sql([sql, { day_1: Date.today.at_beginning_of_month, day_2: Date.today.at_end_of_month, url_id: @url.id }])
    )

    @daily_clicks = []
    result.each do |row|
      @daily_clicks.push [row['day'], row['count']]
    end

    ## browser clicks
    @browsers_clicks = []
    @url.clicks.group(:browser).count.each do |row|
      @browsers_clicks.push row
    end

    ## platform_clicks clicks
    @platform_clicks = []
    @url.clicks.group(:platform).count.each do |row|
      @platform_clicks.push row
    end

  end

  def visit
    @url = Url.find_by(short_url: params[:short_url])
    if @url.blank?
      return render plain: "Not found 404", status: :not_found
    end

    click = @url.clicks.new(browser: browser.name, platform: browser.platform.name)

    unless click.valid_browser?
      return render plain: "Invalid browser", status: 422
    end

    unless click.valid_platform?
      return render plain: "Invalid platform", status: 422
    end

    redirect_to @url.original_url
  end

  def json_file


    urls = Url.order('created_at desc').limit(10)
    json_urls = []
    json_includeds = []
    urls.each do |url|
      clicks = []

      url.clicks.each do |click|
        clicks.push(
          {
            "id": click.id,
            "type": "clicks"
          }
        )
        json_includeds.push(
          {
            "type": "clicks",
            "id": click.id,
            "attributes": {
              "browser": click.browser,
              "platform": "platform"
            }
          }
        )
      end

      json_urls.push(
        {
          "type": "urls",
          "id": url.id,
          "attributes": {
            "created-at": url.created_at,
            "original-url": url.original_url,
            "url": url.short_url,
            "clicks": clicks.count
          },
          "relationships": {
            "clicks": {
              "data": clicks
            }
          }
        }
      )

    end
    render json: {
      "data": json_urls,
      "included":json_includeds
    }
  end
end
