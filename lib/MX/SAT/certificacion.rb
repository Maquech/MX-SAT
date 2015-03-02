# encoding: UTF-8
module MX::SAT
  module Certificacion
    
    def self.num_serial_certificado(certificado)
      ::OpenSSL::X509::Certificate.new(certificado).serial.to_s(2)
    end
    
    def self.certificado_vigente?(certificado)
      cert = ::OpenSSL::X509::Certificate.new(certificado)
      ::Time.now.between?(cert.not_before, cert.not_after)
    end
    
    def self.certificado_b64(certificado)
      cert = OpenSSL::X509::Certificate.new(certificado)
      certb64 = cert.to_pem.sub("-----BEGIN CERTIFICATE-----\n", "").sub("\n-----END CERTIFICATE-----\n","")
      certb64.gsub(/[\n\r]/,"")
    end
    
    def self.generar_cadena_original(xml, xslt)
      xml_doc = Nokogiri::XML(xml, nil, 'UTF-8')
      # libxml no puede transformar XSLT 2.0, así que se editaron los XSLTs del SAT
      # cambiando la versión 2.0 a la 1.0 y usando rutas relativas
      xslt = ::Nokogiri::XSLT(File.open(xslt, 'rb')) # Usar File.open para que los includes del XSLT no fallen
      cadena_original = xslt.transform(xml_doc)
      cadena_original.children.first.to_s
    end
    
    def self.firma_sha256(cadena, llave_privada, passwd = nil)
      private_key = passwd ? ::OpenSSL::PKey::RSA.new(llave_privada, passwd) : ::OpenSSL::PKey::RSA.new(llave_privada)
      firma = private_key.sign(::OpenSSL::Digest::SHA256.new, cadena)
      ::Base64.encode64(firma).gsub(/[\n\r]/, "")
    end
    
  end
end