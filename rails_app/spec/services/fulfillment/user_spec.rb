# frozen_string_literal: true

describe Fulfillment::User do
  it_behaves_like 'Illiad Account' do
    let(:object) { described_class.new(uid: 'test') }
  end
end
