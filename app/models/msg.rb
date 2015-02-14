# == Schema Information
#
# Table name: msgs
#
#  id                :integer          not null, primary key
#  name              :string(256)
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#  file_file_name    :string
#  file_content_type :string
#  file_file_size    :integer
#  file_updated_at   :datetime
#

require 'mapi/msg'

class Msg < ActiveRecord::Base
  validates :name, presence: true, length: { maximum: 256 }
  validates :file, presence: true
  has_attached_file :file
  validates_attachment :file, content_type: { content_type: ["application/vnd.ms-outlook", "CDF", "application/octet-stream"] }
  validates_attachment_file_name :file, matches: /msg\Z/i
  validates_attachment :file, size: { less_than: 10.megabytes }

  def mapi_msg
    @mapi_msg ||= Mapi::Msg.open Paperclip.io_adapters.for(file).path
  end

  def from
    mapi_msg.from
  end
  def to
    mapi_msg.to
  end
  def subject
    mapi_msg.subject
  end
  def recipients
    mapi_msg.recipients
  end
  def attachments
    mapi_msg.attachments
  end
  def mime
    mapi_msg.to_mime
  end
  def plaintext
    @plaintext ||= body.parts.find{|x| x.content_type=="text/plain"}.body if body
  end
  def html
    @html ||= body.parts.find{|x| x.content_type=="text/html"}.body if body
  end

  private
  def body
    # search for the first multipart
    @body ||= mime.parts.find {|x| x.content_type=="multipart/alternative"}
  end

end
