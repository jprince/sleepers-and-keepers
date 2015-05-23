require 'spec_helper'

feature 'Sample Visit' do
  scenario 'tests can run with javascript code', js: true do
    sign_in create(:user)
    expect(page).to have_content 'Injected via JS'
  end
end
