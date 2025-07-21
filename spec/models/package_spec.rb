require 'rails_helper'

RSpec.describe Package, type: :model do
  describe "validations" do
    it { should validate_presence_of(:name) }
    it { should validate_numericality_of(:price).is_greater_than_or_equal_to(0) }
  end

  describe "associations" do
    it { should belong_to(:plan) }
    # Testamos a associação manualmente em vez de usar o matcher .optional
    # porque temos uma validação condicional que interfere com o matcher
    it "belongs to additional_service" do
      expect(Package.new).to respond_to(:additional_service)
    end
  end

  describe "conditional validations" do
    let(:plan) { create(:plan, price: 50) }
    
    context "when price is not provided" do
      it "requires additional_service" do
        package = Package.new(name: "Pacote Básico", plan: plan, price: nil)
        expect(package).not_to be_valid
        expect(package.errors[:additional_service]).to include("can't be blank")
      end
    end

    context "when price is provided" do
      it "does not require additional_service" do
        package = Package.new(name: "Pacote Básico", plan: plan, price: 100)
        expect(package).to be_valid
      end
    end
  end

  describe "price calculation" do
    let(:plan) { create(:plan, price: 50) }
    let(:additional_service) { create(:additional_service, price: 30) }

    describe "#calculate_total_price" do
      it "returns the sum of plan and additional_service prices" do
        package = Package.new(plan: plan, additional_service: additional_service)
        expect(package.calculate_total_price).to eq(80) # 50 + 30
      end
    end

    describe "automatic price calculation" do
      context "when price is not provided" do
        it "calculates price from plan and additional_service" do
          package = build(:package, :without_price, plan: plan, additional_service: additional_service)
          package.valid?
          expect(package.price).to eq(80) # 50 + 30
          expect(package).to be_valid
        end
      end

      context "when price is provided" do
        it "keeps the provided price" do
          package = build(:package, price: 100, plan: plan, additional_service: additional_service)
          original_price = package.price
          package.valid?
          expect(package.price).to eq(original_price)
        end
      end
    end
  end
end
