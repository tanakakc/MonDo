require 'spec_helper'

describe "StaticPages" do

  describe "Home page" do
    it "should have the content 'MonDo'" do
      visit root_path
      expect(page).to have_content("MonDo")
    end
  end

  describe "About page" do
    it "should have the content 'MonDoとは？'" do
      visit '/about'
      expect(page).to have_content("MonDoとは？")
    end
  end

end
