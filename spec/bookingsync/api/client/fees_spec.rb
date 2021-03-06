require "spec_helper"

describe BookingSync::API::Client::Fees do
  let(:client) { BookingSync::API::Client.new(test_access_token) }

  before { |ex| @casette_base_path = casette_path(casette_dir, ex.metadata) }

  describe ".fees", :vcr do
    it "returns fees" do
      expect(client.fees).not_to be_empty
      assert_requested :get, bs_url("fees")
    end
  end

  describe ".fee", :vcr do
    let(:prefetched_fee_id) {
      find_resource("#{@casette_base_path}_fees/returns_fees.yml", "fees")[:id]
    }

    it "returns a single fee" do
      fee = client.fee(prefetched_fee_id)
      expect(fee.id).to eq prefetched_fee_id
    end
  end

  describe ".create_fee", :vcr do
    let(:attributes) do
      {
        name_en: "New fee",
        rate: 10,
        rate_kind: "fixed",
        downpayment_percentage: 10
      }
    end

    it "creates a new fee" do
      client.create_fee(attributes)
      assert_requested :post, bs_url("fees"),
        body: { fees: [attributes] }.to_json
    end

    it "returns newly created fee" do
      VCR.use_cassette("BookingSync_API_Client_Fees/_create_fee/creates_a_new_fee") do
        fee = client.create_fee(attributes)
        expect(fee.name).to eq(en: "New fee")
        expect(fee.rate).to eq "10.0"
        expect(fee.rate_kind).to eq "fixed"
        expect(fee.downpayment_percentage).to eq "10.0"
      end
    end
  end
end
