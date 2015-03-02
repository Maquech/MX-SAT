# encoding: UTF-8
module MX::SAT::Contabilidad
  class BalanzaComprobacion
    VERSION = "1.1"
    
    XSD_BALANZA_COMPROBACION = File.join(File.dirname(__FILE__), 'data', "v#{VERSION}", 'xsd', 'BalanzaComprobacion_1_1.xsd')
    XSLT_BALANZA_COMPROBACION = File.join(File.dirname(__FILE__), 'data', "v#{VERSION}", 'xslt', 'BalanzaComprobacion_1_1.xslt')
   
    TIPO_ENVIO_COMPLEMENTARIA = "C"
    TIPO_ENVIO_NORMAL = "N"
    TIPOS_ENVIO = [TIPO_ENVIO_NORMAL, TIPO_ENVIO_COMPLEMENTARIA].freeze

    # OJOOOOOO están mal las URLs, pero el SAT así las tiene en sus XSDs al 28 de Feb de 2015
    NAMESPACE = { 'xmlns:BCE' => "www.sat.gob.mx/esquemas/ContabilidadE/1_1/BalanzaComprobacion" }.freeze
    NAMESPACES = {
      'xsi:schemaLocation' => "www.sat.gob.mx/esquemas/ContabilidadE/1_1/BalanzaComprobacion" + 
      " http://www.sat.gob.mx/esquemas/ContabilidadE/1_1/BalanzaComprobacion/BalanzaComprobacion_1_1.xsd",
      'xmlns:xsi' => "http://www.w3.org/2001/XMLSchema-instance"
    }.merge(NAMESPACE).freeze


    attr_reader :xml, :xml_certificado, :nombre_archivo
    attr_accessor :rfc, :año, :mes, :tipo_envio, :fecha_modificacion, :datos, :certificado, :llave_privada, :passwd_llave_privada
  
    def initialize
      @xml = nil
      @xml_certificado = nil
      @nombre_archivo = nil
      @rfc = nil
      @año = nil
      @mes = nil
      @tipo_envio = nil
      @fecha_mod_bal = nil
      @fecha_modificacion = nil
      @datos = []
      @certificado = nil
      @llave_privada = nil
      @passwd_llave_privada = nil
    end
    
    def cargar_xslx(archivo)
      doc = ::SimpleXlsxReader.open(archivo)
      filas = doc.sheets.find{ |s| s.name.downcase == "datos" }.rows[1..-1]
      obtener_atributos_generales(filas.first)
      obtener_datos(filas)
    end
    
    def to_xml
      return if @datos.empty?
      builder = ::Nokogiri::XML::Builder.new(encoding: 'UTF-8') do |xml|
        xml['BCE'].Balanza(atributos_nodo_balanza){ @datos.each{ |dato| xml.Ctas(dato) } }
      end
      @xml = builder.to_xml
      certificar_xml
    end
    
    def generar_archivo_xml
      return unless @nombre_archivo
      File.open("#{@nombre_archivo}.xml", "w") {|f| f.write(@xml_certifcado || @xml || self.to_xml) }
      "#{@nombre_archivo}.xml"
    end
    
    def generar_archivo_zip
      return unless @nombre_archivo
      self.generar_archivo_xml unless File.exist?("#{@nombre_archivo}.xml")
      ::Zip::File.open(File.join("#{@nombre_archivo}.zip"), ::Zip::File::CREATE) do |archivo_zip|
        archivo_zip.add("#{@nombre_archivo}.xml", "#{@nombre_archivo}.xml")
      end
      "#{@nombre_archivo}.zip"
    end
    
    def xml_valido?
      xsd_doc = Nokogiri::XML::Schema(File.open(XSD_BALANZA_COMPROBACION, 'rb'))
      xml_doc = Nokogiri::XML(@xml_certificado || @xml || self.to_xml, nil, 'UTF-8')
      errors = ""
      xsd_doc.validate(xml_doc).each { |error| errors += " #{error.message}" }
      doc_valido = xsd_doc.valid?(xml_doc)
      puts "XML validado con #{xsd} es INVÁLIDO!: #{errors}" unless doc_valido
      return doc_valido
    end
    
    
    private
      def certificar_xml
        if !@certificado.nil? and !@llave_privada.nil?
          @xml_certificado = agregar_certificacion_xml
        else
          @xml
        end
      end
      
      def agregar_certificacion_xml
        xml_doc_sin_sello = Nokogiri::XML(@xml || to_xml, nil, 'UTF-8')
        cadena = ::MX::SAT::Certificacion.generar_cadena_original(@xml, XSLT_BALANZA_COMPROBACION)
        nodo_raiz = xml_doc_sin_sello.at_xpath('/BCE:Balanza', NAMESPACE)
        nodo_raiz['Sello'] = ::MX::SAT::Certificacion.firma_sha256(cadena, @llave_privada, @passwd_llave_privada)
        nodo_raiz['noCertificado'] = ::MX::SAT::Certificacion.num_serial_certificado(@certificado)
        nodo_raiz['Certificado'] = ::MX::SAT::Certificacion.certificado_b64(@certificado)
        xml_doc_sin_sello.to_xml
      end
    
      def atributos_nodo_balanza
        atributos = { Version: VERSION, RFC: @rfc, Mes: @mes, Anio: @año, TipoEnvio: @tipo_envio }
        atributos[:FechaModBal] = @fecha_modificacion unless @fecha_modificacion.nil?
        atributos.merge(NAMESPACES)
      end
      
      def establecer_fecha_modificacion
        begin
          @fecha_modificacion = Date.parse(@fecha_mod_bal).to_s if @fecha_mod_bal and !@fecha_mod_bal.empty?
          @fecha_modificacion = 'falta_fecha' if @fecha_mod_bal.nil? and @fecha_mod_bal.empty? and (@tipo_envio == "C")
        rescue ArgumentError
          @fecha_modificacion = 'formato_fecha_incorrecta'
        end
      end
      
      def obtener_atributos_generales(fila)
        arr = fila[0..4]
        @rfc, mes, @año, @tipo_envio, @fecha_mod_bal = *arr
        @mes = fmto_mes(mes)
        establecer_fecha_modificacion
        @nombre_archivo = "#{@rfc}#{@año}#{@mes}B#{@tipo_envio}"
      end
      
      def obtener_datos(filas)
        @datos = filas.map do |fila|
          { NumCta: fila[5], SaldoIni: fmto_decimal(fila[6]),
            Debe: fmto_decimal(fila[7]), Haber: fmto_decimal(fila[8]), SaldoFin: fmto_decimal(fila[9]) }
        end
      end
      
      def fmto_decimal(num)
        return "0" if num.to_i.zero?
        "%.2f" % num
      end
      
      def fmto_mes(num)
        "%02d" % num
      end
  end
end