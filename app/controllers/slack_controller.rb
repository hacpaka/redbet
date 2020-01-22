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

class SlackController < ApplicationController
	layout 'admin'
	self.main_menu = false

	before_action :require_admin

	def index
		@url = Setting.slack_url

		respond_to do |format|
			format.html
		end
	end

	def update
		respond_to do |format|
			Setting[:slack_url] = params[:settings][:slack_url]

			if Setting
				flash[:notice] = l(:notice_successful_update)
			end

			format.html { redirect_to(slack_path) }
		end
	end
end
