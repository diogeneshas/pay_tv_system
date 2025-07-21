require 'rails_helper'


RSpec.describe "/additional_services", type: :request do
 
  let(:valid_attributes) {
    build(:additional_service).attributes
  }

  describe "GET /index" do
    it "renders a successful response" do
      AdditionalService.create! valid_attributes
      get additional_services_url
      expect(response).to be_successful
    end
  end

  describe "GET /show" do
    it "renders a successful response" do
      additional_service = AdditionalService.create! valid_attributes
      get additional_service_url(additional_service)
      expect(response).to be_successful
    end
  end

  describe "GET /new" do
    it "renders a successful response" do
      get new_additional_service_url
      expect(response).to be_successful
    end
  end

  describe "GET /edit" do
    it "renders a successful response" do
      additional_service = AdditionalService.create! valid_attributes
      get edit_additional_service_url(additional_service)
      expect(response).to be_successful
    end
  end

  describe "POST /create" do
    context "with valid parameters" do
      it "creates a new AdditionalService" do
        expect {
          post additional_services_url, params: { additional_service: valid_attributes }
        }.to change(AdditionalService, :count).by(1)
      end
    end
  end

  describe "DELETE /destroy" do
    it "destroys the requested additional_service" do
      additional_service = AdditionalService.create! valid_attributes
      expect {
        delete additional_service_url(additional_service)
      }.to change(AdditionalService, :count).by(-1)
    end
  end
end
