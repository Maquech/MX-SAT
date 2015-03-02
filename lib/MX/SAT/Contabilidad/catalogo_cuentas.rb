# encoding: UTF-8
module MX::SAT::Contabilidad
  class CatalogoCuentas
    VERSION = "1.1"
    
    XSD_CATALOGO_CUENTAS = File.join(File.dirname(__FILE__), 'data', "v#{VERSION}", 'xsd', 'CatalogoCuentas_1_1.xsd')
    XSLT_CATALOGO_CUENTAS = File.join(File.dirname(__FILE__), 'data', "v#{VERSION}", 'xslt', 'CatalogoCuentas_1_1.xslt')

    # OJOOOOOO están mal las URLs, pero el SAT así las tiene en sus XSDs al 28 de Feb de 2015
    NAMESPACE = {'xmlns:catalogocuentas' => "www.sat.gob.mx/esquemas/ContabilidadE/1_1/CatalogoCuentas"}.freeze
    NAMESPACES = {'xsi:schemaLocation' => "www.sat.gob.mx/esquemas/ContabilidadE/1_1/CatalogoCuentas http://www.sat.gob.mx/esquemas/ContabilidadE/1_1/CatalogoCuentas/CatalogoCuentas_1_1.xsd",
          'xmlns:xsi' => "http://www.w3.org/2001/XMLSchema-instance"}.merge(NAMESPACE).freeze


    attr_reader :xml, :xml_certificado, :nombre_archivo
    attr_accessor :rfc, :año, :mes, :datos, :certificado, :llave_privada, :passwd_llave_privada
  
    def initialize
      @xml = nil
      @xml_certificado = nil
      @nombre_archivo = nil
      @rfc = nil
      @año = nil
      @mes = nil
      @datos = []
      @certificado = nil
      @llave_privada = nil
      @passwd_llave_privada = nil
    end
    
    def cargar_xslx(archivo)
      doc = ::SimpleXlsxReader.open(archivo)
      filas = doc.sheets.find{ |s| s.name.downcase == "datos" }.rows[1..-1]
      obtener_atributos_generales(filas.first)
      @datos = filas.map { |fila| { CodAgrup: fila[3], NumCta: fila[4], Desc: fila[5], SubCtaDe: fila[6], Nivel: fila[7], Natur: fila[8] } }
    end
    
    def to_xml
      return if @datos.empty?
      builder = ::Nokogiri::XML::Builder.new(encoding: 'UTF-8') do |xml|
        xml['catalogocuentas'].Catalogo(atributos_nodo_catalogo) do
          @datos.each do |dato|
            xml.Ctas((dato[:SubCtaDe].nil? or dato[:SubCtaDe].empty?) ? dato.reject{|k,v| k == :SubCtaDe} : dato)
          end
        end
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
      xsd_doc = Nokogiri::XML::Schema(File.open(XSD_CATALOGO_CUENTAS, 'rb'))
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
        cadena = ::MX::SAT::Certificacion.generar_cadena_original(@xml, XSLT_CATALOGO_CUENTAS)
        nodo_raiz = xml_doc_sin_sello.at_xpath('/catalogocuentas:Catalogo', NAMESPACE)
        nodo_raiz['Sello'] = ::MX::SAT::Certificacion.firma_sha256(cadena, @llave_privada, @passwd_llave_privada)
        nodo_raiz['noCertificado'] = ::MX::SAT::Certificacion.num_serial_certificado(@certificado)
        nodo_raiz['Certificado'] = ::MX::SAT::Certificacion.certificado_b64(@certificado)
        xml_doc_sin_sello.to_xml
      end
    
      def atributos_nodo_catalogo
        atributos = { Version: VERSION, RFC: @rfc, Mes: @mes, Anio: @año }
        atributos.merge(NAMESPACES)
      end
      
      def atributos_nodo_ctas(dato)
        (dato[:SubCtaDe].nil? or dato[:SubCtaDe].empty?) ? dato.reject{|k,v| k == :SubCtaDe} : dato
      end
      
      def obtener_atributos_generales(fila)
        arr = fila[0..2]
        @rfc, mes, @año = *arr
        @mes = fmto_mes(mes)
        @nombre_archivo = "#{@rfc}#{@año}#{@mes}CT"
      end
      
      def fmto_mes(num)
        "%02d" % num
      end
      
  end
end