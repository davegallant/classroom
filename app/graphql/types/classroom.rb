require_relative "../loaders/github_loader"

def organization_query(obj, fields)
  <<-GRAPHQL
    node(id: "#{obj.github_global_relay_id}"){
      ... on Organization {
        #{fields}
      }
    }
  GRAPHQL
end

class Types
  class Classroom < GraphQL::Schema::Object
    # To see an organization, you must be an organization owner
    def self.authorized?(organization, context)
      super && context[:current_user] && organization.users.include?(context[:current_user])
    end

    implements GraphQL::Relay::Node.interface

    field :database_id, Integer, description: "The Classroom database ID", null: false

    def database_id
      object.id
    end

    field :title, String, description: "The Classroom title.", null: false

    field :slug, String, description: "The Classroom slug for use in URLs.", null: false

    field :github_id, String, description: "The Organization GitHub ID.", null: false

    def github_id
      object.github_id
    end

    field :github_url, String, description: "The organization's GitHub URL", null: true

    def github_url
      GitHubClassroom::GitHubLoader.load(organization_query(object, "url"), context: context).then do |results|
        results.dig("data", "node", "url")
      end
    end

    field :organization_login, String, description: "The Classroom organization login.", null: false

    def organization_login
      GitHubClassroom::GitHubLoader.load(organization_query(object, "login"), context: context).then do |results|
        results.dig("data", "node", "login")
      end
    end

    field :assignments, Types::Assignment.connection_type, description: "Assignments in the Classroom", null: true, connection: true

    def assignments
      assignments = object.assignments
    end
  end
end