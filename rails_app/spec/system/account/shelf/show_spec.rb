# frozen_string_literal: true

require 'system_helper'

describe 'Account Shelf show page' do
  context 'when displaying ill transaction' do
    it 'displays all expected information'
    it 'does not display buttons'
  end

  context 'when displaying ils hold' do
    it 'displays all expected information'

    context 'when not a resource sharing hold' do
      it 'displays cancel button'
      it 'displays record link'
    end

    context 'when a resource sharing hold' do
      it 'does not display cancel button'
      it 'does not display record link'
    end
  end

  context 'when displaying ils loan' do
    it 'displays all expected information'

    context 'when a renewable loan' do
      it 'displays renew button'
    end

    context 'when not a resource sharing loan' do
      it 'displays record button'
    end

    context 'when a resource sharing loan' do
      it 'does not display renew button'
      it 'does not display record button'
    end
  end
end
