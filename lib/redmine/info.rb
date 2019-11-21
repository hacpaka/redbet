# frozen_string_literal: true

module Redmine
	module Info
		class << self
			def app_name;
				'Redmine'
			end

			def url;
				'https://www.redmine.org/'
			end

			def versioned_name;
				"#{app_name} #{Redmine::VERSION}"
			end

			def environment
				s = +"Environment:\n"
				s << [
					["Redmine version", Redmine::VERSION],
					["Ruby version", "#{RUBY_VERSION}-p#{RUBY_PATCHLEVEL} (#{RUBY_RELEASE_DATE}) [#{RUBY_PLATFORM}]"],
					["Rails version", Rails::VERSION::STRING],
					["Environment", Rails.env],
					["Database adapter", ActiveRecord::Base.connection.adapter_name],
					["Mailer queue", ActionMailer::DeliveryJob.queue_adapter.class.name],
					["Mailer delivery", ActionMailer::Base.delivery_method]
				].map { |info| "  %-30s %s" % info }.join("\n") + "\n"

				s << "Redmine plugins:\n"
				plugins = Redmine::Plugin.all
				if plugins.any?
					s << plugins.map { |plugin| "  %-30s %s" % [plugin.id.to_s, plugin.version.to_s] }.join("\n")
				else
					s << "  no plugin installed"
				end
			end
		end
	end
end
