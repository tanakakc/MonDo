require 'spec_helper'

describe StaticPagesController do

  describe "GET 'home'" do
    it "renders the home template" do
      get :home
      expect(response).to render_template("home")
    end
  end

  describe "GET 'about'" do
    it "renders the home template" do
      get :about
      expect(response).to render_template("about")
    end
  end

end
