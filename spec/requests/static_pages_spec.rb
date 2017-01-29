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
      visit about_path
      expect(page).to have_content("MonDoとは？")
    end
  end

  describe "Privacy policy page" do
    it "should have the content  '個人情報のお取り扱い'" do
      visit privacy_policy_path
      expect(page).to have_content("個人情報のお取り扱い")
    end
  end


end
