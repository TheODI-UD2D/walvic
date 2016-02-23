describe Walvic do

  let (:walvic) { described_class.new('euston', 'southbound') }
  let (:now) { DateTime.parse("2016-01-01T16:20:00") }

  before(:each) do
    Timecop.travel(now)
  end

  after(:each) do
    Timecop.return
  end

  it 'generates the correct URL' do
    expect(walvic.url).to eq('http://goingunderground.herokuapp.com/stations/arriving/euston/southbound/2015-09-23T16:20:00.json')
  end

end
