# frozen_string_literal: true

module Redmine
	# @private
	module VERSION
		MAJOR = 4
		MINOR = 0
		TINY = 5

		# Branch values:
		# * official release: nil
		# * stable branch:    stable
		# * trunk:            devel
		BRANCH = 'devel'

		# Retrieves the revision from the working copy
		def self.revision
			nil
		end

		REVISION = self.revision
		ARRAY = [MAJOR, MINOR, TINY, BRANCH, REVISION].compact
		STRING = ARRAY.join('.')

		def self.to_a;
			ARRAY
		end

		def self.to_s;
			STRING
		end
	end
end
