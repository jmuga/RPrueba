/*******************************************************************************        
Descripcion: Obtiene informacion de las ordenes listas para la validacion de resultados.        
Creado por: Terceros        
Fecha Creacion: 01/01/2017        
Modificacion: Se agegaron comentarios        
*******************************************************************************/        
ALTER PROCEDURE [dbo].[pNLS_Validaciones]          
@idUsuario int,          
@FechaSolicitud int,          
@CodigoOrden varchar(20),          
@FechaDesde date,           
@FechaHasta date,          
@NroOficio varchar(20),          
@NroDocumento varchar(20),          
@IdLaboratorioUsuario int,
@Estado int         
AS          
if @NroDocumento is null          
 set @NroDocumento=''          
          
if @NroOficio is null          
 set @NroOficio=''          
          
if @CodigoOrden is null          
 set @CodigoOrden=''          
          
SET NOCOUNT ON          
if @FechaSolicitud=1          
BEGIN          
 select distinct o.idOrden, o.idEstablecimiento, e.nombre AS NombEstab, e.codigoUnico, p.nroDocumento,o.fechaSolicitud as fechaSolicitud,          
 o.fechaRegistro as fechaRegistro, o.idPaciente,o.codigoOrden AS CodOrden, o.nroOficio,          
 ldtd.glosa TipoDocumento, ld.glosa NombreGenero, o.estatus,omr.estatusP,P.genero,           
 p.fechaNacimiento as fechaNacimiento,OM.fechaColeccion,      
  /**SOTERO MODIFICACION STORE SOLICTA VERIFICADOR INGRESO NUEVO RESULTADO---24-10-2017*/      
 oe.estatusSol, o.idProyecto,     
 --estatusSol = case when oe.estatusSol = 0 then 'SOLICITA_INGRESO' WHEN oe.estatusSol = 1 then 'SOLICITA_OK' WHEN oe.estatusSol = 2 then 'SOLICITA_NO' END,         
 /***************************************************************************************/      
 dbo.fNLS_MostrarVentanaVerificacion(1,o.idOrden,@IdLaboratorioUsuario)EXISTE_PENDIENTE,          
 dbo.fNLS_MostrarVentanaVerificacion(0,o.idOrden,@IdLaboratorioUsuario)EXISTE_VALIDADO          
 from Orden o (nolock)          
 inner join OrdenExamen oe (nolock) on oe.idOrden = o.idOrden           
 inner join AreaProcesamientoExamen ape (nolock) on ape.idExamen = oe.idExamen            
 inner join UsuarioAreaProcesamiento apu (nolock) on apu.idUsuario = @IdUsuario and apu.idAreaProcesamiento = ape.idAreaProcesamiento           
 inner join Establecimiento e (nolock) on e.idEstablecimiento = o.idEstablecimiento           
 inner join OrdenMuestra om (nolock) on om.idOrden = o.idOrden           
 inner join MuestraCodificacion mc (nolock) on mc.idMuestraCod = om.idMuestraCod           
 inner join OrdenMaterial oma (nolock) on oma.idOrdenMuestra = om.idOrdenMuestra and oma.idOrdenExamen=oe.idOrdenExamen and oma.idOrden=o.idOrden and oma.idOrden=om.idOrden           
 inner join OrdenMuestraRecepcion omr (nolock) on omr.idOrdenMaterial = oma.idOrdenMaterial and omr.idOrden=o.idOrden and om.idOrden=omr.idOrden and oma.idOrden=omr.idOrden          
 left join Paciente p (nolock) on p.idPaciente = o.idPaciente           
 left join ListaDetalle ld (nolock) on p.genero = ld.idDetalleLista and ld.idLista = 4            
 left join ListaDetalle ldtd (nolock) on p.tipoDocumento = ldtd.idDetalleLista and ldtd.idLista = 7           
 INNER JOIN Establecimiento l (nolock) on l.idEstablecimiento = omr.idLaboratorioDestino          
 where o.estatus in (2,3) and o.estado = 1 and omr.estatus = 3 and omr.estado = 1 and omr.estatusR=3          
  and o.estado = 1 and oe.estado = 1 and om.estado = 1 and omr.conformeR=1 and omr.estado = 1           
  and oma.estado=1 and oe.ingresado=1 and (oe.validado is null or oe.validado=1)          
  and (oe.estatusE=10 or oe.estatusE=11)          
  and (LTRIM(RTRIM(o.nroOficio)) LIKE '%'+ LTRIM(RTRIM(@NroOficio)) + '%')          
  and (@NroDocumento is null or @NroDocumento = '' or LTRIM(RTRIM(p.nroDocumento)) LIKE '%'+ LTRIM(RTRIM(@NroDocumento)) + '%')          
  and ((LTRIM(RTRIM(mc.codificacion)) LIKE '%'+ LTRIM(RTRIM(@CodigoOrden)) + '%')          
  or (LTRIM(RTRIM(o.codigoOrden)) LIKE '%'+ LTRIM(RTRIM(@CodigoOrden)) + '%'))          
  and omr.idLaboratorioDestino =@IdLaboratorioUsuario           
  and (@Estado is null or @Estado = 0 or oe.estatusE=@Estado)
  AND o.fechaSolicitud between @FechaDesde AND convert(varchar(10),convert(datetime,@FechaHasta)+1,112)          
 group by  o.idOrden, o.idEstablecimiento, e.nombre, e.codigoUnico, p.nroDocumento,     
 fechaSolicitud, o.fechaRegistro, o.idPaciente, o.codigoOrden, o.nroOficio, ldtd.glosa, ld.glosa, o.estatus,    
 omr.estatusP,P.genero,fechaNacimiento,OM.fechaColeccion,estatusSol,o.idProyecto        
 order by fechaRegistro desc           
