# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Event do
  context 'scopes' do
    let(:account) { create(:account) }
    let!(:event_done) { create(:event, done: true, scheduled_at: Time.current, kind: 'note', account: account) }
    let!(:event_planned_1) do
      create(:event, account: account, auto_done: false, scheduled_at: (Time.current + 1.hour), kind: 'activity')
    end
    let!(:event_planned_2) do
      create(:event, account: account, auto_done: false, scheduled_at: (Time.current + 2.hour), kind: 'activity')
    end
    let!(:event_scheduled_1) do
      create(:event, account: account, auto_done: true, scheduled_at: (Time.current + 2.hour), kind: 'activity')
    end
    describe 'done' do
      it 'returns 1 event' do
        expect(account.events.done.count).to be 1
      end
    end

    describe 'planned' do
      it 'returns 2 events' do
        expect(account.events.planned.count).to be 2
      end
    end

    skip 'planned overdue' do
    end

    skip 'planned without date' do
    end
    describe 'to do' do
      it 'returns 3 events' do
        expect(account.events.to_do.count).to be 3
      end
    end

    describe 'scheduled' do
      it 'returns 1 events' do
        expect(account.events.scheduled.count).to be 1
      end
    end
  end
end
