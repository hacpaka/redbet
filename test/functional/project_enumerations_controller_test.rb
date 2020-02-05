# frozen_string_literal: true

# Redmine - project management software
# Copyright (C) 2006-2019  Jean-Philippe Lang
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

require File.expand_path('../../test_helper', __FILE__)

class ProjectEnumerationsControllerTest < Redmine::ControllerTest
	fixtures :projects, :trackers, :issue_statuses, :issues,
			 :enumerations, :users, :issue_categories,
			 :projects_trackers,
			 :roles,
			 :member_roles,
			 :members,
			 :enabled_modules,
			 :custom_fields, :custom_fields_projects,
			 :custom_fields_trackers, :custom_values,

	self.use_transactional_tests = false

	def setup
		@request.session[:user_id] = nil
		Setting.default_language = 'en'
	end
end
