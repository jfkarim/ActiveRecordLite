require 'active_record_lite/associatable'

describe "AssocOptions" do
  describe "BelongsToOptions" do
    it "provides defaults" do
      options = BelongsToOptions.new("house")

      expect(options.foreign_key).to eq(:house_id)
      expect(options.class_name).to eq("House")
      expect(options.primary_key).to eq(:id)
    end

    it "allows overrides" do
      options = BelongsToOptions.new("owner", {
          foreign_key: :human_id,
          class_name: "Human",
          primary_key: :human_id
        })

      expect(options.foreign_key).to eq(:human_id)
      expect(options.class_name).to eq("Human")
      expect(options.primary_key).to eq(:human_id)
    end
  end

  describe "HasManyOptions" do
    it "provides defaults" do
      options = HasManyOptions.new("dogs", "Human")

      expect(options.foreign_key).to eq(:human_id)
      expect(options.class_name).to eq("Dog")
      expect(options.primary_key).to eq(:id)
    end

    it "allows overrides" do
      options = HasManyOptions.new("dogs", "Human", {
          foreign_key: :owner_id,
          class_name: "Puppy",
          primary_key: :human_id
        })

      expect(options.foreign_key).to eq(:owner_id)
      expect(options.class_name).to eq("Puppy")
      expect(options.primary_key).to eq(:human_id)
    end
  end

  describe "AssocOptions" do
    before(:all) do
      class Dog < SQLObject
      end

      class Human < SQLObject
        self.table_name = "humans"
      end
    end

    it "#model_class returns class of associated object" do
      options = BelongsToOptions.new("human")
      expect(options.model_class).to eq(Human)
      expect(options.table_name).to eq("humans")

      options = HasManyOptions.new("dogs", "Human")
      expect(options.model_class).to eq(Dog)
      expect(options.table_name).to eq("dogs")
    end
  end
end

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

  describe "#belongs_to" do
    let(:spike) { Dog.find(1) }
    let(:bruce) { Human.find(1) }

    it "fetches `human` from `Dog` correctly" do
      expect(spike).to respond_to(:human)
      human = spike.human

      expect(human).to be_instance_of(Human)
      expect(human.fname).to eq("Bruce")
    end

    it "fetches `house` from `Human` correctly" do
      expect(bruce).to respond_to(:house)
      house = bruce.house

      expect(house).to be_instance_of(House)
      expect(house.address).to eq("200 Cherry Rd")
    end
  end

  describe "#has_many" do
    let(:obama) { Human.find(3) }
    let(:obama_house) { House.find(2) }

    it "fetches `dogs` from `Human`" do
      expect(obama).to respond_to(:dogs)
      dogs = obama.dogs

      expect(dogs.length).to eq(2)

      expected_dog_names = ["Frank", "Maya"]
      2.times do |i|
        dog = dogs[i]

        expect(dog).to be_instance_of(Dog)
        expect(dog.name).to eq(expected_dog_names[i])
      end
    end

    it "fetches `humans` from `House`" do
      expect(obama_house).to respond_to(:humans)
      humans = obama_house.humans

      expect(humans.length).to eq(1)
      expect(humans[0]).to be_instance_of(Human)
      expect(humans[0].fname).to eq("Barack")
    end
  end
end
