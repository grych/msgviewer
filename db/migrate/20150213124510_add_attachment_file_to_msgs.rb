class AddAttachmentFileToMsgs < ActiveRecord::Migration
  def self.up
    change_table :msgs do |t|
      t.attachment :file
    end
  end

  def self.down
    remove_attachment :msgs, :file
  end
end
