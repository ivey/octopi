class Net::HTTP::Patch < Net::HTTPRequest
  METHOD = 'PATCH'
  REQUEST_HAS_BODY = true
  RESPONSE_HAS_BODY = true
end

HTTParty::Request::SupportedHTTPMethods.push Net::HTTP::Patch
