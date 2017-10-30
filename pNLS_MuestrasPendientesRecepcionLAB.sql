/*******************************************************************************  
Descripcion: Obtener informacion de muestras pendientes de ingreso de resultados.  
Creado por: Terceros  
Fecha Creacion: 01/01/2017  
Modificacion: Se agegaron comentarios  
*******************************************************************************/  
ALTER PROCEDURE [dbo].[pNLS_MuestrasPendientesRecepcionLAB]   
@IdUsuario int,   
@IdOrden uniqueidentifier,  
@IdEstablecimientoLogin int  
AS  
BEGIN 

/*AGREGADO POR SOTERO BUSTAMANTE PARA OBTENER ORDEN DE SECUENCIA DE LLEGAD DE LA MUESTRA EN RECEPCION 28/10/2017*/ 
DECLARE @SECUENoBTENCION INT
SET @SECUENoBTENCION =(select MAX(secuenObtencion) From OrdenMuestraRecepcion WHERE idLaboratorioDestino = @IdEstablecimientoLogin )
/******************FIN********************/
 select distinct o.idOrden, o.idEstablecimiento, e.nombre nombreEstablecimiento, e.codigoUnico, ldtd.glosa tipoDocumento, p.nroDocumento, p.codificacion, p.nombres nombrePaciente, p.apellidoPaterno, p.apellidoMaterno, p.fechaNacimiento,   
 o.fechaSolicitud fechaRegistroOrden, o.idPaciente, o.idAnimal, o.idCepaBancoSangre, o.codigoOrden, o.nroOficio, oma.idOrdenMaterial, om.idOrdenMuestra, mc.codificacion codigoMuestra, tm.idTipoMuestra, tm.nombre nombreTipoMuestra,   
 m.idMaterial, m.volumen, pre.idPresentacion, pre.glosa nombrePresentacion, r.idReactivo, r.glosa  nombreReactivo, pro.nombre nombreProyecto, omr.idOrdenMuestraRecepcion, om.fechaColeccion,   
 pre.glosa+' '+r.glosa+' '+cast(m.volumen as varchar(20)) as Material,convert(varchar(10),om.fechaColeccion,103)+' - '+ convert(varchar(5),om.horaColeccion,108) as FechaHoraColeccion,  
 dbo.FUN_CALCULAR_EDAD_MESES(p.fechaNacimiento,o.fechasolicitud)as Edad,ld.glosa Sexo,
 
 /*AGREGADO POR SOTERO BUSTAMANTE PARA OBTENER ORDEN DE SECUENCIA DE LLEGAD DE LA MUESTRA EN RECEPCION 28/10/2017*/ 
 secuenObtencion =(SELECT CASE isnull(@SECUENoBTENCION,0) WHEN  0 THEN 1 ELSE @SECUENoBTENCION + 1 END)
  
 from Orden o (nolock)  
 inner join OrdenExamen oe (nolock) on oe.idOrden = o.idOrden   
 inner join AreaProcesamientoExamen ape (nolock) on ape.idExamen = oe.idExamen    
 inner join UsuarioAreaProcesamiento apu (nolock) on apu.idUsuario = @IdUsuario and apu.idAreaProcesamiento = ape.idAreaProcesamiento   
 inner join OrdenResultadoAnalito ora (nolock) on ora.idOrdenExamen = oe.idOrdenExamen   
 inner join Establecimiento e (nolock) on e.idEstablecimiento = o.idEstablecimiento  
 inner join OrdenMuestra om (nolock) on om.idOrden = o.idOrden and om.idOrden=oe.idOrden and om.idTipoMuestra=oe.idTipoMuestra   
 inner join MuestraCodificacion mc (nolock) on mc.idMuestraCod = om.idMuestraCod   
 inner join OrdenMaterial oma (nolock) on oma.idOrden=o.idOrden and oma.idOrden=om.idOrden and oma.idOrden=oe.idOrden  
 and oma.idOrdenMuestra = om.idOrdenMuestra and oma.idOrdenExamen=ora.idOrdenExamen and oma.idOrdenExamen=oe.idOrdenExamen  
 inner join OrdenMuestraRecepcion omr (nolock) on omr.idOrden=o.idOrden and om.idOrden=omr.idOrden and oma.idOrden=omr.idOrden and omr.idOrden=oe.idOrden  
 and omr.idOrdenMaterial = oma.idOrdenMaterial  
 inner join TipoMuestra tm (nolock) on tm.idTipoMuestra = om.idTipoMuestra and tm.idTipoMuestra=oe.idTipoMuestra  
 inner join Material m (nolock) on m.idMaterial = oma.idMaterial   
 inner join Presentacion pre (nolock) on pre.idPresentacion = m.idPresentacion   
 inner join Reactivo r (nolock) on r.idReactivo = m.idReactivo  
 inner join Proyecto pro (nolock) on pro.idProyecto = o.idProyecto    
 left join Paciente p (nolock) on p.idPaciente = o.idPaciente   
 left join ListaDetalle ldtd (nolock) on p.tipoDocumento = ldtd.idDetalleLista and ldtd.idLista = 7   
 left join ListaDetalle ld (nolock) on p.genero = ld.idDetalleLista and ld.idLista = 4    
 INNER JOIN Establecimiento l (nolock) on l.idEstablecimiento = omr.idLaboratorioDestino 
 
 
  
 where omr.estado = 1 and omr.estatusP=4 and o.estado = 1 and ora.estado = 1 and conformeR = 1   
 and o.idOrden = @IdOrden and omr.idLaboratorioDestino =@IdEstablecimientoLogin
 
 
END  