# encoding: UTF-8
require File.expand_path(File.dirname(__FILE__) + '/../../../spec_helper')

describe MX::SAT::Contabilidad::BalanzaComprobacion do
  after :all do
    FileUtils.rm(Dir.glob('*.{xml,zip}'), force: true)
  end
  
  let!(:archivo_xls_balanza_comprobacion_normal){
    File.join(File.dirname(__FILE__), '..', '..', '..', 'support', 'archivos', 'xlsx', 'balanza_comprobacion_normal.xlsx')
  }
  let!(:archivo_xls_balanza_comprobacion_complementaria){
    File.join(File.dirname(__FILE__), '..', '..', '..', 'support', 'archivos', 'xlsx', 'balanza_comprobacion_complementaria.xlsx')
  }
  let(:balanza){ described_class.new }
  let(:balanza_normal){ b = described_class.new; b.cargar_xslx(archivo_xls_balanza_comprobacion_normal); b }
  let(:balanza_complementaria){ b = described_class.new; b.cargar_xslx(archivo_xls_balanza_comprobacion_complementaria); b }


  describe 'Atributos' do
    let!(:balanza){ described_class.new }
    
    [:xml, :xml_certificado, :nombre_archivo, :rfc, :año, :mes, :tipo_envio, :fecha_modificacion, :datos, :certificado,
      :llave_privada, :passwd_llave_privada].each do |atributo|
      it "#{atributo}" do
        expect(balanza).to respond_to atributo
      end
    end
  end
  
  describe '#nombre_archivo' do
    context 'cuando la balanza de comprobación es normal' do
      it 'tiene el formato RFC+Anio+Mes+B+N (MTS110304UT4201501BN)' do
        expect(balanza_normal.nombre_archivo).to eq "MTS110304UT4201501BN"
      end
    end
    
    context 'cuando la balanza de comprobación es complementaria' do
      it 'tiene el formato RFC+Anio+Mes+B+C (MTS110304UT4201501BC)' do
        expect(balanza_complementaria.nombre_archivo).to eq "MTS110304UT4201501BC"
      end
    end
    
    context 'cuando la balanza no tiene información' do
      it 'nil' do
        expect(balanza.to_xml).to be_nil
      end
    end
  end
  
  describe '#to_xml' do
    context 'cuando la balanza de comprobación es normal' do
      context 'cuando la balanza tiene información' do
        let(:xml_balanza_normal){
          archivo = File.join(File.dirname(__FILE__), '..', '..', '..', 'support', 'archivos', 'xml', 'MTS110304UT4201501BN.xml')
          File.open(archivo, 'rb') { |f| f.read }
        }
        it 'el xml de la balanza de comprobación normal' do
          expect(balanza_normal.to_xml).to be_equivalent_to(xml_balanza_normal)
        end
      end
    end

    context 'cuando la balanza de comprobación es complementaria' do
      context 'cuando la balanza tiene información' do
        let(:xml_balanza_complementaria){
          archivo = File.join(File.dirname(__FILE__), '..', '..', '..', 'support', 'archivos', 'xml', 'MTS110304UT4201501BC.xml')
          File.open(archivo, 'rb') { |f| f.read }
        }
        it 'el xml de la balanza de comprobación normal' do
          expect(balanza_complementaria.to_xml).to be_equivalent_to(xml_balanza_complementaria)
        end
      end
    end

    context 'cuando la balanza no tiene información' do
      it 'nil' do
        expect(balanza.to_xml).to be_nil
      end
    end
  end

  describe '#generar_archivo_xml' do

    
    context 'cuando la balanza de comprobación es normal' do
      context 'cuando la balanza tiene información' do
        it 'se crea el archivo XML' do
          balanza_normal.generar_archivo_xml
          expect(File.exist?("#{balanza_normal.nombre_archivo}.xml")).to be_truthy
        end
      end
    end

    context 'cuando la balanza de comprobación es complementaria' do
      context 'cuando la balanza tiene información' do
        it 'se crea el archivo XML' do
          balanza_complementaria.generar_archivo_xml
          expect(File.exist?("#{balanza_complementaria.nombre_archivo}.xml")).to be_truthy
        end
      end
    end

    context 'cuando la balanza no tiene información' do
      it 'nil' do
        expect(balanza.to_xml).to be_nil
      end
    end
  end

  describe '#generar_archivo_zip' do
    context 'cuando la balanza de comprobación es normal' do
      context 'cuando la balanza tiene información' do
        it 'se crea el archivo ZIP' do
          balanza_normal.generar_archivo_zip
          expect(File.exist?("#{balanza_normal.nombre_archivo}.zip")).to be_truthy
        end
      end
    end

    context 'cuando la balanza de comprobación es complementaria' do
      context 'cuando la balanza tiene información' do
        it 'se crea el archivo ZIP' do
          balanza_complementaria.generar_archivo_zip
          expect(File.exist?("#{balanza_complementaria.nombre_archivo}.zip")).to be_truthy
        end
      end
    end

    context 'cuando la balanza no tiene información' do
      it 'nil' do
        expect(balanza.to_xml).to be_nil
      end
    end
  end

  describe '#xml_valido?' do
    context 'cuando la balanza de comprobación es normal' do
      context 'cuando la balanza tiene información' do
        it 'el xml es válido' do
          expect(balanza_normal.xml_valido?).to be_truthy
        end
      end
    end

    context 'cuando la balanza de comprobación es complementaria' do
      context 'cuando la balanza tiene información' do
        it 'el xml es válido' do
          expect(balanza_complementaria.xml_valido?).to be_truthy
        end
      end
    end

    context 'cuando la balanza no tiene información' do
      it 'nil' do
        expect(balanza.to_xml).to be_nil
      end
    end
  end
end