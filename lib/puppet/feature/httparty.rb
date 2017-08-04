Puppet.features.add(:httparty) do
  begin
    require 'httparty'
  rescue LoadError => e
    warn "Cannot manage Connect jobs without the 'httparty' Ruby gem. #{e}"
  end
end
