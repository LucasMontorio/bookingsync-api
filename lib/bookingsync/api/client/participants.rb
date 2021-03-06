module BookingSync::API
  class Client
    module Participants
      # List participants
      #
      # Returns all participants supported in BookingSync.
      # @param options [Hash] A customizable set of options.
      # @option options [Array] fields: List of fields to be fetched.
      # @return [Array<BookingSync::API::Resource>] Array of participants.
      #
      # @example Get the list of participants for the current account
      #   participants = @api.participants
      #   participants.first.read_at # => "Fri, 02 Mar 2018 17:06:41 UTC +00:00"
      # @see http://developers.bookingsync.com/reference/endpoints/participants/#list-participants
      def participants(options = {}, &block)
        paginate "inbox/participants", options, &block
      end

      # Get a single participant
      #
      # @param participant [BookingSync::API::Resource|Integer] Participant or ID
      #   of the participant.
      # @return [BookingSync::API::Resource]
      def participant(participant)
        get("inbox/participants/#{participant}").pop
      end

      # Create a new participant
      #
      # @param options [Hash] Participant's attributes.
      # @return [BookingSync::API::Resource] Newly created participant.
      def create_participant(options)
        post("inbox/participants", participants: [options]).pop
      end

      # Edit a participant
      #
      # @param participant [BookingSync::API::Resource|Integer] Participant or ID of
      #   the participant to be updated.
      # @param options [Hash] Participant attributes to be updated.
      # @return [BookingSync::API::Resource] Updated participant on success,
      #   exception is raised otherwise.
      # @example
      #   participant = @api.participants.first
      #   @api.edit_participant(participant, { read: true })
      def edit_participant(participant, options = {})
        put("inbox/participants/#{participant}", participants: [options]).pop
      end
    end
  end
end
