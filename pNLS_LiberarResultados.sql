/*******************************************************************************  
Descripcion: Obtiene informacion de la orden y los resultados para ser liberados.  
Creado por: SOTERO BUSTAMANTE  
Fecha Creacion: 20/10/2017  
Modificacion: Se agegaron comentarios  
*******************************************************************************/  
ALTER PROCEDURE [dbo].[pNLS_LiberarResultados]  
@idOrden uniqueidentifier  
  
AS  
BEGIN  
SET NOCOUNT ON  
  
--ORDEN  
SELECT o.codigoOrden as codigoOrden, p.nroDocumento as paciente_nrodocumento,   
p.codificacion as paciente_codificacion,  
p.nombres+ ' '+p.apellidoPaterno + ' ' +p.apellidoPaterno  as paciente_nombres, p.fechaNacimiento as paciente_fechNac,  
(SELECT DATEDIFF(yy,p.fechaNacimiento,GETDATE()) - CASE WHEN (MONTH(p.fechaNacimiento) > MONTH(GETDATE() ) ) OR (MONTH(p.fechaNacimiento) = MONTH(GETDATE() ) AND DAY(fechaNacimiento) > DAY(GETDATE() ) ) THEN 1 ELSE 0 END) as edadAnios,   
(SELECT (DATEDIFF(m,p.fechaNacimiento,GETDATE()) - CASE WHEN (DAY(p.fechaNacimiento) > DAY(GETDATE()) ) THEN 1 ELSE 0 END) % 12 ) as edadMeses,   
pro.idProyecto as proyecto_idProyecto,  
pro.nombre as proyecto_nombre,  
e.nombre as establecimiento_nombre,  
o.nroOficio,   
o.observacion,  
o.estatus,  
o.idEstablecimiento  
FROM Orden o (nolock)  
INNER JOIN Paciente p (nolock)  
 on o.idPaciente = p.idPaciente  
INNER JOIN Proyecto pro (nolock)  
 on o.idProyecto = pro.idProyecto  
INNER JOIN Establecimiento e (nolock)  
 on o.idEstablecimiento = e.idEstablecimiento  
WHERE   
 o.idOrden = @idOrden  
  
  
--ORDEN RESULTADO ANALITO  
Select distinct ORA.idOrdenResultadoAnalito, OE.idOrdenExamen, E.nombre NombreExamen, O.idOrden, O.codigoOrden CodOrden,   
TM.nombre NombreMuestra, A.idAnalito, A.nombre Analito, ORA.resultado, OE.validado, 0 liberado, ES.nombre NombEstab,   
MC.codificacion CodifMuestra, 
--LD.glosa Unidad, 
ORA.observacion, EM.Glosa Metodo
--, AVN.glosa ValorNormal  
from OrdenResultadoAnalito ORA  (nolock)  
    inner join OrdenExamen OE (nolock) on ORA.idOrdenExamen = OE.idOrdenExamen  
 inner join Examen E (nolock) on OE.idExamen = E.idExamen  
 inner join Orden O (nolock) on OE.idOrden = O.idOrden  
 inner join OrdenMuestra OM (nolock) on O.idOrden = OM.idOrden   
 inner join TipoMuestra TM (nolock) on OM.idTipoMuestra = TM.idTipoMuestra  
 inner join Analito A (nolock) on ORA.idAnalito = A.idAnalito  
 inner join MuestraCodificacion MC (nolock) on OM.idMuestraCod = MC.idMuestraCod  
 --inner join ListaDetalle LD (nolock) on A.idListaUnidad = LD.idDetalleLista  
 inner join ExamenMetodo EM (nolock) on E.idExamen = EM.idExamen  
 --inner join AnalitoValorNormal AVN (nolock) on A.idAnalito = AVN.idAnalito  
 inner join Establecimiento ES (nolock) on O.idEstablecimiento = ES.idEstablecimiento  
where OE.validado = 1 and O.idOrden = @idOrden and OE.estatusSol = 1 AND ORA.idSecuen = (SELECT MAX(idSecuen)  from OrdenResultadoAnalito where idOrdenExamen = oe.idOrdenExamen) 
  
END  