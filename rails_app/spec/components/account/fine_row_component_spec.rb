# frozen_string_literal: true

describe Account::FineRowComponent, type: :components do
  let(:penalty_data) do
    { 'type' => { 'value' => 'OVERDUEFINE', 'desc' => 'Overdue fine' },
      'balance' => 0.0,
      'original_amount' => 7.0,
      'creation_time' => '2016-11-03T10:59:00Z',
      'title' => 'THIRD WORLD MODERNISM - ARCHITECTURE, DEVELOPMENT AND IDENTITY',
      'transaction' => [{ 'type' => { 'value' => 'WAIVE', 'desc' => 'Waive' },
                          'amount' => 7.0, 'transaction_time' => '2018-09-10T19:41:00.325Z' }] }
  end

  let(:rendered) { render_inline(described_class.new(fine: Alma::AlmaRecord.new(penalty_data))) }

  it 'renders the fine type' do
    expect(rendered).to have_text 'Overdue fine'
  end

  it 'renders the loan title' do
    expect(rendered).to have_text penalty_data['title'].titleize.squish
  end

  it 'renders the date the fine was charged' do
    expect(rendered).to have_text '11/03/2016'
  end

  it 'renders the date of the last transaction' do
    expect(rendered).to have_text '09/10/2018'
  end

  it 'renders the original fine amount' do
    expect(rendered).to have_text '$7.00'
  end

  it 'renders the remaining balance' do
    expect(rendered).to have_text '$0.00'
  end

  context 'when a fee has no transaction data' do
    let(:penalty_data) do
      { 'type' => { 'value' => 'LOSTITEMREPLACEMENTFEE', 'desc' => 'Lost item replacement fee' },
        'balance' => 125.0,
        'original_amount' => 125.0,
        'creation_time' => '2018-09-10T19:41:00.325Z',
        'title' => 'THIRD WORLD MODERNISM - ARCHITECTURE, DEVELOPMENT AND IDENTITY' }
    end

    it 'renders without a last transaction date' do
      expect(rendered).to have_text 'Lost item replacement fee'
    end
  end

  context 'when a fine has no title' do
    let(:penalty_data) do
      { 'type' => { 'value' => 'CUSTOMER_DEFINED_01', 'desc' => 'WIC Equipment Fine' },
        'balance' => 25.0,
        'original_amount' => 25.0,
        'creation_time' => '2023-04-07T14:51:52.457Z' }
    end

    it 'renders without a title' do
      expect(rendered).to have_text 'WIC Equipment Fine'
    end
  end
end
