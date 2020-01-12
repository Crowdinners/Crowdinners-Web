class Server
    class DeployInfo
        include Mongoid::Document
        embedded_in :server

        field :nextgen, type: Hash
        field :packages, type: Hash

        attr_accessible :nextgen, :packages
    end

    module Deployment
        extend ActiveSupport::Concern
        include Lifecycle

        included do
            # The ID of a virtual machine (ie. Droplet) that deploys this server.
            field :machine_id, default: nil

            # The following paths are relative to the folders in this repository:
            # https://github.com/Crowdinners/Crowdinners-Data
            field :server_path,    type: String, default: -> {bungee? ? "bungee" : "bukkit"}.freeze
            field :plugins_path,   type: String, default: "base".freeze
            field :rotations_path, type: String, default: "default".freeze

            # The path and branch for the (private) Maps repository.
            field :maps_path,   type: String, default: "/".freeze
            field :maps_branch, type: String, default: "master".freeze

            properties2 = [:server_path, :plugins_path, :rotations_path, :maps_path, :rotations_path]

            api_property    :machine_id, *properties2
            attr_accessible :machine_id, *properties2
            attr_cloneable *properties2

            # Path to the update-server script in the Nextgen root folder.
            # This field is set on the API side to tell the server where to update
            # itself from. This can be used to switch a server to an alternate Nextgen
            # repo for beta testing and such.
            #
            # This path is copied to a script in the server's folder as part of the
            # update process, and is then used as the source for the next update.
            # A server must be restarted twice before a change to this field is effective:
            # Once to copy the new path, and again to update from that path.
            #
            # TODO: Find a less wacky way to do this
            field :update_server_path, type: String, default: nil

            # Directory this server is deployed to on its box
            field :deploy_path, type: String, default: nil


            ### Fields reported by the server on startup

            # Most recent plugin versions reported by the server at startup
            field :plugin_versions, type: Hash, default: {}.freeze

            # Info generated by Nextgen and reported by the server at startup
            # Can be nil if the server could not load the deploy.json file
            embeds_one :deploy_info, class_name: 'Server::DeployInfo'

            field :protocol_versions, type: Array, default: -> { [] }

            properties = [:plugin_versions, :update_server_path, :deploy_path, :deploy_info, :protocol_versions]
            attr_accessible *properties
            api_property *properties

            attr_cloneable :update_server_path

            before_event :startup do
                self.plugin_versions ||= {}
                true
            end
        end # included do

        def deployed_sha(package = nil)
            if deploy_info
                if package
                    deploy_info.packages[package.to_s].try!(:[], 'commit')
                else
                    deploy_info.nextgen['version']['commit']
                end
            end
        end

        def application_package
            if bungee?
                'BungeeCord'
            else
                'SportBukkit'
            end
        end

        def deployed_application_sha
            deployed_sha(application_package)
        end

        def deployed_revision(package = nil)
            if repo = package.nil? ? Repository[:nextgen] : Repository.by_repo(package) and commit = deployed_sha(package)
                repo.revision(commit)
            end
        end

        def deployed_application_revision
            deployed_revision(application_package)
        end

        def latest_plugin_revision(revisions = nil)
            if commit = deployed_sha('Plugins')
                if revisions
                    revisions.find{|r| r.sha == commit }
                else
                    Repository[:projectares].revision(commit)
                end
            end
        end

        module ClassMethods
            def deployed_sha(*sha)
                self.in('deploy_info.nextgen.version.commit' => sha)
            end

            def deployed_since(t)
                deployed_sha(*Repository[:nextgen].revisions(since: t).map(&:sha))
            end
        end
    end # Deployment
end
