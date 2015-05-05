Monologue.config do |config|
  config.site_name = 'Book of Vyne'
  config.site_subtitle = 'Wine Hacks by Vyne'
  config.site_url = 'https://www.vyne.co.uk'

  config.meta_description = 'Wine tips from Vyne'
  config.meta_keyword = 'wine, vyne, hacks, tips, food'

  config.admin_force_ssl = false
  config.posts_per_page = 10

  config.disqus_shortname = 'my_disqus_shortname'

  # LOCALE
  config.twitter_locale = 'en' # "fr"
  config.facebook_like_locale = 'en_US' # "fr_CA"
  config.google_plusone_locale = 'en'

  config.layout = 'layouts/aidani'

  # ANALYTICS
  # config.gauge_analytics_site_id = "YOUR COGE FROM GAUG.ES"
  # config.google_analytics_id = "YOUR GA CODE"

  config.sidebar = %w(latest_posts latest_tweets categories tag_cloud)


  #SOCIAL
  config.twitter_username = 'vynewine'
  config.facebook_url = 'https://www.facebook.com/vynewine'
  config.facebook_logo = 'logo.png'
  # config.google_plus_account_url = "https://plus.google.com/u/1/.../posts"
  # config.linkedin_url = "http://www.linkedin.com/in/myhandle"
  # config.github_username = "myhandle"
  config.show_rss_icon = false

end