# Los XSDs del SAT tienen errores (al 28 de Feb de 2015)
El `schemaLocation` y el `xmlns:catalogoscuentas` tienen errores en las URLs (falta el `http://`) pero de ponerlo, el validador del SAT marca error. Idiotas. Los namespaces válidos son:

```
 xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
 xmlns:catalogocuentas="www.sat.gob.mx/esquemas/ContabilidadE/1_1/CatalogoCuentas"
 xsi:schemaLocation="www.sat.gob.mx/esquemas/ContabilidadE/1_1/CatalogoCuentas http://www.sat.gob.mx/esquemas/ContabilidadE/1_1/CatalogoCuentas/CatalogoCuentas_1_1.xsd"
```

Mismo caso para las balanzas, los namespaces no concuerdan con la documentación del diario oficial. Doblemente idiotas. Los namespaces válidos son:

```
 xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
 xmlns:BCE="www.sat.gob.mx/esquemas/ContabilidadE/1_1/BalanzaComprobacion" 
 xsi:schemaLocation="www.sat.gob.mx/esquemas/ContabilidadE/1_1/BalanzaComprobacion http://www.sat.gob.mx/esquemas/ContabilidadE/1_1/BalanzaComprobacion/BalanzaComprobacion_1_1.xsd"
```


## Referencias

### Oficiales

* [SAT, contabilidad electrónica](http://www.sat.gob.mx/fichas_tematicas/buzon_tributario/Paginas/contabilidad_electronica.aspx)
* [Validador del SAT](https://ceportalvalidacionprod.clouda.sat.gob.mx/)


### No oficiales

* [ValidaCFD](http://www.validacfd.com/phpbb3/viewtopic.php?f=16&t=4805&start=130)
* [Fortiz @ lacorona.com.mx - siempre me saca de dudas con sus publicaciones](http://www.lacorona.com.mx/fortiz/sat/ce/)