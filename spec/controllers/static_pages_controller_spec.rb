require 'spec_helper'

describe StaticPagesController do

  describe "GET 'home'" do
    it "renders the home template" do
      get :home
      expect(response).to render_template("home")
    end
  end

  describe "GET 'about'" do
    it "renders the about template" do
      get :about
      expect(response).to render_template("about")
    end
  end

  describe "GET 'privacy_policy'" do
    it "renders the privacy_policy template" do
      get :privacy_policy
      expect(response).to render_template("privacy_policy")
    end
  end


end