END          
ELSE          
BEGIN          
 select distinct o.idOrden, o.idEstablecimiento, e.nombre AS NombEstab, e.codigoUnico, p.nroDocumento,o.fechaSolicitud as fechaSolicitud,          
 o.fechaRegistro as fechaRegistro, o.idPaciente,o.codigoOrden AS CodOrden, o.nroOficio,          
 ldtd.glosa TipoDocumento, ld.glosa NombreGenero, o.estatus,omr.estatusP,P.genero,           
 p.fechaNacimiento as fechaNacimiento,OM.fechaColeccion,      
       
 /**SOTERO MODIFICACION STORE SOLICTA VERIFICADOR INGRESO NUEVO RESULTADO---24-10-2017*/      
 oe.estatusSol,o.idProyecto,      
 --estatusSol = case when oe.estatusSol = 0 then 'SOLICITA_INGRESO' WHEN oe.estatusSol = 1 then 'SOLICITA_OK' WHEN oe.estatusSol = 2 then 'SOLICITA_NO' END,          
  /***************************************************************************************/      
      
 dbo.fNLS_MostrarVentanaVerificacion(1,o.idOrden,@IdLaboratorioUsuario)EXISTE_PENDIENTE,          
 dbo.fNLS_MostrarVentanaVerificacion(0,o.idOrden,@IdLaboratorioUsuario)EXISTE_VALIDADO          
       
 from Orden o (nolock)          
 inner join OrdenExamen oe (nolock) on oe.idOrden = o.idOrden           
 inner join AreaProcesamientoExamen ape (nolock) on ape.idExamen = oe.idExamen            
 inner join UsuarioAreaProcesamiento apu (nolock) on apu.idUsuario = @IdUsuario and apu.idAreaProcesamiento = ape.idAreaProcesamiento           
 inner join Establecimiento e (nolock) on e.idEstablecimiento = o.idEstablecimiento           
 inner join OrdenMuestra om (nolock) on om.idOrden = o.idOrden           
 inner join MuestraCodificacion mc (nolock) on mc.idMuestraCod = om.idMuestraCod           
 inner join OrdenMaterial oma (nolock) on oma.idOrdenMuestra = om.idOrdenMuestra and oma.idOrdenExamen=oe.idOrdenExamen and oma.idOrden=o.idOrden and oma.idOrden=om.idOrden           
 inner join OrdenMuestraRecepcion omr (nolock) on omr.idOrdenMaterial = oma.idOrdenMaterial and omr.idOrden=o.idOrden and om.idOrden=omr.idOrden and oma.idOrden=omr.idOrden          
 left join Paciente p (nolock) on p.idPaciente = o.idPaciente           
 left join ListaDetalle ld (nolock) on p.genero = ld.idDetalleLista and ld.idLista = 4            
 left join ListaDetalle ldtd (nolock) on p.tipoDocumento = ldtd.idDetalleLista and ldtd.idLista = 7           
 INNER JOIN Establecimiento l (nolock) on l.idEstablecimiento = omr.idLaboratorioDestino          
 where o.estatus in (2,3) and o.estado = 1 and omr.estatus = 3 and omr.estado = 1 and omr.estatusR=3          
  and o.estado = 1 and oe.estado = 1 and om.estado = 1 and omr.conformeR=1 and omr.estado = 1           
  and oma.estado=1 and oe.ingresado=1 and (oe.validado is null or oe.validado=1)          
  and (oe.estatusE=10 or oe.estatusE=11)          
  and (LTRIM(RTRIM(o.nroOficio)) LIKE '%'+ LTRIM(RTRIM(@NroOficio)) + '%')          
  and (@NroDocumento is null or @NroDocumento = '' or LTRIM(RTRIM(p.nroDocumento)) LIKE '%'+ LTRIM(RTRIM(@NroDocumento)) + '%')          
  and ((LTRIM(RTRIM(mc.codificacion)) LIKE '%'+ LTRIM(RTRIM(@CodigoOrden)) + '%')          
  or (LTRIM(RTRIM(o.codigoOrden)) LIKE '%'+ LTRIM(RTRIM(@CodigoOrden)) + '%'))          
  and omr.idLaboratorioDestino =@IdLaboratorioUsuario           
  AND om.fechaColeccion between @FechaDesde AND convert(varchar(10),convert(datetime,@FechaHasta)+1,112)          
 group by  o.idOrden, o.idEstablecimiento, e.nombre, e.codigoUnico, p.nroDocumento, fechaSolicitud, o.fechaRegistro, o.idPaciente,     
 o.codigoOrden, o.nroOficio, ldtd.glosa, ld.glosa, o.estatus,omr.estatusP,P.genero,fechaNacimiento,OM.fechaColeccion,estatusSol,o.idProyecto         
 order by fechaRegistro desc           
END 