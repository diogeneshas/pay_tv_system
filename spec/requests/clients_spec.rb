require 'rails_helper'

RSpec.describe "/clients", type: :request do
  
  let(:valid_attributes) { build(:client).attributes }

  describe "GET /index" do
    it "renders a successful response" do
      Client.create! valid_attributes
      get clients_url
      expect(response).to be_successful
    end
  end

  describe "GET /show" do
    it "renders a successful response" do
      client = Client.create! valid_attributes
      get client_url(client)
      expect(response).to be_successful
    end
  end

  describe "GET /new" do
    it "renders a successful response" do
      get new_client_url
      expect(response).to be_successful
    end
  end

  describe "GET /edit" do
    it "renders a successful response" do
      client = Client.create! valid_attributes
      get edit_client_url(client)
      expect(response).to be_successful
    end
  end

  describe "POST /create" do
    context "with valid parameters" do
      it "creates a new Client" do
        expect {
          post clients_url, params: { client: valid_attributes }
        }.to change(Client, :count).by(1)
      end
    end
  end

  describe "PATCH /update" do
    context "with valid parameters" do
      let(:new_attributes) { { name: "New name", age: 20 } }

      it "updates the requested client" do
        client = Client.create! valid_attributes
        patch client_url(client), params: { client: new_attributes }
        client.reload
        expect(client.name).to eq("New name")
        expect(client.age).to eq(20)
      end
    end
  end

  describe "DELETE /destroy" do
    it "destroys the requested client" do
      client = Client.create! valid_attributes
      expect {
        delete client_url(client)
      }.to change(Client, :count).by(-1)
    end
  end
end
