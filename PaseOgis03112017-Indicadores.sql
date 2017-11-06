--script para agregar menu Reportes en header

	UPDATE dbo.Menu
	set nombre = 'Listado de Reportes',
		descripcion = 'Listado de Reportes',
		URL = '/Reporte/Index',
		orden = 43,
		icon = 'listado_reportes.png'
	where idMenu = 14 and idMenuPadre = 5;
Go
--
If Not exists(select 's' from Dato where prefijo = 'Fecha Inicio Sintoma' )
insert into Dato (prefijo,sufijo,idTipo,idDatoDependiente,visible, obligatorio,idListaDato,idGenero,estado,fechaRegistro,idUsuarioRegistro)
select 'Fecha Inicio Sintoma', 'sintoma',2,0,0,0,78,3,1,GETDATE(),72;

Go
--
---
IF OBJECT_ID(N'FUN_OBTENER_DATO_VARIABLE_POR_ENFERMEDAD', N'FN') IS NOT NULL 
    DROP FUNCTION dbo.FUN_OBTENER_DATO_VARIABLE_POR_ENFERMEDAD ;
GO
--select dbo.FUN_OBTENER_DATO_VARIABLE_POR_ENFERMEDAD(1005634)
CREATE FUNCTION dbo.FUN_OBTENER_DATO_VARIABLE_POR_ENFERMEDAD 
(
	@idEnfermedad int--,
	--@datoPalabraClave varchar(20)
)
RETURNS INT
AS BEGIN
    DECLARE @idDato INT
	
	set @idDato =	(
						select
							d.idDato
						from DatoCategoriaDato dcd
						inner join EnfermedadCategoriaDato ecd
						on	dcd.idCategoriaDato = ecd.idCategoriaDato
						inner join Dato d
						on	dcd.idDato = d.idDato
						where
							(
								ecd.idEnfermedad = @idEnfermedad
								or
								@idEnfermedad = 0
							)
							AND
							(
								d.prefijo LIKE 'Fecha%Inicio%Síntoma' --like '%'+@datoPalabraClave+'%'
								or
								d.prefijo LIKE 'Fecha%Inicio%Sintoma'
							)
							AND
							D.idTipo = 2 --TIPO DATE
					)
					
	--select @idDato --test
    RETURN @idDato
END

---
Go
IF OBJECT_ID(N'pNLS_ReporteOportunidadAnalisisMuestras') IS NOT NULL 
    DROP PROCEDURE dbo.pNLS_ReporteOportunidadAnalisisMuestras ;
GO
/*******************************************c************************************
Descripcion: Obtener informacion de los establecimientos filtrado por :
             IdUsuario
Creado por: Jose Chavez
Fecha Creacion: 08/09/2017
Modificacion: Se agegaron comentarios
*******************************************************************************/

CREATE PROCEDURE  [dbo].[pNLS_ReporteOportunidadAnalisisMuestras]
@nombrefiltro			varchar(20),
@idjurisdiccion			varchar(50),
@fechainicio			date,
@fechafin				date,
@enfermedad				int

AS
BEGIN
	--declare @fechainicio		date
	--declare @fechafin			date
	--declare @nombrefiltro		varchar(20)
	declare @idestablecimiento	int
	--declare @idjurisdiccion		varchar(50)
	declare @totalmuestras		int
	declare @idsestablecimiento	varchar(100)
	--set @fechainicio = '2017-01-01'
	--set @fechafin = '2017-10-31'
	--declare @idenfermedad		int
	--declare @iddato				int
	
	--set @idenfermedad = case @enfermedad
	--						when 1 --tbc
	--							then 1005634
	--						when 2 --vih
	--							then 1005635
	--					end
	--set @idenfermedad = @enfermedad

	--agregar establecimiento por muestra
	declare @Muestras table	(	id int identity(1,1),
								idorden uniqueidentifier,
								idordenmuestra uniqueidentifier,
								fechaverificado date,
								fecharecepcionlaboratorio date,
								--fechadato date, --puede ser fecha inicio sintoma(tbc) o fecha solicitud (vih)
								diferenciadias int,
								establecimientocodigounico int,
								establecimientonombre varchar(200)
							)

	insert into @Muestras (idorden, idordenmuestra, fechaverificado, fecharecepcionlaboratorio, establecimientocodigounico, establecimientonombre)
	select
			om.idOrden,
			om.idOrdenMuestra,
			convert(date,oe.fechaValidado),
			CONVERT(date,omr.fechaRecepcionP),
			eess.codigoUnico,
			eess.nombre
	from	OrdenMuestra om(nolock)
	inner join Orden o(nolock)
		on om.idOrden = o.idOrden
	inner join Establecimiento eess (nolock)
		on o.idEstablecimiento = eess.idEstablecimiento
	inner join OrdenMuestraRecepcion omr (nolock)
		on	omr.idOrden = o.idOrden
	inner join OrdenExamen oe (nolock)
		on oe.idOrden =  o.idOrden
	
	---------------------
