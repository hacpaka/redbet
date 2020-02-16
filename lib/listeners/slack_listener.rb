require 'httpclient'

class SlackListener < Redmine::Hook::Listener
	def slack_after_create(context = {})
		issue = context[:issue]

		url = url_for_project issue.project

		return unless url
		return if issue.is_private?

		msg = "[#{escape issue.project}] #{escape issue.author} created <#{object_url issue}|#{escape issue}>#{mentions issue.description}"

		abort(msg)

		# attachment = {}
		# attachment[:text] = escape issue.description if issue.description
		# attachment[:fields] = [{
		# 						   :title => I18n.t("field_status"),
		# 						   :value => escape(issue.status.to_s),
		# 						   :short => true
		# 					   }, {
		# 						   :title => I18n.t("field_priority"),
		# 						   :value => escape(issue.priority.to_s),
		# 						   :short => true
		# 					   }, {
		# 						   :title => I18n.t("field_assigned_to"),
		# 						   :value => escape(issue.assigned_to.to_s),
		# 						   :short => true
		# 					   }]
		#
		# attachment[:fields] << {
		# 	:title => I18n.t("field_watcher"),
		# 	:value => escape(issue.watcher_users.join(', ')),
		# 	:short => true
		# } if Setting.plugin_redmine_slack['display_watchers'] == 'yes'

		speak msg, "", "", channel
	end

	def slack_after_update(context = {})
		issue = context[:issue]
		return if issue.is_private?

		journal = context[:journal]
		return if journal.private_notes?

		email = journal.user.email_address.to_s
 		msg = "<#{object_url issue.project}|[#{escape issue.project}]> {{email:#{escape email }}} updated <#{object_url issue}|#{escape issue}>"

		quotes = []
		quotes.push({:text => "#{escape journal.notes}"}) if journal.notes

		fields = []
		journal.details.map { |d| detail_to_field d }
		 	.select{|v| %w[Status Assignee Priority].include? v[:title] }
			.each{|v| fields.push({ :name => v[:title], :value => v[:value], :formatted => v[:title] == "Status" ? true : false }) }

		speak msg, quotes, fields, email
	end

	def speak(msg, quotes, fields, email)
		url = Setting.slack_url + "?emails=" + email

		struct = {
			:text => msg,
			:quotes => quotes,
			:fields => fields,
		}

		begin
			client = HTTPClient.new
			client.ssl_config.cert_store.set_default_paths
			client.ssl_config.ssl_version = :auto
			client.post_async url, struct.to_json
		rescue Exception => e
			Rails.logger.warn("cannot connect to #{url}")
			Rails.logger.warn(e)
		end
	end

	private

	def escape(msg)
		msg.to_s.gsub("&", "&amp;").gsub("<", "&lt;").gsub(">", "&gt;")
	end

	def object_url(obj)
		if Setting.host_name.to_s =~ /\A(https?\:\/\/)?(.+?)(\:(\d+))?(\/.+)?\z/i
			host, port, prefix = $2, $4, $5
			Rails.application.routes.url_for(obj.event_url({
															   :host => host,
															   :protocol => Setting.protocol,
															   :port => port,
															   :script_name => prefix
														   }))
		else
			Rails.application.routes.url_for(obj.event_url({
															   :host => Setting.host_name,
															   :protocol => Setting.protocol
														   }))
		end
	end

	def detail_to_field(detail)
		case detail.property
		when "cf"
			custom_field = detail.custom_field
			key = custom_field.name
			title = key
			value = (detail.value) ? IssuesController.helpers.format_value(detail.value, custom_field) : ""
		when "attachment"
			key = "attachment"
			title = I18n.t :label_attachment
			value = escape detail.value.to_s
		else
			key = detail.prop_key.to_s.sub("_id", "")
			if key == "parent"
				title = I18n.t "field_#{key}_issue"
			else
				title = I18n.t "field_#{key}"
			end
			value = escape detail.value.to_s
		end

		short = true

		case key
		when "title", "subject", "description"
			short = false
		when "tracker"
			tracker = Tracker.find(detail.value) rescue nil
			value = escape tracker.to_s
		when "project"
			project = Project.find(detail.value) rescue nil
			value = escape project.to_s
		when "status"
			status = IssueStatus.find(detail.value) rescue nil
			value = escape status.to_s
		when "priority"
			priority = IssuePriority.find(detail.value) rescue nil
			value = escape priority.to_s
		when "category"
			category = IssueCategory.find(detail.value) rescue nil
			value = escape category.to_s
		when "assigned_to"
			user = User.find(detail.value) rescue nil
			value = "{{email:#{user.email_address.to_s}}}"
		when "fixed_version"
			version = Version.find(detail.value) rescue nil
			value = escape version.to_s
		when "attachment"
			attachment = Attachment.find(detail.prop_key) rescue nil
			value = "<#{object_url attachment}|#{escape attachment.filename}>" if attachment
		when "parent"
			issue = Issue.find(detail.value) rescue nil
			value = "<#{object_url issue}|#{escape issue}>" if issue
		end

		value = "-" if value.empty?

		result = {:title => title, :value => value}
		result[:short] = true if short
		result
	end

	def mentions text
		return nil if text.nil?
		names = extract_usernames text
		names.present? ? "\nTo: " + names.join(', ') : nil
	end

	def extract_usernames text = ''
		if text.nil?
			text = ''
		end

		# slack usernames may only contain lowercase letters, numbers,
		# dashes and underscores and must start with a letter or number.
		text.scan(/@[a-z0-9][a-z0-9_\-]*/).uniq
	end
end
