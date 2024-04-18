# frozen_string_literal: true

require 'system_helper'

describe 'Fines and Fees show page' do
  let(:user) { build(:user) }
  let(:total_fines) { 100.0 }

  before do
    sign_in user

    # Stub Alma User
    alma_user = instance_double(Alma::User)
    allow(user).to receive(:alma_record).and_return(alma_user)
    allow(alma_user).to receive(:total_fines).and_return(total_fines)

    visit fines_and_fees_path
  end

  it 'shows total fines' do
    expect(page).to have_text "$#{total_fines}"
  end
end
