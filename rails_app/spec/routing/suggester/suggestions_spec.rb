# frozen_string_literal: true

describe 'routes for Suggestions', type: :routing do
  it 'properly sets the q parameter' do
    expect(get('/suggester/test')).to route_to(
      controller: 'suggester/suggestions',
      action: 'show',
      q: 'test'
    )
  end

  it 'properly sets the q parameter when it contains a period' do
    expect(get('/suggester/st.%20john')).to route_to(
      controller: 'suggester/suggestions',
      action: 'show',
      q: 'st. john'
    )
  end

  it 'properly sets the q parameter when it includes other URL path punctuation encoded by javascript' do
    expect(get('suggester/a%2Fb%3Fc%3Dd')).to route_to(
      controller: 'suggester/suggestions',
      action: 'show',
      q: 'a/b?c=d'
    )
  end
end
