# frozen_string_literal: true

shared_examples 'renders Additional Results component' do
  it 'renders the component' do
    expect(rendered).to have_css('div.documents-list')
  end
end

shared_examples 'does not render Additional Results component' do
  it 'does not render the component' do
    expect(rendered.to_html).to be_empty
  end
end

shared_examples 'renders turbo frames for each included source' do
  it 'renders turbo frame tags for sources remaining after filtering' do
    filtered.each do |source|
      expect(rendered).to have_css("turbo-frame##{source}-frame")
    end
  end
end

shared_examples 'returns expected number of included sources' do |count|
  it 'returns the expected number of sources' do
    expect(filtered.size).to eq(count)
  end
end
