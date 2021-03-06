require "spec_helper"

describe BookingSync::API::Client::ApplicationsPeriodsRentals do
  let(:client) { BookingSync::API::Client.new(test_access_token) }

  before { |ex| @casette_base_path = casette_path(casette_dir, ex.metadata) }

  describe ".applications_periods_rentals", :vcr do
    it "returns applications_periods_rentals" do
      expect(client.applications_periods_rentals).not_to be_empty
      assert_requested :get, bs_url("applications_periods_rentals")
    end
  end

  describe ".applications_periods_rental", :vcr do
    let(:prefetched_applications_periods_rental) {
      find_resource("#{@casette_base_path}_applications_periods_rentals/returns_applications_periods_rentals.yml", "applications_periods_rentals")
    }

    it "returns applications_periods_rental" do
      applications_periods_rental = client.applications_periods_rental(prefetched_applications_periods_rental[:id])
      expect(applications_periods_rental.price_increase).to eq(prefetched_applications_periods_rental[:price_increase])
    end
  end

  describe ".create_applications_periods_rental", :vcr do
    let(:attributes) {
      {
        rental_id: 1,
        application_id: 9,
        start_date: "2017-01-03",
        end_date: "2017-01-04",
        price_increase: 15.0
      }
    }

    it "creates a applications_periods_rental" do
      client.create_applications_periods_rental(attributes)
      assert_requested :post, bs_url("applications_periods_rentals"),
        body: { applications_periods_rental: attributes }.to_json
    end

    it "returns newly created applications_periods_rental" do
      VCR.use_cassette("BookingSync_API_Client_Bookings/_create_applications_periods_rental/creates_an_applications_periods_rental") do
        applications_periods_rental = client.create_applications_periods_rental(attributes)
        expect(applications_periods_rental).to be_kind_of(BookingSync::API::Resource)
        expect(applications_periods_rental.price_increase).to eq(attributes[:price_increase].to_s)
      end
    end
  end

  describe ".edit_applications_periods_rental", :vcr do
    let(:prefetched_edit_applications_periods_rental) {
      find_resource("#{@casette_base_path}_applications_periods_rentals/returns_applications_periods_rentals.yml", "applications_periods_rentals")
    }
    let(:price_increase) { 3.1 }

    it "updates given applications_periods_rental by ID" do
      client.edit_applications_periods_rental(prefetched_edit_applications_periods_rental, price_increase: price_increase)
      assert_requested :put, bs_url("applications_periods_rentals/#{prefetched_edit_applications_periods_rental}"),
        body: { applications_periods_rental: { price_increase: price_increase } }.to_json
    end

    it "returns updated applications_periods_rental" do
      applications_periods_rental = client.edit_applications_periods_rental(prefetched_edit_applications_periods_rental, price_increase: price_increase)
      expect(applications_periods_rental).to be_kind_of(BookingSync::API::Resource)
      expect(applications_periods_rental.price_increase).to eq(price_increase.to_s)
    end
  end
end
