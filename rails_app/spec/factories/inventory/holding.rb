# frozen_string_literal: true

FactoryBot.define do
  factory :holding, class: 'Inventory::Holding' do
    bib_holding do
      {
        'holding_id' => '678910',
        'created_by' => 'import',
        'created_date' => '2017-06-06Z',
        'originating_system' => 'ILS',
        'originating_system_id' => '223036-penndb',
        'suppress_from_publishing' => 'false',
        'calculated_suppress_from_publishing' => 'false',
        'anies' => [
          <<~MARCXML
            <?xml version="1.0" encoding="UTF-16"?>
            <record>
              <leader>00281cy  a22001214  4500</leader>
              <controlfield tag="001">223036</controlfield>
              <controlfield tag="004">184436</controlfield>
              <controlfield tag="005">20020722112855.0</controlfield>
              <controlfield tag="008">9706034u    u   o001uu   0000000</controlfield>
              <datafield ind1="1" ind2=" " tag="014">
                <subfield code="a">ABA6623001</subfield>
              </datafield>
              <datafield ind1="0" ind2=" " tag="014">
                <subfield code="9">000223044</subfield>
              </datafield>
              <datafield ind1="0" ind2="1" tag="852">
                <subfield code="b">ChemLib</subfield>
                <subfield code="c">chemperi</subfield>
                <subfield code="h">QD1</subfield>
                <subfield code="i">.C48</subfield>
                <subfield code="z">Public note</subfield>
              </datafield>
              <datafield ind1="4" ind2="1" tag="866">
                <subfield code="8">0</subfield>
                <subfield code="a">1965-1971</subfield>
              </datafield>
            </record>"
          MARCXML
        ]
      }
    end

    skip_create
    initialize_with { new(bib_holding) }
  end
end
