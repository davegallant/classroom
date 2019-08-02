# frozen_string_literal: true

module GitHubClassroom
  module LTI
    class MembershipService
      include Mixins::RequestSigning

      def initialize(context_membership_url, consumer_key, shared_secret)
        @context_membership_url = context_membership_url
        @consumer_key = consumer_key
        @secret = shared_secret
      end

      def students
        membership(roles: %w[Student Learner])
      end

      def instructors
        membership(roles: %w[Instructor])
      end

      def membership(roles: [])
        #byebug
        #headers = { "Accept": "application/vnd.ims.lis.v2.membershipcontainer+json" }
        #request = signed_request(@context_membership_url, @consumer_key, @secret,
        #  query: { role: roles.join(",") },
        #  headers: headers)
        #response = request.get
        #byebug

        req = membership_request(roles)

        byebug
        response = req.get

        json_membership = JSON.parse(response.body)
        parsed_membership = parse_membership(json_membership)
        parsed_membership
      end

      private

      def membership_request(roles)

        req = signed_request(
          @context_membership_url,
          method: :get,
          headers: { "Accept": "application/vnd.ims.lis.v2.membershipcontainer+json" },
          query: { role: roles.join(",") }
        )

        #headers = {
        #  "Accept": "application/vnd.ims.lis.v2.membershipcontainer+json",
        #  "Authorization": req.get_fields("Authorization")[0]
        #}

        #Faraday.new(url: req.uri, headers: headers) do |conn|
        #  conn.response :raise_error
        #  conn.adapter Faraday.default_adapter
        #end
      end

      def parse_membership(json_membership)
        unparsed_memberships = json_membership.dig("pageOf", "membershipSubject", "membership")
        raise JSON::ParserError unless unparsed_memberships

        unparsed_memberships.map do |unparsed_membership|
          membership_hash = unparsed_membership.deep_transform_keys { |key| key.underscore.to_sym }
          member_hash = membership_hash[:member]

          parsed_member = IMS::LTI::Models::MembershipService::LISPerson.new(member_hash)
          membership_hash[:member] = parsed_member

          IMS::LTI::Models::MembershipService::Membership.new(membership_hash)
        end
      end
    end
  end
end
