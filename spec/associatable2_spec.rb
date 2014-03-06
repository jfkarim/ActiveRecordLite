require 'active_record_lite/associatable'

describe "Associatable" do
  before(:each) { DBConnection.reset }
  after(:each) { DBConnection.reset }

  before(:all) do
    class Dog < SQLObject
      belongs_to :human, foreign_key: :owner_id
    end

    class Human < SQLObject
      self.table_name = "humans"
      has_many :dogs, foreign_key: :owner_id
      belongs_to :house
    end

    class House < SQLObject
      has_many :humans
    end
  end

  describe "::assoc_options" do
    it "defaults to empty hash" do
      class TempClass < SQLObject
      end

      expect(TempClass.assoc_options).to eq({})
    end

    it "stores `belongs_to` options" do
      dog_assoc_options = Dog.assoc_options
      human_options = dog_assoc_options[:human]

      expect(human_options).to be_instance_of(BelongsToOptions)
      expect(human_options.foreign_key).to eq(:owner_id)
      expect(human_options.class_name).to eq("Human")
      expect(human_options.primary_key).to eq(:id)
    end

    it "stores options separately for each class" do
      expect(Dog.assoc_options).to have_key(:human)
      expect(Human.assoc_options).to_not have_key(:human)

      expect(Human.assoc_options).to have_key(:house)
      expect(Dog.assoc_options).to_not have_key(:house)
    end
  end

  describe "#has_one_through" do
    before(:all) do
      class Dog
        has_one_through :home, :human, :house
      end
    end

    let(:dog) { Dog.find(1) }

    it "adds getter method" do
      expect(dog).to respond_to(:home)
    end

    it "fetches associated `home` for a `Dog`" do
      house = dog.home

      expect(house).to be_instance_of(House)
      expect(house.address).to eq("200 CHerry Rd")
    end
  end
end