--	select fechaValidado from OrdenExamen where estatusE = 11 -- FEcha Resultado Validado
--select fechaRecepcionP from OrdenMuestraRecepcion where idOrden = '877D88EB-8D3F-4E21-BCB7-1AFA7D64AE3C' --FechaRecepcionLaboratorio
	
	---------------------
	
	where
		CONVERT(DATE,om.fechaRegistro) BETWEEN CONVERT(DATE, @fechainicio) AND CONVERT(DATE, @fechafin)
		and
		(
			@nombrefiltro = 'establecimiento' and CONVERT(varchar(50), eess.idEstablecimiento) = @idjurisdiccion--@idestablecimiento
			or
			@nombrefiltro = 'microred' and CONVERT(varchar(50), eess.idMicroRed) = @idjurisdiccion
			or
			@nombrefiltro = 'red' and CONVERT(varchar(50), eess.idRed) = @idjurisdiccion
			or
			@nombrefiltro = 'disa' and CONVERT(varchar(50), eess.idDISA) = @idjurisdiccion
			or
			@nombrefiltro = 'institucion' and CONVERT(varchar(50), eess.codigoInstitucion) = @idjurisdiccion
		)
		and
		oe.estatusE = 11 -- fecha resultado validado
		and
		(
			oe.idEnfermedad = @enfermedad
			or
			@enfermedad = 0
			or
			@enfermedad is null
		)
	order by om.fechaRegistro

	--set @totalmuestras = (select COUNT(1) from @Muestras)

	--hacer un update general a la tabla #Muestras set datediff (fecharegistro - fechainiciosintomas)
	--select  DATEDIFF(day, '2015-05-20', '2015-05-15')
	update @Muestras
	set diferenciadias = DATEDIFF(day, fecharecepcionlaboratorio, fechaverificado)

	select
		diferenciadias,
		convert(varchar(10),establecimientocodigounico) + ' - ' + establecimientonombre,
		COUNT(idordenmuestra) [totalmuestras]
	from @Muestras
	/*
		comprobar que este agrupamiento pueda traer algo como
		dias		eess		x muestras
	--------------------------------------------
		1			eess1		2
		2			eess1		1
		3			eess1		6
		4			eess2		2
		4			eess1		2
		
		si trae asi esta bien
	*/
	where
		diferenciadias is not null
	group by diferenciadias, establecimientocodigounico, establecimientonombre
	having COUNT(idordenmuestra) > 0 

	--select @totalmuestras
	--select * from @Muestras

END
go
---

IF OBJECT_ID(N'pNLS_ReporteOportunidadEnvioMuestras') IS NOT NULL 
    DROP PROCEDURE dbo.pNLS_ReporteOportunidadEnvioMuestras ;
GO
/*******************************************c************************************
Descripcion: Obtener informacion de los establecimientos filtrado por :
             IdUsuario
Creado por: Jose Chavez
Fecha Creacion: 08/09/2017
Modificacion: Se agegaron comentarios
*******************************************************************************/
--exec pNLS_PrimerReporte 'establecimiento', 994,'01092017','08102017',1
--exec pNLS_PrimerReporte @nombrefiltro='establecimiento',@idjurisdiccion='994',@fechainicio='2017-09-01 00:00:00',@fechafin='2017-10-08 00:00:00',@enfermedad=1
CREATE PROCEDURE  [dbo].[pNLS_ReporteOportunidadEnvioMuestras]
@nombrefiltro			varchar(20),
@idjurisdiccion			varchar(50),
@fechainicio			date,
@fechafin				date,
@enfermedad				int

