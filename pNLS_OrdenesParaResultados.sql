alter PROCEDURE [dbo].[pNLS_OrdenesParaResultados]     
@Tipo int,    
@IdEstablecimientoLogin int,    
@IdUsuario int,     
@NroDocumento varchar(50),     
@FechaDesde date,     
@FechaHasta date,    
@NroOficio varchar(50),    
@CodigoOrden varchar(50),    
@CodigoMuestra varchar(50),    
@Estatus int    
AS    
BEGIN    
 if @NroDocumento is null    
  set @NroDocumento=''    
    
 if @NroOficio is null    
  set @NroOficio=''    
    
 if @CodigoOrden is null    
  set @CodigoOrden=''    
    
 if @CodigoMuestra is null    
  set @CodigoMuestra=''    
      
SET NOCOUNT ON    
if @Tipo=1    
BEGIN    
 IF @Estatus=0    
 BEGIN    
  select distinct o.idOrden, o.idEstablecimiento, e.nombre, e.codigoUnico, p.nroDocumento,o.fechaSolicitud as fechaSolicitud,     
  o.fechaRegistro as fechaRegistro, o.idPaciente,o.codigoOrden, o.nroOficio,ldtd.glosa TipoDocumento, ld.glosa NombreGenero, o.estatus,omr.estatusP,    
  p.fechaNacimiento as fechaNacimiento,count(omr.conformeP) validadas, count(omr.idOrdenMuestraRecepcion) muestras,dbo.fNLS_MostrarVentanaResultados(o.idOrden,@IdEstablecimientoLogin)FlagResultado    
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
   and o.estado = 1 and oe.estado = 1 and om.estado = 1 and omr.conformeR=1 and omr.estado = 1 and oma.estado=1    
   and (@NroOficio is null or @NroOficio = '' or (LTRIM(RTRIM(o.nroOficio)) LIKE '%'+ LTRIM(RTRIM(@NroOficio)) + '%'))    
   and (@NroDocumento is null or @NroDocumento = '' or (LTRIM(RTRIM(p.nroDocumento)) LIKE '%'+ LTRIM(RTRIM(@NroDocumento)) + '%')  )  
   and (@CodigoMuestra is null or @CodigoMuestra = '' or ((LTRIM(RTRIM(mc.codificacion)) LIKE '%'+ LTRIM(RTRIM(@CodigoMuestra)) + '%') )   
   or (LTRIM(RTRIM(o.codigoOrden)) LIKE '%'+ LTRIM(RTRIM(@CodigoMuestra)) + '%'))    
   and omr.idLaboratorioDestino =@IdEstablecimientoLogin     
   AND o.fechaSolicitud between @FechaDesde AND @FechaHasta--convert(varchar(10),convert(datetime,@FechaHasta)+1,112)    
  group by  o.idOrden, o.idEstablecimiento, e.nombre, e.codigoUnico, p.nroDocumento, fechaSolicitud, o.fechaRegistro, o.idPaciente, o.codigoOrden, o.nroOficio, ldtd.glosa, ld.glosa, o.estatus,omr.estatusP,fechaNacimiento     
  order by fechaSolicitud desc     
 END
	
	if @Estatus = 7
	
			BEGIN
				  select distinct o.idOrden, o.idEstablecimiento, e.nombre, e.codigoUnico, p.nroDocumento,o.fechaSolicitud as fechaSolicitud,     
				  o.fechaRegistro as fechaRegistro, o.idPaciente,o.codigoOrden, o.nroOficio,ldtd.glosa TipoDocumento, ld.glosa NombreGenero, o.estatus,omr.estatusP,    
				  p.fechaNacimiento as fechaNacimiento,count(omr.conformeP) validadas, count(omr.idOrdenMuestraRecepcion) muestras,dbo.fNLS_MostrarVentanaResultados(o.idOrden,@IdEstablecimientoLogin)FlagResultado    
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
				  where o.estatus in (2,3) and o.estado = 1 and omr.estatus = 3 and omr.estado = 1 and omr.estatusR=3 AND OE.conforme=0 AND OE.validado=0 --omr.estatusP=@Estatus    
				   and o.estado = 1 and oe.estado = 1 and om.estado = 1 and omr.conformeR=1 and omr.estado = 1 and oma.estado=1    
				   and (@NroOficio is null or @NroOficio = '' or (LTRIM(RTRIM(o.nroOficio)) LIKE '%'+ LTRIM(RTRIM(@NroOficio)) + '%'))    
				   and (@NroDocumento is null or @NroDocumento = '' or (LTRIM(RTRIM(p.nroDocumento)) LIKE '%'+ LTRIM(RTRIM(@NroDocumento)) + '%')  )  
				   and (@CodigoMuestra is null or @CodigoMuestra = '' or ((LTRIM(RTRIM(mc.codificacion)) LIKE '%'+ LTRIM(RTRIM(@CodigoMuestra)) + '%') )   
				   or (LTRIM(RTRIM(o.codigoOrden)) LIKE '%'+ LTRIM(RTRIM(@CodigoMuestra)) + '%'))    
				   and omr.idLaboratorioDestino =@IdEstablecimientoLogin     
				   AND o.fechaSolicitud between @FechaDesde AND @FechaHasta--convert(varchar(10),convert(datetime,@FechaHasta)+1,112)   
				  group by  o.idOrden, o.idEstablecimiento, e.nombre, e.codigoUnico, p.nroDocumento, fechaSolicitud, o.fechaRegistro, o.idPaciente, o.codigoOrden, o.nroOficio, ldtd.glosa, ld.glosa, o.estatus,omr.estatusP,fechaNacimiento     
				  order by fechaSolicitud desc     
		 END    
 
     
 ELSE    
  
 BEGIN
 
    
  select distinct o.idOrden, o.idEstablecimiento, e.nombre, e.codigoUnico, p.nroDocumento,o.fechaSolicitud as fechaSolicitud,     
  o.fechaRegistro as fechaRegistro, o.idPaciente,o.codigoOrden, o.nroOficio,ldtd.glosa TipoDocumento, ld.glosa NombreGenero, o.estatus,omr.estatusP,    
  p.fechaNacimiento as fechaNacimiento,count(omr.conformeP) validadas, count(omr.idOrdenMuestraRecepcion) muestras,dbo.fNLS_MostrarVentanaResultados(o.idOrden,@IdEstablecimientoLogin)FlagResultado    
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
  where o.estatus in (2,3) and o.estado = 1 and omr.estatus = 3 and omr.estado = 1 and omr.estatusR=3 AND omr.estatusP=@Estatus    
   and o.estado = 1 and oe.estado = 1 and om.estado = 1 and omr.conformeR=1 and omr.estado = 1 and oma.estado=1    
   and (@NroOficio is null or @NroOficio = '' or (LTRIM(RTRIM(o.nroOficio)) LIKE '%'+ LTRIM(RTRIM(@NroOficio)) + '%'))    
   and (@NroDocumento is null or @NroDocumento = '' or (LTRIM(RTRIM(p.nroDocumento)) LIKE '%'+ LTRIM(RTRIM(@NroDocumento)) + '%')  )  
   and (@CodigoMuestra is null or @CodigoMuestra = '' or ((LTRIM(RTRIM(mc.codificacion)) LIKE '%'+ LTRIM(RTRIM(@CodigoMuestra)) + '%') )   
   or (LTRIM(RTRIM(o.codigoOrden)) LIKE '%'+ LTRIM(RTRIM(@CodigoMuestra)) + '%'))    
   and omr.idLaboratorioDestino =@IdEstablecimientoLogin     
   AND o.fechaSolicitud between @FechaDesde AND @FechaHasta--convert(varchar(10),convert(datetime,@FechaHasta)+1,112)   
  group by  o.idOrden, o.idEstablecimiento, e.nombre, e.codigoUnico, p.nroDocumento, fechaSolicitud, o.fechaRegistro, o.idPaciente, o.codigoOrden, o.nroOficio, ldtd.glosa, ld.glosa, o.estatus,omr.estatusP,fechaNacimiento     
  order by fechaSolicitud desc     
 END    
