require 'spec_helper'

feature 'Sample Visit' do
  scenario 'user can see homepage' do
    visit root_path
    expect(page).to have_content 'Welcome Home'
  end

  scenario 'tests can run with javascript code', js: true do
    visit root_path
    expect(page).to have_content 'Injected via JS'
  end
end
