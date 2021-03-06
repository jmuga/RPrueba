/*******************************************************************************
Descripcion: Metodo para obtener Muestras Rechazadas por ROM.
Creado por: Marcos Mejia
*******************************************************************************/

ALTER PROCEDURE [dbo].[pNLS_OrdenMuestraByEstablecimientoRechazado]  
	@FechaSolicitud int,   
	@IdUsuarioLogueado int,   
	@CodigoOrden varchar(200),   
	@FechaDesde date,   
	@FechaHasta date,   
	@NroOficio varchar(50),  
	@TipoOrden int,  
	@Estatus int,  
	@IdMuestra varchar(50),  
	@IdLaboratorio int  
AS  
--SET LANGUAGE 'Español'                
	BEGIN  
	 if @codigoOrden is null  
	   set @codigoOrden=''  

	 if @nroOficio is null  
	   set @nroOficio=''  

	 if @idMuestra is null  
	   set @idMuestra=''   

	IF @FechaSolicitud=1  
	BEGIN  
	PRINT 1
	 SELECT * FROM   
	  (  
		SELECT o.idOrden, o.codigoOrden as codigoOrden,o.nroOficio,'' as nroDocumento,p.nroDocumento as nroDocPaciente,   
		a.codificacion as nroDocAnimal,cb.codificacion as nroDocCepaBanco,o.estatus as estadoOrden,o.fechaSolicitud as fechaSolicitud,  
		o.fechaRegistro as fechaRegistro,e.nombre as nombreEstablecimiento, omr.conformeR,   
		(select top 1 1 as pertenceLab from OrdenMuestraRecepcion omrp (nolock)  
		where omrp.idOrden = o.idOrden and omrp.estatus in (1,2)     
		and omrp.idLaboratorioDestino = @IdLaboratorio and omrp.estado = 1) as EXISTE_PENDIENTE,  
		(select top 1 1 as pertenceLab from OrdenMuestraRecepcion omrp  (nolock)  
		where omrp.idOrden = o.idOrden and omrp.estatus = 2 and omrp.idLaboratorioOrigen = @IdLaboratorio  
		and omrp.idLaboratorioDestino <> @IdLaboratorio and omrp.estado = 1) as EXISTE_REFERENCIADO,  
		(select top 1 1 as pertenceLab from OrdenMuestraRecepcion omrp  (nolock)  
		where omrp.idOrden = o.idOrden and omrp.estatus in (3,5)     
		and omrp.idLaboratorioDestino = @IdLaboratorio and omrp.estado = 1) as EXISTE_RECIBIDO,  
		p.genero as genero,ldtd.glosa as tipoDocumento,ld.glosa nombreGenero,p.fechaNacimiento  
		FROM Orden o  
		INNER JOIN Establecimiento e (nolock) on o.idEstablecimiento = e.idEstablecimiento   
		LEFT JOIN  Paciente p (nolock) on o.idPaciente = p.idPaciente  
		LEFT JOIN Animal a (nolock) on o.idAnimal = a.idAnimal  
		LEFT JOIN CepaBancoSangre cb (nolock) on o.idCepaBancoSangre = cb.idCepaBancoSangre  
		LEFT JOIN ListaDetalle ld  (nolock) on p.genero = ld.idDetalleLista and ld.idLista = 4    
		LEFT JOIN ListaDetalle ldtd on p.tipoDocumento = ldtd.idDetalleLista and ldtd.idLista = 7   
		INNER JOIN OrdenMuestraRecepcion omr on o.idOrden = omr.idOrden 
		WHERE o.estado = 1 AND o.estatus <> 0  AND OMR.conformeR = 0
		AND (@NroOficio = '' OR @NroOficio IS NULL OR (LTRIM(RTRIM(o.nroOficio)) LIKE '%'+ LTRIM(RTRIM(@NroOficio)) + '%'))  
		AND (@CodigoOrden = '' OR @CodigoOrden IS NULL OR (LTRIM(RTRIM(o.codigoOrden)) LIKE '%'+ LTRIM(RTRIM(@CodigoOrden)) + '%'))
		AND o.fechaSolicitud between @FechaDesde AND @FechaHasta
		AND (EXISTS(select '' from OrdenMuestra oxs inner join MuestraCodificacion mcx on oxs.idMuestraCod = mcx.idMuestraCod   
		where (LTRIM(RTRIM(mcx.codificacion)) LIKE '%'+ LTRIM(RTRIM(@IdMuestra)) +'%' and oxs.idOrden = o.idOrden)))) o2  
		WHERE ((@Estatus = 0 AND (o2.EXISTE_PENDIENTE IS NOT NULL OR o2.EXISTE_RECIBIDO IS NOT NULL))  
		OR (@Estatus = 1 AND o2.EXISTE_PENDIENTE IS NOT NULL AND o2.EXISTE_RECIBIDO IS NULL)  
		OR (@Estatus = 2 AND o2.EXISTE_RECIBIDO IS NOT NULL )  
		OR (@Estatus = 3 AND o2.EXISTE_REFERENCIADO IS NOT NULL)) 
		ORDER BY o2.fechaRegistro DESC  
	END
	ELSE  
	BEGIN  
	SELECT * FROM   
	(  
		SELECT o.idOrden, o.codigoOrden as codigoOrden,o.nroOficio,'' as nroDocumento,p.nroDocumento as nroDocPaciente,   
		a.codificacion as nroDocAnimal,cb.codificacion as nroDocCepaBanco,o.estatus as estadoOrden,o.fechaSolicitud as fechaSolicitud,  
		o.fechaRegistro as fechaRegistro,e.nombre as nombreEstablecimiento, omr.conformeR,     
		(select top 1 1 as pertenceLab from OrdenMuestraRecepcion omrp (nolock)  
		where omrp.idOrden = o.idOrden and omrp.estatus in (1,2)     
		and omrp.idLaboratorioDestino = @IdLaboratorio and omrp.estado = 1) as EXISTE_PENDIENTE,  
		(select top 1 1 as pertenceLab from OrdenMuestraRecepcion omrp  (nolock)  
		where omrp.idOrden = o.idOrden and omrp.estatus = 2 and omrp.idLaboratorioOrigen = @IdLaboratorio  
		and omrp.idLaboratorioDestino <> @IdLaboratorio and omrp.estado = 1) as EXISTE_REFERENCIADO,  
		(select top 1 1 as pertenceLab from OrdenMuestraRecepcion omrp  (nolock)  
		where omrp.idOrden = o.idOrden and omrp.estatus in (3,5)     
		and omrp.idLaboratorioDestino = @IdLaboratorio and omrp.estado = 1) as EXISTE_RECIBIDO,  
		p.genero as genero,ldtd.glosa as tipoDocumento,ld.glosa nombreGenero,p.fechaNacimiento  
		FROM Orden o  
		INNER JOIN Establecimiento e (nolock) on o.idEstablecimiento = e.idEstablecimiento   
		LEFT JOIN  Paciente p (nolock) on o.idPaciente = p.idPaciente  
		LEFT JOIN Animal a (nolock) on o.idAnimal = a.idAnimal  
		LEFT JOIN CepaBancoSangre cb (nolock) on o.idCepaBancoSangre = cb.idCepaBancoSangre  
		LEFT JOIN ListaDetalle ld  (nolock) on p.genero = ld.idDetalleLista and ld.idLista = 4    
		LEFT JOIN ListaDetalle ldtd on p.tipoDocumento = ldtd.idDetalleLista and ldtd.idLista = 7 
		INNER JOIN OrdenMuestraRecepcion omr on o.idOrden = omr.idOrden   
		WHERE o.estado = 1 AND o.estatus <> 0  AND OMR.conformeR = 0
		AND (@NroOficio = '' OR @NroOficio IS NULL OR (LTRIM(RTRIM(o.nroOficio)) LIKE '%'+ LTRIM(RTRIM(@NroOficio)) + '%'))  
		AND (@CodigoOrden = '' OR @CodigoOrden IS NULL OR (LTRIM(RTRIM(o.codigoOrden)) LIKE '%'+ LTRIM(RTRIM(@CodigoOrden)) + '%'))
		AND o.idOrden IN (select idOrden from OrdenMuestra 
		where fechaColeccion BETWEEN @FechaDesde AND @FechaHasta)
		AND (@IdMuestra is null OR EXISTS(select '' from OrdenMuestra oxs inner join MuestraCodificacion mcx on oxs.idMuestraCod = mcx.idMuestraCod   
		where (@IdMuestra = '' or @IdMuestra is null or LTRIM(RTRIM(mcx.codificacion)) LIKE '%'+ LTRIM(RTRIM(@IdMuestra)) +'%' and oxs.idOrden = o.idOrden)))) o2  
		WHERE ((@Estatus = 0 AND (o2.EXISTE_PENDIENTE IS NOT NULL OR o2.EXISTE_RECIBIDO IS NOT NULL))  
		OR (@Estatus = 1 AND o2.EXISTE_PENDIENTE IS NOT NULL AND o2.EXISTE_RECIBIDO IS NULL)  
		OR (@Estatus = 2 AND o2.EXISTE_RECIBIDO IS NOT NULL )  
		OR (@Estatus = 3 AND o2.EXISTE_REFERENCIADO IS NOT NULL))  
		ORDER BY o2.fechaRegistro DESC  
	END  
END 