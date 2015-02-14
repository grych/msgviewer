Paperclip.options[:content_type_mappings] = {
  msg: "CDF V2 Document, No summary info"
}
Paperclip::Attachment.default_options[:path] = ":rails_root/storage/:class/:attachment/:id_partition/:style/:filename"
