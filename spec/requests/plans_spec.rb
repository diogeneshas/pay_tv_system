require 'rails_helper'

RSpec.describe "/plans", type: :request do
 
  let(:valid_attributes) {
    build(:plan).attributes
  }

  describe "GET /index" do
    it "renders a successful response" do
      Plan.create! valid_attributes
      get plans_url
      expect(response).to be_successful
    end
  end

  describe "GET /show" do
    it "renders a successful response" do
      plan = Plan.create! valid_attributes
      get plan_url(plan)
      expect(response).to be_successful
    end
  end

  describe "GET /new" do
    it "renders a successful response" do
      get new_plan_url
      expect(response).to be_successful
    end
  end

  describe "GET /edit" do
    it "renders a successful response" do
      plan = Plan.create! valid_attributes
      get edit_plan_url(plan)
      expect(response).to be_successful
    end
  end

  describe "POST /create" do
    context "with valid parameters" do
      it "creates a new Plan" do
        expect {
          post plans_url, params: { plan: valid_attributes }
        }.to change(Plan, :count).by(1)
      end
    end
  end

  describe "DELETE /destroy" do
    it "destroys the requested plan" do
      plan = Plan.create! valid_attributes
      expect {
        delete plan_url(plan)
      }.to change(Plan, :count).by(-1)
    end
  end
end
