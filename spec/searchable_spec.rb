require 'active_record_lite/searchable'

describe "Searchable" do
  before(:each) { DBConnection.reset }
  after(:each) { DBConnection.reset }

  before(:all) do
    class Dog < SQLObject
    end

    class Human < SQLObject
      self.table_name = "humans"
    end
  end

  it "#where searches with single criterion" do
    dogs = Dog.where(name: "Spike")
    dog = dogs.first

    expect(dogs.length).to eq(1)
    expect(dog.name).to eq("Spike")
  end

  it "#where can return multiple objects" do
    humans = Human.where(house_id: 1)
    expect(humans.length).to eq(2)
  end

  it "#where searches with multiple criteria" do
    humans = Human.where(fname: "Bruce", house_id: 1)
    expect(humans.length).to eq(1)

    human = humans[0]
    expect(human.fname).to eq("Bruce")
    expect(human.house_id).to eq(1)
  end
end
