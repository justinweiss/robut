# Encoding patch, stolen from https://github.com/ln/xmpp4r/issues/3#issuecomment-1739952
require 'socket'
class TCPSocket
  def external_encoding
    Encoding::BINARY
  end
end

require 'rexml/source'
class REXML::IOSource
  alias_method :encoding_assign, :encoding=
  def encoding=(value)
    encoding_assign(value) if value
  end
end

begin
  # OpenSSL is optional and can be missing
  require 'openssl'
  class OpenSSL::SSL::SSLSocket
    def external_encoding
      Encoding::BINARY
    end
  end
rescue
end
