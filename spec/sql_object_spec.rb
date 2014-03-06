require 'active_record_lite/sql_object'
require 'securerandom'

describe SQLObject do
  before(:each) { DBConnection.reset }
  after(:each) { DBConnection.reset }

  before(:all) do
    class Dog < SQLObject
    end

    class Human < SQLObject
      self.table_name = "humans"
    end
  end

  describe "::set_table/::table_name" do
    it "::set_table_name sets table name" do
      expect(Human.table_name).to eq("humans")
    end

    it "::table_name generates default name" do
      expect(Dog.table_name).to eq("dogs")
    end

    it "::parse_all turns an array of hashes into objects" do
      hashes = [
        { name: "dog1", owner_id: 1 },
        { name: "dog2", owner_id: 2 }
      ]

      dogs = Dog.parse_all(hashes)
      expect(dogs.length).to eq(2)
      hashes.each_index do |i|
        expect(dogs[i].name).to eq(hashes[i][:name])
        expect(dogs[i].owner_id).to eq(hashes[i][:owner_id])
      end
    end
  end

  describe "::all/::find" do
    it "::all returns all the dogs" do
      dogs = Dog.all

      expect(dogs.count).to eq(4)
      dogs.all? { |dog| expect(dog).to be_instance_of(Dog) }
    end

    it "::find finds objects by id" do
      c = Dog.find(1)

      expect(c).not_to be_nil
      expect(c.name).to eq("Spike")
    end
  end

  describe "#insert" do
    let(:dog) { Dog.new(name: "Gizmo", owner_id: 1) }

    before(:each) { dog.insert }

    it "#attribute_values returns array of values" do
      dog = Dog.new(id: 123, name: "dog1", owner_id: 1)

      expect(dog.attribute_values).to eq([123, "dog1", 1])
    end

    it "#insert inserts a new record" do
      expect(Dog.all.count).to eq(5)
    end

    it "#insert sets the id" do
      expect(dog.id).to_not be_nil
    end

    it "#insert creates record with proper values" do
      # pull the dog again
      dog2 = Dog.find(dog.id)

      expect(dog2.name).to eq("Gizmo")
      expect(dog2.owner_id).to eq(1)
    end
  end

  describe "#update" do
    it "#update changes attributes" do
      human = Human.find(2)

      human.fname = "Vladmir"
      human.lname = "Putin"
      human.update

      # pull the human again
      human = Human.find(2)
      expect(human.fname).to eq("Vladmir")
      expect(human.lname).to eq("Putin")
    end
  end

  describe "#save" do
    it "#save calls save/update as appropriate" do
      human = Human.new
      expect(human).to receive(:insert)
      human.save

      human = Human.find(1)
      expect(human).to receive(:update)
      human.save
    end
  end
end
