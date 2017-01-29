require 'spec_helper'

describe "StaticPages" do

  describe "Home page" do
    it "should have the content 'MonDo'" do
      visit root_path
      expect(page).to have_content("MonDo")
    end
  end

end
