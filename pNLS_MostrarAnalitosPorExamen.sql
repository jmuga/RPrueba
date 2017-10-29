/*******************************************************************************    
Descripcion: Obtiene los componentes de las pruebas filtrado por las pruebas seleccionadas.  
Creado por: Terceros    
Fecha Creacion: 01/01/2017    
Modificacion: Se agegaron comentarios    
*******************************************************************************/    
ALTER PROCEDURE [dbo].[pNLS_MostrarAnalitosPorExamen]  
 @idOrdenExamen varchar(1000),
 @GeneroPaciente int 
  
AS  
  
BEGIN  
  
  SET NOCOUNT ON  
  
Select DISTINCT OE.idOrden, oe.IdExamen,ora.idAnalito, ORA.idOrdenResultadoAnalito, e.nombre Examen, A.nombre Analito,ORA.codigoOpcion, ORA.resultado Resultado,   
LD.glosa Unidad, AVN.glosa ValorReferencia, AVN.valorInferior, AVN.valorSuperior, ORA.observacion,ora.orden,isnull(oe.estatusE,0) as estatusE,a.tipo --,MAX(ORA.idSecuen)  
from OrdenResultadoAnalito ORA (nolock)  
inner join OrdenExamen OE (nolock) on ORA.idOrdenExamen = OE.idOrdenExamen  
inner join Examen e (nolock) on oe.idExamen = e.idExamen  
inner join Analito A (nolock) on ORA.idAnalito = A.idAnalito  
inner join ListaDetalle LD (nolock) on A.idListaUnidad = LD.idDetalleLista and LD.idLista = 2  
left join AnalitoValorNormal AVN (nolock) on A.idAnalito = AVN.idAnalito   
and ((a.tipo = 1 and AVN.grupoGenero = @GeneroPaciente) or (a.tipo = 3))  
where OE.idOrdenExamen in (SELECT Item FROM dbo.fNLS_SplitString(@idOrdenExamen, ',')) 
/**AGREGADO SOTERO BUSTAMANTE 24-10-2017 SELECCIONAR EL ULTIMO RESULTADO INGRESADO POR EL VERIFICADOR*/
AND ORA.idSecuen = (SELECT MAX(idSecuen) FROM OrdenResultadoAnalito WHERE idOrdenResultadoAnalito = ORA.idOrdenResultadoAnalito)
order by ora.orden  
  
END  