# encoding: UTF-8
require File.expand_path(File.dirname(__FILE__) + '/../../../spec_helper')

describe MX::SAT::Contabilidad::CatalogoCuentas do
  after :all do
    FileUtils.rm(Dir.glob('*.{xml,zip}'), force: true)
  end
  
  let!(:archivo_xls_catalogo_cuentas){
    File.join(File.dirname(__FILE__), '..', '..', '..', 'support', 'archivos', 'xlsx', 'catalogo_cuentas.xlsx')
  }
  let(:catalogo_vacio){ described_class.new }
  let(:catalogo){ c = described_class.new; c.cargar_xslx(archivo_xls_catalogo_cuentas); c }
  
  describe 'Atributos' do
    let!(:catalogo_vacio){ described_class.new }
    
    [:xml, :xml_certificado, :nombre_archivo, :rfc, :año, :mes, :datos, :certificado, :llave_privada, :passwd_llave_privada].
    each do |atributo|
      it "#{atributo}" do
        expect(catalogo_vacio).to respond_to atributo
      end
    end
  end
  
  describe '#nombre_archivo' do
    context 'cuando el catálogo de cuentas tiene información' do
      it 'tiene el formato RFC+Anio+Mes+CT (MTS110304UT4201501CT)' do
        expect(catalogo.nombre_archivo).to eq "MTS110304UT4201501CT"
      end
    end
    
    context 'cuando el catálogo no tiene información' do
      it 'nil' do
        expect(catalogo_vacio.to_xml).to be_nil
      end
    end
  end
  
  describe '#to_xml' do
    context 'cuando el catálogo tiene información' do
      let(:xml_catalogo_cuentas){
        archivo = File.join(File.dirname(__FILE__), '..', '..', '..', 'support', 'archivos', 'xml', 'MTS110304UT4201501CT.xml')
        File.open(archivo, 'rb') { |f| f.read }
      }
      it 'el xml de el catálogo de cuentas normal' do
        expect(catalogo.to_xml).to be_equivalent_to(xml_catalogo_cuentas)
      end
    end

    context 'cuando el catálogo no tiene información' do
      it 'nil' do
        expect(catalogo_vacio.to_xml).to be_nil
      end
    end
  end

  describe '#generar_archivo_xml' do
    context 'cuando el catálogo tiene información' do
      it 'se crea el archivo XML' do
        catalogo.generar_archivo_xml
        expect(File.exist?("#{catalogo.nombre_archivo}.xml")).to be_truthy
      end
    end

    context 'cuando el catálogo no tiene información' do
      it 'nil' do
        expect(catalogo_vacio.to_xml).to be_nil
      end
    end
  end

  describe '#generar_archivo_zip' do
    context 'cuando el catálogo tiene información' do
      it 'se crea el archivo ZIP' do
        catalogo.generar_archivo_zip
        expect(File.exist?("#{catalogo.nombre_archivo}.zip")).to be_truthy
      end
    end

    context 'cuando el catálogo no tiene información' do
      it 'nil' do
        expect(catalogo_vacio.to_xml).to be_nil
      end
    end
  end

  describe '#xml_valido?' do
    context 'cuando el catálogo tiene información' do
      it 'el xml es válido' do
        expect(catalogo.xml_valido?).to be_truthy
      end
    end

    context 'cuando el catálogo no tiene información' do
      it 'nil' do
        expect(catalogo_vacio.to_xml).to be_nil
      end
    end
  end
end