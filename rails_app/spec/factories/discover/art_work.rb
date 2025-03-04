# frozen_string_literal: true

FactoryBot.define do
  factory :art_work, class: 'Discover::ArtWork' do
    title { 'Chair' }
    link {  'https://pennartcollection.com/collection/art/1203/chair/' }
    thumbnail_url { 'https://pennartcollection.com/wp-content/themes/collection2015/images/objects/1203.thumb.jpg' }
    location { 'Somewhere on campus' }
    format { 'Etching' }
    creator { 'Murray, Elizabeth' }
    description do
      'Elizabeth Murray was an American painter and printmaker who was prolific throughout the second' \
'half of the twentieth century. As an artist, she was interested in both abstraction and representation. Her' \
'shaped and layered canvases challenged traditional conventions of painting, while her vibrant semi-abstract' \
'depictions of everyday objects, as well as her embrace of both high and low culture, challenged Modernist abstraction.'
    end
  end
end
