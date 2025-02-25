class Accounts::Apps::Chatwoots::Webhooks::Events::Message

  def self.call(chatwoot, webhook)
    contact = Accounts::Apps::Chatwoots::Webhooks::ImportContact.call(chatwoot, webhook['conversation']['contact_inbox']['contact_id'])[:ok]
    message = Accounts::Apps::Chatwoots::Webhooks::ImportMessage.call(chatwoot, contact, webhook)
    return { ok: message }
  end
end