require "hypertrack"
require "spec_helper"

describe HyperTrack::Driver do

  describe ".create with invalid args" do
    context "given blank string as args" do
      it "should raise InvalidParameters error" do
        expect { HyperTrack::Driver.create('') }.
        to raise_error(HyperTrack::InvalidParameters, "Error: Expected a Hash. Got: ")
      end
    end

    context "params missing one or all of required attributes" do
      it "should raise InvalidParameters error" do
        expect { HyperTrack::Driver.create({}) }.
        to raise_error(HyperTrack::InvalidParameters, "Request is missing required params - [:name, :vehicle_type]")

        expect { HyperTrack::Driver.create({ vehicle_type: 'car' }) }.
        to raise_error(HyperTrack::InvalidParameters, "Request is missing required params - [:name]")

        expect { HyperTrack::Driver.create({ name: 'foo' }) }.
        to raise_error(HyperTrack::InvalidParameters, "Request is missing required params - [:vehicle_type]")
      end
    end

    context "params containing invalid values for vehicle_type attribute" do
      it "should raise InvalidParameters error" do
        expect { HyperTrack::Driver.create({ name: 'foo', vehicle_type: 'random' }) }.
        to raise_error(HyperTrack::InvalidParameters, /Error: Invalid vehicle_type: random. Allowed/)
      end
    end
  end

  describe ".retrieve with invalid args" do
    context "given blank string or nil as driver_id" do
      it "should raise InvalidParameters error" do
        expect { HyperTrack::Driver.retrieve('') }.
        to raise_error(HyperTrack::InvalidParameters, "ID is required to retrieve a HyperTrack::Driver")

        expect { HyperTrack::Driver.retrieve(nil) }.
        to raise_error(HyperTrack::InvalidParameters, "ID is required to retrieve a HyperTrack::Driver")
      end
    end
  end

  describe "HyperTrack::Driver class methods with valid args should return proper values" do

    before(:all) do
      HyperTrack.secret_key = "abc"

      @driver_params = { id: "unique_driver_id", name: "foo", vehicle_type: "car" }

      @request_headers = {
        Accept: '*/*',
        'Accept-Encoding': 'gzip;q=1.0,deflate;q=0.6,identity;q=0.3',
        Authorization: "token #{HyperTrack.secret_key}",
        'Content-Type': 'application/json',
        'User-Agent': 'Ruby'
      }

      @response_driver_hash = {
        id: @driver_params[:id],
        fleet_id: nil,
        name: @driver_params[:name],
        phone: "",
        photo: nil,
        vehicle_type: @driver_params[:vehicle_type],
        location: nil,
        location_recorded_at: nil,
        created_at: "2016-09-26T19:52:28.561076Z",
        modified_at: "2016-09-26T19:52:28.561110Z",
        is_ontime: nil,
        lookup_id: "",
        last_known_location: {},
        last_heartbeat: nil,
        battery_level: nil,
        is_sendeta: false,
        invite_status: "pending"
      }
    end

    context ".create with valid args" do
      it "should return a HyperTrack::Driver object" do

        stub_request(:post, "#{HyperTrack::ApiClient::BASE_URL}/#{HyperTrack::ApiClient::API_VERSION}/#{HyperTrack::Driver::API_BASE_PATH}").
          with({
            body: { name: @driver_params[:name], vehicle_type: @driver_params[:vehicle_type] }.to_json,
            headers: @request_headers
          }).
          to_return({ body: @response_driver_hash.to_json, status: 200 })

        driver_object = HyperTrack::Driver.create({ name: @driver_params[:name], vehicle_type: @driver_params[:vehicle_type] })

        expect(driver_object).to be_an_instance_of HyperTrack::Driver
        expect(driver_object.id).to eq(@driver_params[:id])
        expect(driver_object.name).to eq(@driver_params[:name])
        expect(driver_object.vehicle_type).to eq(@driver_params[:vehicle_type])
      end
    end

    context ".retrieve with valid args" do
      it "should return a HyperTrack::Driver object" do

        stub_request(:get, "#{HyperTrack::ApiClient::BASE_URL}/#{HyperTrack::ApiClient::API_VERSION}/#{HyperTrack::Driver::API_BASE_PATH}#{@driver_params[:id]}/").
          with({ headers: @request_headers }).
          to_return({ body: @response_driver_hash.to_json, status: 200 })

        driver_object = HyperTrack::Driver.retrieve(@driver_params[:id])

        expect(driver_object).to be_an_instance_of HyperTrack::Driver
        expect(driver_object.id).to eq(@driver_params[:id])
        expect(driver_object.name).to eq(@driver_params[:name])
        expect(driver_object.vehicle_type).to eq(@driver_params[:vehicle_type])
      end
    end

    context ".list with valid args" do
      it "should return an array of HyperTrack::Driver object(s)" do
        stub_request(:get, "#{HyperTrack::ApiClient::BASE_URL}/#{HyperTrack::ApiClient::API_VERSION}/#{HyperTrack::Driver::API_BASE_PATH}").
          with({ headers: @request_headers }).
          to_return({ body: { count: 1, results: [@response_driver_hash] }.to_json, status: 200 })

        driver_list = HyperTrack::Driver.list

        expect(driver_list['count']).to eq(1)
        expect(driver_list['results'][0]).to be_an_instance_of HyperTrack::Driver
        expect(driver_list['results'][0].id).to eq(@driver_params[:id])
        expect(driver_list['results'][0].name).to eq(@driver_params[:name])
        expect(driver_list['results'][0].vehicle_type).to eq(@driver_params[:vehicle_type])
      end
    end
  end

end
