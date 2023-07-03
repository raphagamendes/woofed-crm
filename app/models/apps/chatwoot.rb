# == Schema Information
#
# Table name: apps_chatwoots
#
#  id                        :bigint           not null, primary key
#  active                    :boolean          default(FALSE), not null
#  chatwoot_endpoint_url     :string           default(""), not null
#  chatwoot_user_token       :string           default(""), not null
#  embedding_token           :string           default(""), not null
#  name                      :string
#  status                    :string           default("inactive"), not null
#  created_at                :datetime         not null
#  updated_at                :datetime         not null
#  account_id                :bigint
#  chatwoot_account_id       :integer          not null
#  chatwoot_dashboard_app_id :integer          not null
#  chatwoot_webhook_id       :integer          not null
#
# Indexes
#
#  index_apps_chatwoots_on_account_id  (account_id)
#
class Apps::Chatwoot < ApplicationRecord
  include Applicable

  scope :actives, -> { where(active: true) }

  enum status: { 
    'inactive': 'inactive',
    'active': 'active',
    'sync': 'sync',
    'pair': 'pair',
  }

  validate :validate_chatwoot
  before_validation :chatwoot_create_flow
  before_destroy :chatwoot_delete_flow

  after_create_commit do
    self.update(embedding_token: generate_token)
  end

  def validate_chatwoot
    if self.chatwoot_dashboard_app_id.blank? || self.chatwoot_webhook_id.blank?
      errors.add(:chatwoot_endpoint_url, 'Invalid Chatwoot configuration')
      errors.add(:chatwoot_user_token, 'Invalid Chatwoot configuration')
    end
  end

  def chatwoot_create_flow
    dashboard_apps_response = Faraday.post(
      "#{chatwoot_endpoint_url}/api/v1/accounts/#{chatwoot_account_id}/dashboard_apps",
      {
        "title": "WoofedCRM",
        "content":[{"type": "frame","url": "https://www.woofedcrm.com"}]
      }.to_json,
      {'api_access_token': "#{chatwoot_user_token}", 'Content-Type': 'application/json'}
    )
    byebug
    webhook_response = Faraday.post(
      "#{chatwoot_endpoint_url}/api/v1/accounts/#{chatwoot_account_id}/webhooks",
      {
        "webhook":{
          "url": "https://chat.zimobi.com.br/app/accounts/5/settings/integrations/webhook",
          "subscriptions":["contact_created","contact_updated"]
        }
      }.to_json,
      {'api_access_token': "#{chatwoot_user_token}", 'Content-Type': 'application/json'}
    )

    if dashboard_apps_response.status == 200 && webhook_response.status == 200
      dashboard_apps_body = JSON.parse(dashboard_apps_response.body)
      webhook_body = JSON.parse(webhook_response.body)
      self.chatwoot_dashboard_app_id = dashboard_apps_body['id']
      self.chatwoot_webhook_id =  webhook_body['payload']['webhook']['id']
      return true
    else
      return false
    end

  rescue
    return false
  end

  def chatwoot_delete_flow
    dashboard_apps_response = Faraday.delete(
      "#{chatwoot_endpoint_url}/api/v1/accounts/#{chatwoot_account_id}/dashboard_apps/#{chatwoot_dashboard_app_id}",
      {},
      {'api_access_token': "#{chatwoot_user_token}", 'Content-Type': 'application/json'}
    )

    webhook_response = Faraday.delete(
      "#{chatwoot_endpoint_url}/api/v1/accounts/#{chatwoot_account_id}/webhooks/#{chatwoot_webhook_id}",
      {},
      {'api_access_token': "#{chatwoot_user_token}", 'Content-Type': 'application/json'}
    )

    byebug
    return true
    rescue
      return true
  end

  def generate_token
    loop do
      token = SecureRandom.hex(10)
      break token unless Apps::Chatwoot.where(embedding_token: token).exists?
    end
  end
end
