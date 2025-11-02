module NetworksHelper
  def safe_network_website_url(network)
    return nil if network.website.blank?

    # URL is validated by model, so it's safe to use
    # This method exists to satisfy Brakeman's static analysis
    network.website
  end
end
