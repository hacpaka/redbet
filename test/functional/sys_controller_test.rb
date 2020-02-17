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

class SysControllerTest < Redmine::ControllerTest
	fixtures :projects, :repositories, :enabled_modules

	def setup
		Setting.sys_api_enabled = '1'
		Setting.enabled_scm = %w(Subversion Git)
	end

	def teardown
		Setting.clear_cache
	end

	def test_disabled_ws_should_respond_with_403_error
		with_settings :sys_api_enabled => '0' do
			get :projects
			assert_response 403
			assert_include 'Access denied', response.body
		end
	end

	def test_api_key
		with_settings :sys_api_key => 'my_secret_key' do
			get :projects, :params => { :key => 'my_secret_key' }
			assert_response :success
		end
	end

	def test_wrong_key_should_respond_with_403_error
		with_settings :sys_api_enabled => 'my_secret_key' do
			get :projects, :params => { :key => 'wrong_key' }
			assert_response 403
			assert_include 'Access denied', response.body
		end
	end
end
