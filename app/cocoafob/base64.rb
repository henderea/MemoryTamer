class NSString
  def base64Encode(line_breaks = false)
    plainString = self
    plainString = plainString.gsub(/[\r\n]/, '') unless line_breaks
    plainData = plainString.dataUsingEncoding(NSUTF8StringEncoding)
    encodedString = plainData.base64EncodedStringWithOptions(0)
    encodedString = encodedString.gsub(/[\r\n]/, '') unless line_breaks
    encodedString
  end

  def base64Decode(line_breaks = false)
    originalString = self
    originalString = originalString.gsub(/[\r\n]/, '') unless line_breaks
    decodedData = NSData.alloc.initWithBase64EncodedString(originalString, options: 0)
    decodedString = NSString.alloc.initWithData(decodedData, encoding: NSUTF8StringEncoding)
    decodedString = decodedString.gsub(/[\r\n]/, '') unless line_breaks
    decodedString
  end
end