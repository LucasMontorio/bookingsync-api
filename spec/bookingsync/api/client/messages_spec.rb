require "spec_helper"

describe BookingSync::API::Client::Messages do
  let(:client) { BookingSync::API::Client.new(test_access_token) }

  before { |ex| @casette_base_path = casette_path(casette_dir, ex.metadata) }

  describe ".messages", :vcr do
    it "returns messages" do
      expect(client.messages).not_to be_empty
      assert_requested :get, bs_url("inbox/messages")
    end
  end

  describe ".message", :vcr do
    let(:prefetched_message_id) {
      find_resource("#{@casette_base_path}_messages/returns_messages.yml", "messages")[:id]
    }

    it "returns a single message" do
      message = client.message(prefetched_message_id)
      expect(message.id).to eq prefetched_message_id
    end
  end

  describe ".create_message", :vcr do
    let(:conversation) { BookingSync::API::Resource.new(client, id: 1) }
    let(:participant) { BookingSync::API::Resource.new(client, id: 1) }
    let(:attributes) do
      {
        content: "Message content",
        origin: "homeaway",
        visibility: "all",
        conversation_id: conversation.id,
        sender_id: participant.id
      }
    end

    it "creates a new message" do
      client.create_message(attributes)
      assert_requested :post, bs_url("inbox/messages"),
        body: { messages: [attributes] }.to_json
    end

    it "returns newly created message" do
      VCR.use_cassette("BookingSync_API_Client_Messages/_create_message/creates_a_new_message") do
        message = client.create_message(attributes)
        expect(message.content).to eq("Message content")
        expect(message.origin).to eq("homeaway")
        expect(message.visibility).to eq("all")
      end
    end
  end

  describe ".edit_message", :vcr do
    let(:attributes) {
      { content: "Updated message content" }
    }
    let(:created_message_id) {
      find_resource("#{@casette_base_path}_create_message/creates_a_new_message.yml", "messages")[:id]
    }

    it "updates given message by ID" do
      client.edit_message(created_message_id, attributes)
      assert_requested :put, bs_url("inbox/messages/#{created_message_id}"),
        body: { messages: [attributes] }.to_json
    end

    it "returns updated message" do
      VCR.use_cassette("BookingSync_API_Client_Messages/_edit_message/updates_given_message_by_ID") do
        message = client.edit_message(created_message_id, attributes)
        expect(message).to be_kind_of(BookingSync::API::Resource)
        expect(message.content).to eq("Updated message content")
      end
    end
  end

  describe ".add_attachment_to_message", :vcr do
    let(:attachment_to_be_added) { BookingSync::API::Resource.new(client, id: 1) }
    let(:prefetched_message_id) {
      find_resource("#{@casette_base_path}_messages/returns_messages.yml", "messages")[:id]
    }
    let(:attributes) { { id: attachment_to_be_added.id } }

    it "adds attachment to given message" do
      client.add_attachment_to_message(prefetched_message_id, attributes)
      assert_requested :put, bs_url("inbox/messages/#{prefetched_message_id}/add_attachment"),
        body: { attachments: [attributes] }.to_json
    end

    it "returns message with updated links" do
      casette_path = "BookingSync_API_Client_Messages/_add_attachment_to_message" \
                     "/adds_attachment_to_given_message"
      VCR.use_cassette(casette_path) do
        expect { client.add_attachment_to_message(prefetched_message_id, attributes) }
          .to change { client.message(prefetched_message_id)[:links][:attachments] }
          .from([])
          .to([attachment_to_be_added.id])
      end
    end
  end
end
