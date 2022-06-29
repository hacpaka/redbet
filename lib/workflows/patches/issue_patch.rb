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

module Workflows
	module Patches

		module IssuePatch

			def self.included(base)
				base.send(:include, InstanceMethods)

				base.class_eval do
					before_save :before_save_custom_workflow
					after_save :after_save_custom_workflow
					before_destroy :before_destroy_custom_workflow
					after_destroy :after_destroy_custom_workflow
				end
			end

			module InstanceMethods

				def before_save_custom_workflow
					@issue = self
					@saved_attributes = attributes.dup
					CustomWorkflow.run_shared_code(self)
					CustomWorkflow.run_custom_workflow(:issue, self, :before_save)
					throw :abort if errors.any?
					errors.empty? && (@saved_attributes == attributes || valid?)
				ensure
					@saved_attributes = nil
				end

				def after_save_custom_workflow
					CustomWorkflow.run_custom_workflow(:issue, self, :after_save)
				end

				def before_destroy_custom_workflow
					CustomWorkflow.run_custom_workflow(:issue, self, :before_destroy)
				end

				def after_destroy_custom_workflow
					CustomWorkflow.run_custom_workflow(:issue, self, :after_destroy)
				end

			end
		end
	end
end

ActiveSupport::Reloader.to_prepare do
	unless Issue.include?(Workflows::Patches::IssuePatch)
		Issue.send(:include,Workflows::Patches::IssuePatch)
	end
end
