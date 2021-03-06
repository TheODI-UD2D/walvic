describe Walvic do

  let (:walvic) { described_class.new('euston', 'southbound') }
  let (:now) { DateTime.parse("2016-01-01T16:20:00") }

  before(:each) do
    Timecop.travel(now)
    Walvic::PINS.each do |pin|
      allow(PiPiper::Pin).to receive(:new).with(pin: pin, direction: :out) { instance_double(PiPiper::Pin, pin: pin) }
    end
  end

  after(:each) do
    Timecop.return
  end

  it 'sets up lights on initialize' do
    Walvic::PINS.each_with_index do |v, i|
      expect(walvic.instance_variable_get("@pin_#{i}").pin).to eq(v)
    end
  end

  it 'generates the correct URL' do
    expect(walvic.url).to eq('http://goingunderground.herokuapp.com/stations/arriving/southbound/euston/2015-09-23T16:20:00.json')
  end

  it 'gets some json', :vcr do
    json = walvic.json
    expect(json.count).to eq(10)
    expect(json.first).to eq([
      {
        "segment" => 1193,
        "number" => 0,
        "timeStamp" => "2015-09-23T16:08:39.575Z"
      },
      {
        "CAR_A" => 29.443181818181817,
        "CAR_B" => 17.266666666666666,
        "CAR_C" => 12.931506849315069,
        "CAR_D" => 13.32857142857143
      }
    ])
  end

  it 'gets the average occupancy', :vcr do
    expect(walvic.average_occupancy).to eq(18)
  end

  it 'gets the correct number of lights to illuminate', :vcr do
    expect(walvic.num_lights).to eq(0)
  end

  it 'turns the right lights on and off', :vcr do
    expect(walvic.instance_variable_get("@pin_0")).to receive(:on)
    expect(walvic.instance_variable_get("@pin_0")).to receive(:off)

    walvic.illuminate
  end

end
