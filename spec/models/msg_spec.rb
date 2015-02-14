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

require 'rails_helper'

RSpec.describe Msg, type: :model do
  TEST_FILE = 'spec/fixtures/files/Test Message.msg'
  TEST_FILE_BAD = 'spec/fixtures/files/Test Message.msgX'

  before do
    @empty_msg = Msg.new
    @fileless_msg = Msg.new(name: 'testname')
    @nameless_msg = Msg.new(file: File.new(Rails.root + TEST_FILE))
    @msg = Msg.new(name:"test name", file: File.new(Rails.root + TEST_FILE))
    @gemfile = Msg.new(name: "Gemfile", file: File.new(Rails.root + "Gemfile"))
  end

  it { should respond_to :name }
  it { should respond_to :file }

  describe "should not be valid" do
    it "without name and file" do
      expect(@empty_msg.valid?).not_to eq(true)
    end
    it "without file" do
      expect(@fileless_msg).not_to be_valid
    end
    it "without name" do
      expect(@nameless_msg).not_to be_valid
    end
    it "with bad file path" do
      expect{Msg.new(file: File.new(Rails.root + TEST_FILE_BAD))}.to raise_error(Errno::ENOENT)
    end
    it "with bad file content-type" do
      expect(@gemfile).not_to be_valid
    end
  end

  describe "should be valid" do
    it "with the proper file and name" do
      expect(@msg).to be_valid
    end
  end

  describe "should be able to open the Mapi file" do
    it "and decode it" do
      expect(@msg.mapi_msg).not_to be_nil
      expect(@msg.mapi_msg.subject).to eq "A message"
    end
    it "and contain three attachments" do
      expect(@msg.attachments.length).to eq(3)
      expect(@msg.attachments.first.filename).to eq("SOME_SQL.SQL")
    end
    it "and have valid receipents" do
      expect(@msg.recipients.length).to eq 1
      expect(@msg.recipients.first.to_s).to eq "\"GRYSZKIEWICZ Tomasz\" <gryszkiewicz@unicc.org>"
    end
    it "and have valid body parts" do
      expect(@msg.plaintext.include? "Please ignore it.").to eq true
      expect(@msg.html.include? "Please ignore it.").to eq true
      expect(@msg.html.include? "<b>test message</b>").to eq true
    end
    it "and can decode the attachments properly" do
      expect(@msg.attachments.first.filename).to eq "SOME_SQL.SQL"
      expect(@msg.attachments.first.data.read.include? "select * from dual;").to eq true
    end
  end
end
