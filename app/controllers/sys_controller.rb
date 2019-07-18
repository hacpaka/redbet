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

class SysController < ActionController::Base
	before_action :check_enabled

	def projects
		p = Project.active.has_module(:repository).
			order("#{Project.table_name}.identifier").preload(:repository).to_a
		# extra_info attribute from repository breaks activeresource client
		render :json => p.to_json(
			:only => [:id, :identifier, :name, :is_public, :status],
			:include => {:repository => {:only => [:id, :url]}}
		)
	end

	protected

	def check_enabled
		User.current = nil
		unless Setting.sys_api_enabled? && params[:key].to_s == Setting.sys_api_key
			render :plain => 'Access denied. Repository management WS is disabled or key is invalid.', :status => 403
			return false
		end
	end
end
