require 'rails_helper'

RSpec.describe Client, type: :model do
  describe "validations" do
    it { should validate_presence_of(:name) }
    it { should validate_presence_of(:age) }
    it { should validate_numericality_of(:age).is_greater_than_or_equal_to(18) }
  end
end
