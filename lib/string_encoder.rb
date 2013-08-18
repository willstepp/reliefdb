module StringEncoder
  def self.encode(target_encoding = "UTF8", source_encoding = "SQL_ASCII", value)
    Iconv.conv(target_encoding, source_encoding, value)
  end
end