AS
BEGIN
	--declare @fechainicio		date
	--declare @fechafin			date
	--declare @nombrefiltro		varchar(20)
	declare @idestablecimiento	int
	--declare @idjurisdiccion		varchar(50)
	declare @totalmuestras		int
	declare @idsestablecimiento	varchar(100)
	--set @fechainicio = '2017-01-01'
	--set @fechafin = '2017-10-31'
	--declare @idenfermedad		int
	--declare @iddato				int
	
	--set @idenfermedad = case @enfermedad
	--						when 1 --tbc
	--							then 1005634
	--						when 2 --vih
	--							then 1005635
	--					end
	--set @idenfermedad = @enfermedad

	--agregar establecimiento por muestra
	declare @Muestras table	(	id int identity(1,1),
								idorden uniqueidentifier,
								idordenmuestra uniqueidentifier,
								fecharegistro date,
								fecharecepcionmuestra date,
								--fechadato date, --puede ser fecha inicio sintoma(tbc) o fecha solicitud (vih)
								diferenciadias int,
								establecimientocodigounico int,
								establecimientonombre varchar(200)
							)

	insert into @Muestras (idorden, idordenmuestra, fecharegistro, fecharecepcionmuestra, establecimientocodigounico, establecimientonombre)
	select
			om.idOrden,
			om.idOrdenMuestra,
			convert(date,om.fechaRegistro),
			CONVERT(date,omr.fechaRecepcion),
			eess.codigoUnico,
			eess.nombre
	from	OrdenMuestra om(nolock)
	inner join Orden o(nolock)
		on om.idOrden = o.idOrden
	inner join OrdenExamen oe (nolock)
		on o.idOrden = oe.idOrden
	inner join Establecimiento eess (nolock)
		on o.idEstablecimiento = eess.idEstablecimiento
	inner join OrdenMuestraRecepcion omr (nolock)
		on	omr.idOrden = o.idOrden
	where
		CONVERT(DATE,om.fechaRegistro) BETWEEN CONVERT(DATE, @fechainicio) AND CONVERT(DATE, @fechafin)
		and
		(
			@nombrefiltro = 'establecimiento' and CONVERT(varchar(50), eess.idEstablecimiento) = @idjurisdiccion--@idestablecimiento
			or
			@nombrefiltro = 'microred' and CONVERT(varchar(50), eess.idMicroRed) = @idjurisdiccion
			or
			@nombrefiltro = 'red' and CONVERT(varchar(50), eess.idRed) = @idjurisdiccion
			or
			@nombrefiltro = 'disa' and CONVERT(varchar(50), eess.idDISA) = @idjurisdiccion
			or
			@nombrefiltro = 'institucion' and CONVERT(varchar(50), eess.codigoInstitucion) = @idjurisdiccion
		)
		and
		(
			oe.idEnfermedad = @enfermedad
			or
			@enfermedad = 0
			or
			@enfermedad is null
		)
	order by om.fechaRegistro

	set @totalmuestras = (select COUNT(1) from @Muestras)

	--hacer un update general a la tabla #Muestras set datediff (fecharegistro - fechainiciosintomas)
	--select  DATEDIFF(day, '2015-05-20', '2015-05-15')
	update @Muestras
	set diferenciadias = DATEDIFF(day, fecharecepcionmuestra, fecharegistro)

	select
		diferenciadias,
		establecimientocodigounico,
		COUNT(idordenmuestra) [totalmuestras]
	from @Muestras
	/*
		comprobar que este agrupamiento pueda traer algo como
		dias		eess		x muestras
	--------------------------------------------
		1			eess1		2
		2			eess1		1
		3			eess1		6
		4			eess2		2
		4			eess1		2
		
		si trae asi esta bien
	*/
	where
		diferenciadias is not null
	group by diferenciadias, establecimientocodigounico
	having COUNT(idordenmuestra) > 0 

	--select @totalmuestras
	--select * from @Muestras