ENd    
ELSE    
BEGIN    
 IF @Estatus=0    
 BEGIN    
  select distinct o.idOrden, o.idEstablecimiento, e.nombre, e.codigoUnico, p.nroDocumento,o.fechaSolicitud as fechaSolicitud,     
  o.fechaRegistro as fechaRegistro, o.idPaciente,o.codigoOrden, o.nroOficio,ldtd.glosa TipoDocumento, ld.glosa NombreGenero, o.estatus,omr.estatusP,    
  p.fechaNacimiento as fechaNacimiento,count(omr.conformeP) validadas, count(omr.idOrdenMuestraRecepcion) muestras,dbo.fNLS_MostrarVentanaResultados(o.idOrden,@IdEstablecimientoLogin)FlagResultado    
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
  where o.estatus in (2,3) and o.estado = 1 and omr.estatus = 3 and omr.estado = 1 and omr.estatusR=3 --and (oe.validado = 0 or oe.validado is null)    
   and o.estado = 1 and oe.estado = 1 and om.estado = 1 and omr.conformeR=1 and omr.estado = 1 and oma.estado=1    
   and (@NroOficio is null or @NroOficio = '' or (LTRIM(RTRIM(o.nroOficio)) LIKE '%'+ LTRIM(RTRIM(@NroOficio)) + '%'))    
   and (@NroDocumento is null or @NroDocumento = '' or (LTRIM(RTRIM(p.nroDocumento)) LIKE '%'+ LTRIM(RTRIM(@NroDocumento)) + '%')  )  
   and (@CodigoMuestra is null or @CodigoMuestra = '' or ((LTRIM(RTRIM(mc.codificacion)) LIKE '%'+ LTRIM(RTRIM(@CodigoMuestra)) + '%') )   
   or (LTRIM(RTRIM(o.codigoOrden)) LIKE '%'+ LTRIM(RTRIM(@CodigoMuestra)) + '%'))    
   and omr.idLaboratorioDestino =@IdEstablecimientoLogin     
   AND o.fechaSolicitud between @FechaDesde AND @FechaHasta--convert(varchar(10),convert(datetime,@FechaHasta)+1,112)   
  group by  o.idOrden, o.idEstablecimiento, e.nombre, e.codigoUnico, p.nroDocumento, fechaSolicitud, o.fechaRegistro, o.idPaciente, o.codigoOrden, o.nroOficio, ldtd.glosa, ld.glosa, o.estatus,omr.estatusP,fechaNacimiento     
  order by fechaRegistro desc    
 END
			if @Estatus = 7
	
			BEGIN
				  select distinct o.idOrden, o.idEstablecimiento, e.nombre, e.codigoUnico, p.nroDocumento,o.fechaSolicitud as fechaSolicitud,     
				  o.fechaRegistro as fechaRegistro, o.idPaciente,o.codigoOrden, o.nroOficio,ldtd.glosa TipoDocumento, ld.glosa NombreGenero, o.estatus,omr.estatusP,    
				  p.fechaNacimiento as fechaNacimiento,count(omr.conformeP) validadas, count(omr.idOrdenMuestraRecepcion) muestras,dbo.fNLS_MostrarVentanaResultados(o.idOrden,@IdEstablecimientoLogin)FlagResultado    
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
				  
				  where o.estatus in (2,3) and o.estado = 1 and omr.estatus = 3 and omr.estado = 1 and omr.estatusR=3 AND oe.conforme=0 and oe.validado=0 --omr.estatusP=@Estatus    
				   and o.estado = 1 and oe.estado = 1 and om.estado = 1 and omr.conformeR=1 and omr.estado = 1 and oma.estado=1    
				   and (@NroOficio is null or @NroOficio = '' or (LTRIM(RTRIM(o.nroOficio)) LIKE '%'+ LTRIM(RTRIM(@NroOficio)) + '%'))    
				   and (@NroDocumento is null or @NroDocumento = '' or (LTRIM(RTRIM(p.nroDocumento)) LIKE '%'+ LTRIM(RTRIM(@NroDocumento)) + '%')  )  
				   and (@CodigoMuestra is null or @CodigoMuestra = '' or ((LTRIM(RTRIM(mc.codificacion)) LIKE '%'+ LTRIM(RTRIM(@CodigoMuestra)) + '%') )   
				   or (LTRIM(RTRIM(o.codigoOrden)) LIKE '%'+ LTRIM(RTRIM(@CodigoMuestra)) + '%'))    
				   and omr.idLaboratorioDestino =@IdEstablecimientoLogin     
				   AND o.fechaSolicitud between @FechaDesde AND @FechaHasta--convert(varchar(10),convert(datetime,@FechaHasta)+1,112)    
				  
				  
				  group by  o.idOrden, o.idEstablecimiento, e.nombre, e.codigoUnico, p.nroDocumento, fechaSolicitud, o.fechaRegistro, o.idPaciente, o.codigoOrden, o.nroOficio, ldtd.glosa, ld.glosa, o.estatus,omr.estatusP,fechaNacimiento     
				  order by fechaSolicitud desc    
		 END  
		     
 ELSE    
 BEGIN    
  select distinct o.idOrden, o.idEstablecimiento, e.nombre, e.codigoUnico, p.nroDocumento,o.fechaSolicitud as fechaSolicitud,     
  o.fechaRegistro as fechaRegistro, o.idPaciente,o.codigoOrden, o.nroOficio,ldtd.glosa TipoDocumento, ld.glosa NombreGenero, o.estatus,omr.estatusP,    
  p.fechaNacimiento as fechaNacimiento,count(omr.conformeP) validadas, count(omr.idOrdenMuestraRecepcion) muestras,dbo.fNLS_MostrarVentanaResultados(o.idOrden,@IdEstablecimientoLogin)FlagResultado    
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
  
  where o.estatus in (2,3) and o.estado = 1 and omr.estatus = 3 and omr.estado = 1 and omr.estatusR=3 AND omr.estatusP=@Estatus    
   and o.estado = 1 and oe.estado = 1 and om.estado = 1 and omr.conformeR=1 and omr.estado = 1 and oma.estado=1    
   and (@NroOficio is null or @NroOficio = '' or (LTRIM(RTRIM(o.nroOficio)) LIKE '%'+ LTRIM(RTRIM(@NroOficio)) + '%'))    
   and (@NroDocumento is null or @NroDocumento = '' or (LTRIM(RTRIM(p.nroDocumento)) LIKE '%'+ LTRIM(RTRIM(@NroDocumento)) + '%')  )  
   and (@CodigoMuestra is null or @CodigoMuestra = '' or ((LTRIM(RTRIM(mc.codificacion)) LIKE '%'+ LTRIM(RTRIM(@CodigoMuestra)) + '%') )   
   or (LTRIM(RTRIM(o.codigoOrden)) LIKE '%'+ LTRIM(RTRIM(@CodigoMuestra)) + '%'))    
   and omr.idLaboratorioDestino =@IdEstablecimientoLogin     
   AND o.fechaSolicitud between @FechaDesde AND @FechaHasta--convert(varchar(10),convert(datetime,@FechaHasta)+1,112)    
  
  
  group by  o.idOrden, o.idEstablecimiento, e.nombre, e.codigoUnico, p.nroDocumento, fechaSolicitud, o.fechaRegistro, o.idPaciente, o.codigoOrden, o.nroOficio, ldtd.glosa, ld.glosa, o.estatus,omr.estatusP,fechaNacimiento     
  order by fechaSolicitud desc     
 END    
END    
END    
    
    