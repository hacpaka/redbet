class UpdateEnumerationsToSti < ActiveRecord::Migration[4.2]
	def self.up
		Enumeration.where("opt = 'IPRI'").update_all("type = 'IssuePriority'")
		Enumeration.where("opt = 'DCAT'").update_all("type = 'DocumentCategory'")
	end

	def self.down
		# no-op
	end
end
