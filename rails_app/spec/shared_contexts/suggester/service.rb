# frozen_string_literal: true

shared_context 'with cleared engine registry' do
  before { Suggester::Engines::Registry.clear! }
  after  { Suggester::Engines::Registry.clear! }
end