END

Go
---

IF OBJECT_ID(N'pNLS_ReporteOportunidadObtencionMuestras') IS NOT NULL 
    DROP PROCEDURE dbo.pNLS_ReporteOportunidadObtencionMuestras ;
GO
/*******************************************************************************
Descripcion: Obtener informacion de los establecimientos filtrado por :
             IdUsuario
Creado por: Jose Chavez
Fecha Creacion: 08/09/2017
Modificacion: Se agegaron comentarios
*******************************************************************************/
--exec pNLS_PrimerReporte 'establecimiento', 994,'01092017','08102017',1
--exec pNLS_ReporteOportunidadObtencionMuestras @nombrefiltro='establecimiento',@idjurisdiccion='994',@fechainicio='2016-12-01 00:00:00',@fechafin='2017-10-25 00:00:00',@enfermedad=0
--select dbo.FUN_OBTENER_DATO_VARIABLE_POR_ENFERMEDAD(0)
CREATE PROCEDURE  [dbo].[pNLS_ReporteOportunidadObtencionMuestras]
@nombrefiltro			varchar(20),
--@idestablecimiento	int,
@idjurisdiccion			varchar(50),
@fechainicio			date,
@fechafin				date,
@enfermedad				int

AS
BEGIN
	declare @idDatoTable table (idDato int)
	
	--declare @enfermedad int
	--set @enfermedad = 1005634
	--select dbo.FUN_OBTENER_DATO_VARIABLE_POR_ENFERMEDAD(@enfermedad)
	insert into @idDatoTable (idDato) (select dbo.FUN_OBTENER_DATO_VARIABLE_POR_ENFERMEDAD(@enfermedad))
	
	declare @datoTableLength int
	set @datoTableLength = (select COUNT(1) from @idDatoTable)
	if(@datoTableLength = 0)
	begin
		--return 0
		select 0
	end
	else
	begin
		--select idDato from @idDatoTable
		declare @idestablecimiento	int
		declare @totalmuestras		int
		declare @idsestablecimiento	varchar(100)
		
		--agregar establecimiento por muestra
		declare @Muestras table	(	id int identity(1,1),
									idorden uniqueidentifier,
									idordenmuestra uniqueidentifier,
									fecharegistro date,
									--fechainiciosintoma date,
									fechadato date, --puede ser fecha inicio sintoma(tbc) o fecha solicitud (vih)
									diferenciadias int,
									establecimientocodigounico int,
									establecimientonombre varchar(200)
								)

		insert into @Muestras (idorden, idordenmuestra, fecharegistro, establecimientocodigounico, establecimientonombre)
		select
				om.idOrden,
				om.idOrdenMuestra,
				convert(date,om.fechaRegistro),
				eess.codigoUnico,
				eess.nombre
		from	OrdenMuestra om(nolock)
		inner join Orden o(nolock)
			on om.idOrden = o.idOrden
		inner join OrdenExamen oe (nolock)
			on o.idOrden = oe.idOrden
		inner join Establecimiento eess (nolock)
			on o.idEstablecimiento = eess.idEstablecimiento
		where
			CONVERT(DATE,om.fechaRegistro) BETWEEN CONVERT(DATE, @fechainicio) AND CONVERT(DATE, @fechafin)
			and
			(
				@nombrefiltro = 'establecimiento' and CONVERT(varchar(50), eess.idEstablecimiento) = @idjurisdiccion--@idestablecimiento
				or
				@nombrefiltro = 'microred' and CONVERT(varchar(50), eess.idMicroRed) = @idjurisdiccion
				or
				@nombrefiltro = 'red' and CONVERT(varchar(50), eess.idRed) = @idjurisdiccion
				or
				@nombrefiltro = 'disa' and CONVERT(varchar(50), eess.idDISA) = @idjurisdiccion
				or
				@nombrefiltro = 'institucion' and CONVERT(varchar(50), eess.codigoInstitucion) = @idjurisdiccion
			)
			and
			(
				oe.idEnfermedad = @enfermedad
				or
				@enfermedad = 0
				or
				@enfermedad is null
			)
		order by om.fechaRegistro

		set @totalmuestras = (select COUNT(1) from @Muestras)
		--select @totalmuestras
		declare @loopcounter int
		set @loopcounter = 1
		while(@loopcounter is not null and @loopcounter <= @totalmuestras)
		begin
			--select	idordenmuestra
			--from	@Muestras
			--where	id = @loopcounter
			
			declare @currentIdOrden uniqueidentifier	
			set @currentIdOrden = (select idOrden from @Muestras where id = @loopcounter)
			
			update	@Muestras
			set	fechadato =	(
								select
										distinct CONVERT(date, odc.valor, 103)
								from	OrdenDatoClinico odc(nolock)
								--inner join DatoCategoriaDato
								inner join	Dato d (nolock)
									on	odc.idDato = odc.idDato
								where
									odc.idOrden = @currentIdOrden
									and
									(
										odc.idEnfermedad = @enfermedad--1005634 --tuberculosis
										or
										--0=0
										@enfermedad = 0
									)
									and
									odc.idDato in (select idDato from @idDatoTable) --@iddato--423 -- dato creado 'fecha inicio sintomas' para enfermedad tuberculosis
									--odc.idDato in (423)
									and
									odc.valor is not null
									and
									odc.valor <> ''
							)
			where	id = @loopcounter	
			
			set @loopcounter = @loopcounter + 1
			continue
		end

		--hacer un update general a la tabla #Muestras set datediff (fecharegistro - fechainiciosintomas)
		--select  DATEDIFF(day, '2015-05-20', '2015-05-15')
		
		update @Muestras
		set diferenciadias = DATEDIFF(day, fechadato, fecharegistro)

		--select * from @Muestras
		select
			diferenciadias,
			establecimientocodigounico,
			COUNT(idordenmuestra) [totalmuestras]
		from @Muestras
		/*
			comprobar que este agrupamiento pueda traer algo como
			dias		eess		x muestras
		--------------------------------------------
			1			eess1		2
			2			eess1		1
			3			eess1		6
			4			eess2		2
			4			eess1		2
			
			si trae asi esta bien
		*/
		where
			diferenciadias is not null
		group by diferenciadias, establecimientocodigounico
		having COUNT(idordenmuestra) > 0 

		--select @totalmuestras
		--select * from @Muestras
	end
