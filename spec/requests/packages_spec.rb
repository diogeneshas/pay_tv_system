require 'rails_helper'

RSpec.describe "/packages", type: :request do
  let(:valid_attributes) {
    build(:package).attributes
  }

  describe "GET /index" do
    it "renders a successful response" do
      Package.create! valid_attributes
      get packages_url
      expect(response).to be_successful
    end
  end

  describe "GET /show" do
    it "renders a successful response" do
      package = Package.create! valid_attributes
      get package_url(package)
      expect(response).to be_successful
    end
  end

  describe "GET /new" do
    it "renders a successful response" do
      get new_package_url
      expect(response).to be_successful
    end
  end

  describe "GET /edit" do
    it "renders a successful response" do
      package = Package.create! valid_attributes
      get edit_package_url(package)
      expect(response).to be_successful
    end
  end

  describe "POST /create" do
    context "with valid parameters" do
      it "creates a new Package" do
        expect {
          post packages_url, params: { package: valid_attributes }
        }.to change(Package, :count).by(1)
      end
    end
  end

  describe "PATCH /update" do
    context "with valid parameters" do
      let(:new_attributes) {
        { name: "Updated Package Name", price: 99.99 }
      }

      it "updates the requested package" do
        package = Package.create! valid_attributes
        patch package_url(package), params: { package: new_attributes }
        package.reload
        expect(package.name).to eq(new_attributes[:name])
        expect(package.price).to eq(new_attributes[:price])
      end
    end
  end

  describe "DELETE /destroy" do
    it "destroys the requested package" do
      package = Package.create! valid_attributes
      expect {
        delete package_url(package)
      }.to change(Package, :count).by(-1)
    end
  end
end
