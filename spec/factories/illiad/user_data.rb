# frozen_string_literal: true

FactoryBot.define do
  factory :illiad_user_data, class: Hash do
    add_attribute(:UserName) { 'testuser' }
    add_attribute(:ExternalUserId) { 'testuser' }
    add_attribute(:LastName) { 'User' }
    add_attribute(:FirstName) { 'Test' }
    add_attribute(:SSN) { '22222222' }
    add_attribute(:Status) { 'Staff' }
    add_attribute(:EMailAddress) { 'testuser@upenn.edu' }
    add_attribute(:Phone) { '9042411080' }
    add_attribute(:Department) { 'Other - Unlisted' }
    add_attribute(:NVTGC) { 'VPL' }
    add_attribute(:NotificationMethod) { 'Electronic' }
    add_attribute(:DeliveryMethod) { 'Mail to Address' }
    add_attribute(:LoanDeliveryMethod) { 'Hold for Pickup' }
    add_attribute(:LastChangedDate) { '2020-12-24T12:12:12' }
    add_attribute(:AuthorizedUsers) { nil }
    add_attribute(:Cleared) { 'Yes' }
    add_attribute(:Web) { true }
    add_attribute(:Address) { '123 Main St.' }
    add_attribute(:Address2) { nil }
    add_attribute(:City) { 'Philadelphia' }
    add_attribute(:State) { 'PA' }
    add_attribute(:Zip) { '19104' }
    add_attribute(:Site) { nil }
    add_attribute(:ExpirationDate) { '2025-12-08T10:50:04' }
    add_attribute(:Number) { nil }
    add_attribute(:UserRequestLimit) { nil }
    add_attribute(:Organization) { nil }
    add_attribute(:Fax) { nil }
    add_attribute(:ShippingAcctNo) { nil }
    add_attribute(:ArticleBillingCategory) { 'Exempt' }
    add_attribute(:LoanBillingCategory) { 'Exempt' }
    add_attribute(:Country) { nil }
    add_attribute(:SAddress) { nil }
    add_attribute(:SAddress2) { nil }
    add_attribute(:SCity) { nil }
    add_attribute(:SState) { nil }
    add_attribute(:SZip) { nil }
    add_attribute(:SCountry) { nil }
    add_attribute(:RSSID) { '555555555555555555555' }
    add_attribute(:AuthType) { 'ILLiad' }
    add_attribute(:UserInfo1) { nil }
    add_attribute(:UserInfo2) { nil }
    add_attribute(:UserInfo3) { nil }
    add_attribute(:UserInfo4) { nil }
    add_attribute(:UserInfo5) { nil }
    add_attribute(:MobilePhone) { nil }

    skip_create
    initialize_with { attributes.stringify_keys }
  end
end