END
---
go
IF OBJECT_ID(N'pNLS_ReportePorcentajeResultadosEmitidos') IS NOT NULL 
    DROP PROCEDURE dbo.pNLS_ReportePorcentajeResultadosEmitidos ;
GO
/*******************************************c************************************
Descripcion: Obtener informacion de los establecimientos filtrado por :
             IdUsuario
Creado por: Jose Chavez
Fecha Creacion: 08/09/2017
Modificacion: Se agegaron comentarios
*******************************************************************************/
--exec pNLS_ReportePorcentajeResultadosEmitidos @nombrefiltro='institucion',@idjurisdiccion='20',@fechainicio='2017-01-01 00:00:00',@fechafin='2017-10-26 00:00:00',@enfermedad=0
CREATE PROCEDURE  [dbo].[pNLS_ReportePorcentajeResultadosEmitidos]
@nombrefiltro			varchar(20),
@idjurisdiccion			varchar(50),
@fechainicio			date,
@fechafin				date,
@enfermedad				int

AS
BEGIN
	declare @idestablecimiento	int	
	declare @totalmuestras		int
	declare @idsestablecimiento	varchar(100)

	declare @tablaNumerador table (TotalRV decimal, Establecimiento varchar(100))
	declare @tablaDenominador table (TotalMuestras decimal, Establecimiento varchar(100))
	declare @tablaResult table (Establecimiento varchar(100), TotalRV decimal, TotalMuestras decimal, Porcentaje decimal(7,4))
	
	--INSERTAR EN TABLA NUMERADOR
	--declare @nombrefiltro	varchar(25)
	--declare @idjurisdiccion	int
	--declare @enfermedad int
	--set	@nombrefiltro = 'institucion'
	--set	@idjurisdiccion = '12'
	--set @enfermedad = 0--1005634
	insert into @tablaNumerador (TotalRV, Establecimiento)
	select COUNT(1), eess.nombre
	from	OrdenExamen oe (nolock)
	inner join Orden o (nolock)
		on oe.idOrden = o.idOrden
	inner join OrdenMuestra om(nolock)
		on o.idOrden = om.idOrden
	inner join Establecimiento eess (nolock)
		on o.idEstablecimiento = eess.idEstablecimiento
	where
		CONVERT(DATE,om.fechaRegistro) BETWEEN CONVERT(DATE, @fechainicio) AND CONVERT(DATE, @fechafin)--between CONVERT(date, '2016-06-01') and CONVERT(date, '2017-10-30')
		and
		(
			@nombrefiltro = 'establecimiento' and CONVERT(varchar(50), eess.idEstablecimiento) = @idjurisdiccion
			or
			@nombrefiltro = 'microred' and CONVERT(varchar(50), eess.idMicroRed) = @idjurisdiccion
			or
			@nombrefiltro = 'red' and CONVERT(varchar(50), eess.idRed) = @idjurisdiccion
			or
			@nombrefiltro = 'disa' and CONVERT(varchar(50), eess.idDISA) = @idjurisdiccion
			or
			@nombrefiltro = 'institucion' and CONVERT(varchar(50), eess.codigoInstitucion) = @idjurisdiccion
		)
		and
		oe.estatusE = 11
		and
		(
			oe.idEnfermedad = @enfermedad
			or
			@enfermedad = 0
		)
	group by eess.nombre

	--INSERTAR EN TABLA DENOMINADOR
	insert into @tablaDenominador (TotalMuestras, Establecimiento)
	select	COUNT(1), eess.nombre
	from	OrdenMuestra om (nolock)
	inner join Orden o (nolock)
		on om.idOrden = om.idOrden
	inner join OrdenExamen oe (nolock)
		on o.idOrden = oe.idOrden
	inner join Establecimiento eess (nolock)
		on o.idEstablecimiento = eess.idEstablecimiento
	where
		CONVERT(DATE,om.fechaRegistro) BETWEEN CONVERT(DATE, @fechainicio) AND CONVERT(DATE, @fechafin)
		and
		(
			@nombrefiltro = 'establecimiento' and CONVERT(varchar(50), eess.idEstablecimiento) = @idjurisdiccion--@idestablecimiento
			or
			@nombrefiltro = 'microred' and CONVERT(varchar(50), eess.idMicroRed) = @idjurisdiccion
			or
			@nombrefiltro = 'red' and CONVERT(varchar(50), eess.idRed) = @idjurisdiccion
			or
			@nombrefiltro = 'disa' and CONVERT(varchar(50), eess.idDISA) = @idjurisdiccion
			or
			@nombrefiltro = 'institucion' and CONVERT(varchar(50), eess.codigoInstitucion) = @idjurisdiccion
		)
		and
		(
			oe.idEnfermedad = @enfermedad
			or
			@enfermedad = 0
		)
	group by eess.nombre--o.idEstablecimiento

	--select * from @tablaNumerador
	--select * from @tablaDenominador

	--JUNTAR DATOS EN TABLA RESULT
	insert into @tablaResult(Establecimiento, TotalRV, TotalMuestras, Porcentaje)
	select	den.Establecimiento, isnull(num.TotalRV,0), den.TotalMuestras, ((isnull(num.TotalRV,0.00)*100)/den.TotalMuestras)
	from	@tablaNumerador num
	right join @tablaDenominador den
		on	num.Establecimiento = den.Establecimiento

	select Establecimiento, TotalRV, TotalMuestras, Porcentaje
	from @tablaResult
