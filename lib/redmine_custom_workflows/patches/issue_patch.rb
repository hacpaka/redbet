# encoding: utf-8
#
# Redmine plugin for Custom Workflows
#
# Copyright Anton Argirov
# Copyright Karel Pičman <karel.picman@kontron.com>
#
# This program is free software; you can redistribute it and/or
# modify it under the terms of the GNU General Public License
# as published by the Free Software Foundation; either version 2
# of the License, or (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program; if not, write to the Free Software
# Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.

module RedmineCustomWorkflows
	module Patches
		module IssuePatch

			def self.included(base)
				base.send(:include, InstanceMethods)
				base.class_eval do
					before_save :before_save_custom_workflows
					after_save :after_save_custom_workflows
					before_destroy :before_destroy_custom_workflows
					after_destroy :after_destroy_custom_workflows
					validate :validate_status

					def self.attachments_callback(event, issue, attachment)
						issue.instance_variable_set(:@issue, issue)
						issue.instance_variable_set(:@attachment, attachment)
						CustomWorkflow.run_shared_code(issue) if event.to_s.starts_with? 'before_'
						CustomWorkflow.run_custom_workflows(:issue_attachments, issue, event)
					end

					[:before_add, :before_remove, :after_add, :after_remove].each do |observable|
						send("#{observable}_for_attachments") << if Rails::VERSION::MAJOR >= 4
																	 lambda { |event, issue, attachment| Issue.attachments_callback(event, issue, attachment) }
																 else
																	 lambda { |issue, attachment| Issue.attachments_callback(observable, issue, attachment) }
																 end
					end
				end
			end

			module InstanceMethods

				def validate_status
					return true unless @saved_attributes && @saved_attributes['status_id'] != status_id &&
						!new_statuses_allowed_to(User.current, new_record?).collect(&:id).include?(status_id)

					status_was = IssueStatus.find_by_id(status_id_was)
					status_new = IssueStatus.find_by_id(status_id)

					errors.add :status, :new_status_invalid,
							   :old_status => status_was && status_was.name,
							   :new_status => status_new && status_new.name
				end

				def before_save_custom_workflows
					@issue = self
					@saved_attributes = attributes.dup
					CustomWorkflow.run_shared_code(self)
					CustomWorkflow.run_custom_workflows(:issue, self, :before_save)
					throw :abort if errors.any?
					errors.empty? && (@saved_attributes == attributes || valid?)
				ensure
					@saved_attributes = nil
				end

				def after_save_custom_workflows
					CustomWorkflow.run_custom_workflows(:issue, self, :after_save)
				end

				def before_destroy_custom_workflows
					CustomWorkflow.run_custom_workflows(:issue, self, :before_destroy)
				end

				def after_destroy_custom_workflows
					CustomWorkflow.run_custom_workflows(:issue, self, :after_destroy)
				end

			end

		end
	end
end

unless Issue.include?(RedmineCustomWorkflows::Patches::IssuePatch)
	Issue.send(:include, RedmineCustomWorkflows::Patches::IssuePatch)
end
