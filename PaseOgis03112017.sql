ALTER TABLE ordenExamen ADD estatusSol int Default 0,fechaSol datetime, observaSol Varchar(100),idUsuarioSol int ;
ALTER TABLE OrdenMuestraRecepcion ADD secuenObtencion int;
--
ALTER TABLE OrdenResultadoAnalito   ADD idSecuen int;
Update OrdenResultadoAnalito set idSecuen = 1;
ALTER TABLE OrdenResultadoAnalito ALTER COLUMN idSecuen int NOT NULL
--borrar  de OrdenResultadoAnalito
ALTER TABLE OrdenResultadoAnalito DROP CONSTRAINT PK_OrdenResultadoAnalito 
ALTER TABLE [dbo].[OrdenResultadoAnalito] ADD  CONSTRAINT [PK_OrdenResultadoAnalito] PRIMARY KEY CLUSTERED 
(
	[idOrdenExamen] ASC,
	[idAnalito] ASC,
	[idSecuen] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
GO
--Cambia de posición el campo idSecuen
--
/* To prevent any potential data loss issues, you should review this script in detail before running it outside the context of the database designer.*/
BEGIN TRANSACTION
SET QUOTED_IDENTIFIER ON
SET ARITHABORT ON
SET NUMERIC_ROUNDABORT OFF
SET CONCAT_NULL_YIELDS_NULL ON
SET ANSI_NULLS ON
SET ANSI_PADDING ON
SET ANSI_WARNINGS ON
COMMIT
BEGIN TRANSACTION
GO
ALTER TABLE dbo.OrdenResultadoAnalito
	DROP CONSTRAINT FK_OrdenResultadoAnalito_OrdenExamen
GO
ALTER TABLE dbo.OrdenExamen SET (LOCK_ESCALATION = TABLE)
GO
COMMIT
select Has_Perms_By_Name(N'dbo.OrdenExamen', 'Object', 'ALTER') as ALT_Per, Has_Perms_By_Name(N'dbo.OrdenExamen', 'Object', 'VIEW DEFINITION') as View_def_Per, Has_Perms_By_Name(N'dbo.OrdenExamen', 'Object', 'CONTROL') as Contr_Per BEGIN TRANSACTION
GO
ALTER TABLE dbo.OrdenResultadoAnalito
	DROP CONSTRAINT FK_OrdenResultadoAnalito_Analito
GO
ALTER TABLE dbo.Analito SET (LOCK_ESCALATION = TABLE)
GO
COMMIT
select Has_Perms_By_Name(N'dbo.Analito', 'Object', 'ALTER') as ALT_Per, Has_Perms_By_Name(N'dbo.Analito', 'Object', 'VIEW DEFINITION') as View_def_Per, Has_Perms_By_Name(N'dbo.Analito', 'Object', 'CONTROL') as Contr_Per BEGIN TRANSACTION
GO
ALTER TABLE dbo.OrdenResultadoAnalito
	DROP CONSTRAINT DF_OrdenResultadoAnalito_idOrdenResultadoAnalito
GO
ALTER TABLE dbo.OrdenResultadoAnalito
	DROP CONSTRAINT DF_OrdenResultadoAnalito_estado
GO
ALTER TABLE dbo.OrdenResultadoAnalito
	DROP CONSTRAINT DF_OrdenResultadoAnalito_fechaRegistro
GO
CREATE TABLE dbo.Tmp_OrdenResultadoAnalito
	(
	idOrdenResultadoAnalito uniqueidentifier NOT NULL,
	idOrdenExamen uniqueidentifier NOT NULL,
	idAnalito uniqueidentifier NOT NULL,
	idSecuen int NOT NULL,
	orden int NULL,
	codigoOpcion nchar(10) NULL,
	resultado varchar(2000) NULL,
	observacion varchar(1000) NULL,
	estado int NOT NULL,
	fechaRegistro datetime NOT NULL,
	idUsuarioRegistro int NULL,
	fechaEdicion datetime NULL,
	idUsuarioEdicion int NULL
	)  ON [PRIMARY]
GO
ALTER TABLE dbo.Tmp_OrdenResultadoAnalito SET (LOCK_ESCALATION = TABLE)
GO
ALTER TABLE dbo.Tmp_OrdenResultadoAnalito ADD CONSTRAINT
	DF_OrdenResultadoAnalito_idOrdenResultadoAnalito DEFAULT (newid()) FOR idOrdenResultadoAnalito
GO
ALTER TABLE dbo.Tmp_OrdenResultadoAnalito ADD CONSTRAINT
	DF_OrdenResultadoAnalito_estado DEFAULT ((1)) FOR estado
GO
ALTER TABLE dbo.Tmp_OrdenResultadoAnalito ADD CONSTRAINT
	DF_OrdenResultadoAnalito_fechaRegistro DEFAULT (getdate()) FOR fechaRegistro
GO
IF EXISTS(SELECT * FROM dbo.OrdenResultadoAnalito)
	 EXEC('INSERT INTO dbo.Tmp_OrdenResultadoAnalito (idOrdenResultadoAnalito, idOrdenExamen, idAnalito, idSecuen, orden, codigoOpcion, resultado, observacion, estado, fechaRegistro, idUsuarioRegistro, fechaEdicion, idUsuarioEdicion)
		SELECT idOrdenResultadoAnalito, idOrdenExamen, idAnalito, idSecuen, orden, codigoOpcion, resultado, observacion, estado, fechaRegistro, idUsuarioRegistro, fechaEdicion, idUsuarioEdicion FROM dbo.OrdenResultadoAnalito WITH (HOLDLOCK TABLOCKX)')
GO
DROP TABLE dbo.OrdenResultadoAnalito
GO
EXECUTE sp_rename N'dbo.Tmp_OrdenResultadoAnalito', N'OrdenResultadoAnalito', 'OBJECT' 
GO
ALTER TABLE dbo.OrdenResultadoAnalito ADD CONSTRAINT
	PK_OrdenResultadoAnalito PRIMARY KEY CLUSTERED 
	(
	idOrdenExamen,
	idAnalito,
	idSecuen
	) WITH( STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]

GO
ALTER TABLE dbo.OrdenResultadoAnalito ADD CONSTRAINT
	FK_OrdenResultadoAnalito_Analito FOREIGN KEY
	(
	idAnalito
	) REFERENCES dbo.Analito
	(
	idAnalito
	) ON UPDATE  NO ACTION 
	 ON DELETE  NO ACTION 
	
GO
ALTER TABLE dbo.OrdenResultadoAnalito ADD CONSTRAINT
	FK_OrdenResultadoAnalito_OrdenExamen FOREIGN KEY
	(
	idOrdenExamen
	) REFERENCES dbo.OrdenExamen
	(
	idOrdenExamen
	) ON UPDATE  NO ACTION 
	 ON DELETE  NO ACTION 
	
GO
COMMIT
select Has_Perms_By_Name(N'dbo.OrdenResultadoAnalito', 'Object', 'ALTER') as ALT_Per, 
Has_Perms_By_Name(N'dbo.OrdenResultadoAnalito', 'Object', 'VIEW DEFINITION') as View_def_Per, 
Has_Perms_By_Name(N'dbo.OrdenResultadoAnalito', 'Object', 'CONTROL') as Contr_Per 
--
UPDATE OrdenExamen
SET estatusSol = 0

--SP
Go

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

Go
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

Go

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
@IdLaboratorioUsuario int      
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
 oe.estatusSol,  
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
  --and (LTRIM(RTRIM(o.nroOficio)) LIKE '%'+ LTRIM(RTRIM(@NroOficio)) + '%')      
  and (@NroDocumento is null or @NroDocumento = '' or LTRIM(RTRIM(p.nroDocumento)) LIKE '%'+ LTRIM(RTRIM(@NroDocumento)) + '%')      
  --and ((LTRIM(RTRIM(mc.codificacion)) LIKE '%'+ LTRIM(RTRIM(@CodigoOrden)) + '%')      
  --or (LTRIM(RTRIM(o.codigoOrden)) LIKE '%'+ LTRIM(RTRIM(@CodigoOrden)) + '%'))      
  and omr.idLaboratorioDestino =@IdLaboratorioUsuario       
  AND o.fechaSolicitud between @FechaDesde AND convert(varchar(10),convert(datetime,@FechaHasta)+1,112)      
 group by  o.idOrden, o.idEstablecimiento, e.nombre, e.codigoUnico, p.nroDocumento, 
 fechaSolicitud, o.fechaRegistro, o.idPaciente, o.codigoOrden, o.nroOficio, ldtd.glosa, ld.glosa, o.estatus,
 omr.estatusP,P.genero,fechaNacimiento,OM.fechaColeccion,estatusSol     
 order by fechaRegistro desc       
END      
ELSE      
BEGIN      
 select distinct o.idOrden, o.idEstablecimiento, e.nombre AS NombEstab, e.codigoUnico, p.nroDocumento,o.fechaSolicitud as fechaSolicitud,      
 o.fechaRegistro as fechaRegistro, o.idPaciente,o.codigoOrden AS CodOrden, o.nroOficio,      
 ldtd.glosa TipoDocumento, ld.glosa NombreGenero, o.estatus,omr.estatusP,P.genero,       
 p.fechaNacimiento as fechaNacimiento,OM.fechaColeccion,  
   
 /**SOTERO MODIFICACION STORE SOLICTA VERIFICADOR INGRESO NUEVO RESULTADO---24-10-2017*/  
 oe.estatusSol,  
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
  --and (LTRIM(RTRIM(o.nroOficio)) LIKE '%'+ LTRIM(RTRIM(@NroOficio)) + '%')      
  and (@NroDocumento is null or @NroDocumento = '' or LTRIM(RTRIM(p.nroDocumento)) LIKE '%'+ LTRIM(RTRIM(@NroDocumento)) + '%')      
  --and ((LTRIM(RTRIM(mc.codificacion)) LIKE '%'+ LTRIM(RTRIM(@CodigoOrden)) + '%')      
  --or (LTRIM(RTRIM(o.codigoOrden)) LIKE '%'+ LTRIM(RTRIM(@CodigoOrden)) + '%'))      
  and omr.idLaboratorioDestino =@IdLaboratorioUsuario       
  AND om.fechaColeccion between @FechaDesde AND convert(varchar(10),convert(datetime,@FechaHasta)+1,112)      
 group by  o.idOrden, o.idEstablecimiento, e.nombre, e.codigoUnico, p.nroDocumento, fechaSolicitud, o.fechaRegistro, o.idPaciente, 
 o.codigoOrden, o.nroOficio, ldtd.glosa, ld.glosa, o.estatus,omr.estatusP,P.genero,fechaNacimiento,OM.fechaColeccion,estatusSol     
 order by fechaRegistro desc       
END      

Go
IF OBJECT_ID(N'pNLS_ValidacionesSolicitudes') IS NOT NULL 
    DROP PROCEDURE dbo.pNLS_ValidacionesSolicitudes ;
GO
/*******************************************************************************    
Descripcion: Obtiene informacion de las ordenes listas para la LIBERACION de resultados.    
Creado por: SOTERO BUSTAMANTE    
Fecha Creacion: 28/10/2017    
Modificacion: Se agegaron comentarios    
*******************************************************************************/    
CREATE PROCEDURE [dbo].[pNLS_ValidacionesSolicitudes]      
@idUsuario int,      
@FechaSolicitud int,      
@CodigoOrden varchar(20),      
@FechaDesde date,       
@FechaHasta date,      
@NroOficio varchar(20),      
@NroDocumento varchar(20),      
@IdLaboratorioUsuario int      
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
 oe.estatusSol,  
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
  --and (LTRIM(RTRIM(o.nroOficio)) LIKE '%'+ LTRIM(RTRIM(@NroOficio)) + '%')      
  and (@NroDocumento is null or @NroDocumento = '' or LTRIM(RTRIM(p.nroDocumento)) LIKE '%'+ LTRIM(RTRIM(@NroDocumento)) + '%')      
  --and ((LTRIM(RTRIM(mc.codificacion)) LIKE '%'+ LTRIM(RTRIM(@CodigoOrden)) + '%')      
  --or (LTRIM(RTRIM(o.codigoOrden)) LIKE '%'+ LTRIM(RTRIM(@CodigoOrden)) + '%'))      
  and omr.idLaboratorioDestino =@IdLaboratorioUsuario       
  AND o.fechaSolicitud between @FechaDesde AND convert(varchar(10),convert(datetime,@FechaHasta)+1,112)
  
  AND OE.estatusSol=1
  
         
 group by  o.idOrden, o.idEstablecimiento, e.nombre, e.codigoUnico, p.nroDocumento, 
 fechaSolicitud, o.fechaRegistro, o.idPaciente, o.codigoOrden, o.nroOficio, ldtd.glosa, ld.glosa, o.estatus,
 omr.estatusP,P.genero,fechaNacimiento,OM.fechaColeccion,estatusSol     
 order by fechaRegistro desc       
END      
ELSE      
BEGIN      
 select distinct o.idOrden, o.idEstablecimiento, e.nombre AS NombEstab, e.codigoUnico, p.nroDocumento,o.fechaSolicitud as fechaSolicitud,      
 o.fechaRegistro as fechaRegistro, o.idPaciente,o.codigoOrden AS CodOrden, o.nroOficio,      
 ldtd.glosa TipoDocumento, ld.glosa NombreGenero, o.estatus,omr.estatusP,P.genero,       
 p.fechaNacimiento as fechaNacimiento,OM.fechaColeccion,  
   
 /**SOTERO MODIFICACION STORE SOLICTA VERIFICADOR INGRESO NUEVO RESULTADO---24-10-2017*/  
 oe.estatusSol,  
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
  --and (LTRIM(RTRIM(o.nroOficio)) LIKE '%'+ LTRIM(RTRIM(@NroOficio)) + '%')      
  and (@NroDocumento is null or @NroDocumento = '' or LTRIM(RTRIM(p.nroDocumento)) LIKE '%'+ LTRIM(RTRIM(@NroDocumento)) + '%')      
  --and ((LTRIM(RTRIM(mc.codificacion)) LIKE '%'+ LTRIM(RTRIM(@CodigoOrden)) + '%')      
  --or (LTRIM(RTRIM(o.codigoOrden)) LIKE '%'+ LTRIM(RTRIM(@CodigoOrden)) + '%'))      
  and omr.idLaboratorioDestino =@IdLaboratorioUsuario       
  AND om.fechaColeccion between @FechaDesde AND convert(varchar(10),convert(datetime,@FechaHasta)+1,112) 
  
  AND OE.estatusSol=1
       
 group by  o.idOrden, o.idEstablecimiento, e.nombre, e.codigoUnico, p.nroDocumento, fechaSolicitud, o.fechaRegistro, o.idPaciente, 
 o.codigoOrden, o.nroOficio, ldtd.glosa, ld.glosa, o.estatus,omr.estatusP,P.genero,fechaNacimiento,OM.fechaColeccion,estatusSol     
 order by fechaRegistro desc       
END      


go

/*******************************************************************************    
Descripcion: Registra los resultados de la prueba ejecutada.    
Creado por: Terceros    
Fecha Creacion: 01/01/2017    
Modificacion: Se agegaron comentarios    
*******************************************************************************/    
ALTER PROCEDURE  [dbo].[pNLU_OrdenResultadoAnalitoResultado]    
@IdOrdenResultadoAnalito uniqueidentifier,    
@Resultado varchar(800),    
@IdUsuario int,     
@idExamenMetodo int,     
@Observacion varchar(1000),    
@CodigoOpcion varchar(10)    
AS    
BEGIN    
 declare @idOrdenExamen varchar(36)    
 declare @validado int    
 declare @estadoE int    
     
 select @idOrdenExamen=idOrdenExamen from OrdenResultadoAnalito where idOrdenResultadoAnalito = @IdOrdenResultadoAnalito    
 select @validado=validado,@estadoE=estatusE from OrdenExamen where idOrdenExamen = @idOrdenExamen    
     
 if @estadoE=7    
 begin    
  update OrdenExamen set estatusE=8,ingresado=1,fechaIngreso=GETDATE(),idUsuarioIngreso=@IdUsuario,idExamenMetodo = @idExamenMetodo where idOrdenExamen=@idOrdenExamen    
    
  Update OrdenResultadoAnalito     
  set resultado = @Resultado,observacion = @Observacion,idUsuarioRegistro = @IdUsuario,fechaRegistro = GETDATE(), codigoOpcion = @CodigoOpcion    
  where idOrdenResultadoAnalito = @IdOrdenResultadoAnalito    
 end    
    
 if @estadoE=8    
 begin    
  update OrdenExamen set fechaIngEdicion=GETDATE(),idUsuarioIngEdicion=@IdUsuario,idExamenMetodo = @idExamenMetodo where idOrdenExamen=@idOrdenExamen    
    
  Update OrdenResultadoAnalito     
  set resultado = @Resultado,observacion = @Observacion,idUsuarioEdicion = @IdUsuario,fechaEdicion = GETDATE(), codigoOpcion = @CodigoOpcion    
  where idOrdenResultadoAnalito = @IdOrdenResultadoAnalito    
 end    
     
 if @estadoE=9    
 begin    
  update OrdenExamen set validado=null,fechaValidado=null,idUsuarioValidado=null,conforme=null, motivoNoConforme=null,    
  fechaIngEdicion=GETDATE(),idUsuarioIngEdicion=@IdUsuario,idExamenMetodo = @idExamenMetodo     
  where idOrdenExamen=@idOrdenExamen    
      
  Update OrdenResultadoAnalito     
  set resultado = @Resultado,observacion = @Observacion,idUsuarioEdicion = @IdUsuario,fechaEdicion = GETDATE(), codigoOpcion = @CodigoOpcion    
  where idOrdenResultadoAnalito = @IdOrdenResultadoAnalito    
 end  
  if @estadoE = 11  
  begin  
  update OrdenExamen set fechaEdicion=GETDATE(),idUsuarioEdicion=@IdUsuario, estatusSol=0   
  where idOrdenExamen=@idOrdenExamen    
  ---Insertamos un nuevo registro a la tabla ordenresultadoanalito  
    
 declare @idAnalito varchar(36)     
 declare @idSecuen int  
 declare @orden int  
 declare @nuevSecuen int  
     
  select @idOrdenExamen = idOrdenExamen,@idAnalito= idAnalito, @idSecuen= MAX(idSecuen), @orden =orden   
  from OrdenResultadoAnalito    
  where idOrdenResultadoAnalito = @IdOrdenResultadoAnalito  
  group by idOrdenExamen,idAnalito,idSecuen,orden  
  
  set @nuevSecuen = @idSecuen + 1  
    
  insert into OrdenResultadoAnalito values(@IdOrdenResultadoAnalito, @idOrdenExamen,@idAnalito,@nuevSecuen,@orden,@CodigoOpcion,  
           @Resultado,@Observacion,1,GETDATE(),@IdUsuario,GETDATE(),@IdUsuario)  
    
  --update OrdenResultadoAnalito set estado = 0 where idOrdenResultadoAnalito = @IdOrdenResultadoAnalito and idSecuen = @idSecuen    
    
  end  
   
     
END

go
IF OBJECT_ID(N'pNLU_OrdenSolicitaIngresoResultados') IS NOT NULL 
    DROP PROCEDURE dbo.pNLU_OrdenSolicitaIngresoResultados ;
GO
/*******************************************************************************  
Descripcion: SOLICITA ORDEN PARA INGRESO DE RESULTADOS.  
Creado por: SOTERO BUSTAMANTE  
Fecha Creacion: 01/01/2017  
Modificacion: AUTORIZACION DE INGRESO DE RESULTADOS
*******************************************************************************/  
Create PROCEDURE  [dbo].[pNLU_OrdenSolicitaIngresoResultados]  
@IdOrden uniqueidentifier,  
@IdUsuario int, 
@estatusSol int ,
@observaSol varchar(200) = ''   
  
  
AS  
BEGIN  
 
 if @estatusSol=1  
 begin  
  update OrdenExamen set estatusSol = @estatusSol,fechaSol= GETDATE(), idUsuarioSol = @IdUsuario 
  where idOrden = @IdOrden 
 end  
  
  if @estatusSol=2  
 begin  
  update OrdenExamen set estatusSol = @estatusSol,fechaSol= GETDATE(), idUsuarioSol = @IdUsuario, observaSol = @observaSol 
  where idOrden = @IdOrden 
 end 
 
   
END

GO
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
GO

/*******************************************************************************    
Descripcion: Registra los recepcion de la muestra en Labortorio     
             Estado = 5    
Creado por: TERCEROS
Fecha Creacion: 01/01/2017    
Modificacion: Se agegaron comentarios    
*******************************************************************************/    
ALTER PROCEDURE  [dbo].[pNLU_OrdenMuestraRecepcionLAB]    
@idOrdenMuestraRecepcion uniqueidentifier,    
@idUsuario int,  
@secuenObtencion int   
AS
/*MODIFICADO POR SOTERO 30/10/2017 ACTUALIZAR ORDEN DE SECUENCIA*/
DECLARE @LAB INT 
SET @LAB = (SELECT idLaboratorioDestino FROM OrdenMuestraRecepcion WHERE idOrdenMuestraRecepcion = @idOrdenMuestraRecepcion)
		
IF exists (select secuenObtencion From OrdenMuestraRecepcion WHERE idLaboratorioDestino = @LAB and secuenObtencion=@secuenObtencion)
	BEGIN 
		RAISERROR ('El registro ya existe', 
		16, -- Severidad 
		1   -- Estado
		)
	END
ELSE     
	BEGIN  
		UPDATE OrdenMuestraRecepcion     
		SET fechaRecepcionP = GETDATE(),horaRecepcionP = GETDATE(),    
		idUsuarioRecepcionP=@idUsuario,estatusP=5,conformeP=null,secuenObtencion=@secuenObtencion    
		WHERE idOrdenMuestraRecepcion = @idOrdenMuestraRecepcion    
	END 

Go
/*******************************************************************************  
Descripcion: Registra la información del resultado en la tabla OrdenResultadoAnalito  
Creado por: Terceros  
Fecha Creacion: 01/01/2017  
Modificacion: Se agegaron comentarios  
*******************************************************************************/  
ALTER PROCEDURE  [dbo].[pNLI_OrdenResultadoAnalito]  
@IdOrden uniqueidentifier  
AS  
BEGIN  
 INSERT INTO OrdenResultadoAnalito (idOrdenExamen,idAnalito,orden,idSecuen)   
 SELECT distinct oe.idOrdenExamen, ea.idAnalito,ea.ordenAnalito,1 
 FROM ExamenAnalito ea  
 INNER JOIN Examen e ON e.idExamen = ea.idExamen  
 INNER JOIN OrdenExamen oe ON oe.idExamen = e.idExamen and oe.idExamen=ea.idExamen  
 INNER JOIN OrdenMaterial omat ON omat.idOrdenExamen = oe.idOrdenExamen and oe.idOrden=omat.idOrden  
 INNER JOIN OrdenMuestraRecepcion omtre ON omtre.idOrdenMaterial = omat.idOrdenMaterial and omtre.idOrden=omat.idOrden and omtre.idOrden=oe.idOrden  
 WHERE ea.estado=1 and e.estado=1 and oe.estado = 1  and omtre.estado = 1 and omat.estado=1 and oe.idOrden = @IdOrden    
 AND omtre.estatus = 3 and oe.idOrdenExamen not in   
 (select x1.idOrdenExamen from OrdenResultadoAnalito x1 inner join OrdenExamen x2 on x2.idOrdenExamen=x1.idOrdenExamen 
  where x2.idOrden=@IdOrden)  
END	

Go
IF OBJECT_ID(N'pNLS_DatosPacienteByNroDocumento') IS NOT NULL 
    DROP PROCEDURE dbo.pNLS_DatosPacienteByNroDocumento ;
GO
/*******************************************************************************  
Descripcion: Obtiene informaci�n de las ordenes y muestras con resutlado de un paciente.
Creado por: Juan Muga  
Fecha Creacion: 01/10/2017  
Modificacion: Se agegaron comentarios 
exec  pNLS_DatosPacienteByNroDocumento '43699165'
*******************************************************************************/  
CREATE PROCEDURE [dbo].[pNLS_DatosPacienteByNroDocumento]  
@nroDocumento varchar(12)
AS  
  
BEGIN  
select distinct 
		IdOrden = o.idOrden,
		FechaSolicitud = o.fechaSolicitud,
		FechaObtencion = om.fechaColeccion,
		Orden = o.codigoOrden,
		EstablecimientoOrigen = e.codigoUnico+' - '+e.nombre,      
		ID_Muestra = mc.codificacion,
		Enfermedad = enf.nombre ,
		Examen = ex.nombre,
		Componente = (Select Nombre from Analito where idAnalito = ora.idAnalito),   
		Resultado = ora.Resultado, 
		oe.ingresado, 
		oe.validado,
		oe.EstatusE,
		EstatusResultado = ldx2.Glosa
from Orden o (nolock)      
inner join OrdenExamen oe (nolock) on oe.idOrden = o.idOrden       
inner join Examen ex (nolock) on ex.idExamen = oe.idExamen       
inner join Enfermedad enf (nolock) on enf.idEnfermedad = oe.idEnfermedad       
left join ExamenMetodo em (nolock) on em.idExamenMetodo = oe.idExamenMetodo       
left  join OrdenResultadoAnalito ora (nolock) on ora.idOrdenExamen = oe.idOrdenExamen      
inner join Establecimiento e (nolock) on e.idEstablecimiento = o.idEstablecimiento and e.tipo = 1      
inner join OrdenMuestra om (nolock) on om.idOrden = o.idOrden       
inner join MuestraCodificacion mc (nolock) on mc.idMuestraCod = om.idMuestraCod       
inner join OrdenMaterial oma (nolock) on oma.idOrdenMuestra = om.idOrdenMuestra and oma.idOrden=o.idOrden       
and oma.idOrden=om.idOrden and oma.idOrden=oe.idOrden and oma.idOrdenExamen=oe.idOrdenExamen      
left join OrdenMuestraRecepcion omr (nolock) on omr.idOrdenMaterial = oma.idOrdenMaterial       
and omr.idOrden=o.idOrden and om.idOrden=omr.idOrden and oma.idOrden=omr.idOrden and omr.idOrden=oe.idOrden 
inner join Paciente p (nolock) on p.idPaciente = o.idPaciente            
left join ListaDetalle ldx2 (nolock) on oe.estatusE = ldx2.idDetalleLista and ldx2.idLista = 16       
where LTRIM(RTRIM(p.nroDocumento)) = @nroDocumento 

End