END
---
GO
IF OBJECT_ID(N'pNLS_Redes') IS NOT NULL 
    DROP PROCEDURE dbo.pNLS_Redes ;
Go
--
/*******************************************************************************
Descripcion: Obtiene todas las redes.
Creado por: Jose Chavez
Fecha Creacion: 08/09/2017
*******************************************************************************/
CREATE PROCEDURE [dbo].[pNLS_Redes]
AS
BEGIN

SET NOCOUNT ON

SELECT	distinct
		r.idRed,
		r.idDISA,
		r.nombreRed,
		e.codigoInstitucion
FROM	Red r 
inner join Establecimiento e
	on
		r.idRed = e.idRed
		and
		r.idDISA = e.idDISA
WHERE	r.estado = 1
order by r.idRed 

END

GO
IF OBJECT_ID(N'pNLS_REDByUsuario') IS NOT NULL 
    DROP PROCEDURE dbo.pNLS_REDByUsuario ;
GO
/*******************************************************************************
Descripcion: Obtener informacion de los establecimientos filtrado por :
             IdUsuario
Creado por: Jose Chavez
Fecha Creacion: 08/09/2017
Modificacion: Se agegaron comentarios
*******************************************************************************/
--exec pNLS_REDByUsuario 190
CREATE PROCEDURE  [dbo].[pNLS_REDByUsuario]
@IdUsuario int
AS
BEGIN
	DECLARE @Tipo int
	SELECT @Tipo=idTipoUsuario from Usuario where idUsuario=@IdUsuario

	if @Tipo=2---ADMINISTRADOR GENERAL
	BEGIN
		SELECT distinct i.idRed,i.nombreRed, i.idDISA
		FROM Red i
		inner join Establecimiento ue on i.idRed=ue.idRed and ue.idDISA=i.idDISA
		where i.estado = 1
		order by i.idRed 
	END
	ELSE
	BEGIN
		SELECT distinct i.idRed,i.nombreRed, i.idDISA
		FROM Red i
		inner join UsuarioEstablecimiento ue on (i.idRed=ue.idRed or ue.idRed is null) and (ue.idDISA=i.idDISA or ue.idDisa is null)
		where i.estado = 1 and ue.estado=1 
		and ue.idUsuario=@IdUsuario
		order by i.idRed 
	END
END
GO
IF OBJECT_ID(N'pNLS_MicroRedes') IS NOT NULL 
    DROP PROCEDURE dbo.pNLS_MicroRedes ;
go
/*******************************************************************************
Descripcion: Obtiene todas las micro redes.
Creado por: Jose Chavez
Fecha Creacion: 08/09/2017
*******************************************************************************/
CREATE PROCEDURE [dbo].[pNLS_MicroRedes]
AS
BEGIN

SET NOCOUNT ON

SELECT	distinct
		m.idMicroRed,
		m.idRed,
		m.idDISA,
		m.nombreMicroRed,
		e.codigoInstitucion
FROM	MicroRed m
inner join Establecimiento e
	on
		m.idRed = e.idRed
		and
		m.idDISA = e.idDISA
WHERE	m.estado = 1
order by m.idMicroRed

END
go
IF OBJECT_ID(N'pNLS_Establecimientos') IS NOT NULL 
    DROP PROCEDURE dbo.pNLS_Establecimientos ;
GO

/*******************************************************************************
Descripcion: Obtiene todas las micro redes.
Creado por: Jose Chavez
Fecha Creacion: 08/09/2017
*******************************************************************************/
CREATE PROCEDURE [dbo].[pNLS_Establecimientos]
AS
BEGIN

SET NOCOUNT ON

SELECT	idEstablecimiento,
		idMicroRed,
		idRed,
		idDISA,
		e.codigoInstitucion,
		e.codigoUnico,
		e.codigoUnico + '-'+e.nombre nombre
FROM	Establecimiento e
INNER JOIN Ubigeo udepartemento (nolock) ON  udepartemento.idUbigeo = SUBSTRING(e.ubigeo,1,2)+'0000'
INNER JOIN Ubigeo uProvincia (nolock) ON  uProvincia.idUbigeo = SUBSTRING(e.ubigeo,1,4)+'00' 
INNER JOIN Ubigeo uDistrito (nolock) ON  uDistrito.idUbigeo = e.ubigeo
WHERE	e.estado = 1
ORDER BY e.nombre
END

GO


