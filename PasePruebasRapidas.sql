---------------------
IF NOT EXISTS(SELECT 1 FROM sys.columns 
          WHERE Name = N'iPruebaRapida'
          AND Object_ID = Object_ID(N'dbo.Examen'))
Begin          
	Alter Table Examen add iPruebaRapida Int default 0;
	Update Examen set iPruebaRapida = 0;
	Update Examen set iPruebaRapida = 1 where idExamen in ( 'D0095440-BE21-4F4D-A4E6-10E64AB6306A',
															'1333B231-A3F5-4D60-A39A-47965656EA9B',
															'AE289C0A-C3C7-4569-B023-6DA158365DD1');
End														
Go						
IF OBJECT_ID(N'pNLP_ProcesoPruebaRapida') IS NOT NULL 
    DROP PROCEDURE dbo.pNLP_ProcesoPruebaRapida ;
GO								
/*******************************************************************************  
Descripcion: Obtiene informacion e los examene de una Orden
			 para generar los estados a cada bandeja hasta que llegue al ingreso de resultados.  
Creado por: Juan Muga  
Fecha Creacion: 04/11/2017  
Modificacioó: 
*******************************************************************************/  
CREATE PROCEDURE [dbo].[pNLP_ProcesoPruebaRapida]   
@idOrden  uniqueidentifier,    
@idUsuario Int
AS  
BEGIN  
--Recepcion de la muestra 
UPDATE OrdenMuestraRecepcion   
 SET conformeR = 1, fechaRecepcion = convert(date,getdate()),   
 horaRecepcion = convert(time,getdate()),EstatusR=3,EstatusP=4, estatus = 3  
 WHERE idOrdenMuestraRecepcion in (select omr.idordenmuestrarecepcion
									from Examen e 
									inner join ordenexamen oe on oe.idexamen = e.idexamen
									inner join ordenmaterial om on om.idOrdenExamen = oe.idOrdenExamen
									inner join ordenmuestrarecepcion omr on om.IdOrden = omr.IdOrden
									inner join orden o on o.idorden= omr.idorden
									where e.iPruebaRapida = 1
									and o.IdOrden = @idOrden)
--Actualiza estado orden  
  Exec pNLS_ObtenerCantidadMuetrasPorRecepcionar @idOrden
--Registro de Analitos									
 INSERT INTO OrdenResultadoAnalito (idOrdenExamen,idAnalito,orden,idSecuen)       
 SELECT distinct oe.idOrdenExamen, ea.idAnalito,ea.ordenAnalito,1     
 FROM ExamenAnalito ea      
 INNER JOIN Examen e ON e.idExamen = ea.idExamen      
 INNER JOIN OrdenExamen oe ON oe.idExamen = e.idExamen and oe.idExamen=ea.idExamen      
 INNER JOIN OrdenMaterial omat ON omat.idOrdenExamen = oe.idOrdenExamen and oe.idOrden=omat.idOrden      
 INNER JOIN OrdenMuestraRecepcion omtre ON omtre.idOrdenMaterial = omat.idOrdenMaterial and omtre.idOrden=omat.idOrden and omtre.idOrden=oe.idOrden 
 WHERE ea.estado=1 and e.estado=1 and oe.estado = 1  and omtre.estado = 1 and omat.estado=1 and oe.idOrden =@idOrden       
 AND omtre.estatus = 3 and 
 Not Exists (select 's' from OrdenResultadoAnalito x1 inner join OrdenExamen x2 on x2.idOrdenExamen=x1.idOrdenExamen     
			 where x2.idOrden=@idOrden) 
 and e.iPruebaRapida = 1
 --Recepcionar en Laboratorio 
 UPDATE OrdenMuestraRecepcion       
 SET fechaRecepcionP = convert(date,getdate()),horaRecepcionP = convert(time,getdate()),      
 idUsuarioRecepcionP=@idUsuario,estatusP=5,conformeP=null,secuenObtencion=0
 WHERE idOrdenMuestraRecepcion in (select omr.idordenmuestrarecepcion
									from Examen e 
									inner join ordenexamen oe on oe.idexamen = e.idexamen
									inner join ordenmaterial om on om.idOrdenExamen = oe.idOrdenExamen
									inner join ordenmuestrarecepcion omr on om.IdOrden = omr.IdOrden
									inner join orden o on o.idorden= omr.idorden
									where e.iPruebaRapida = 1
									and o.IdOrden = @idOrden)
--Registrar Control de Calidad en Labortorio
 UPDATE OrdenMuestraRecepcion   
 SET conformeP = 1,fechaValidarMuestra = convert(date,getdate()),idUsuarioValidarMuestra=@idUsuario,estatusP=6  
 WHERE idOrdenMuestraRecepcion in (select omr.idordenmuestrarecepcion
									from Examen e 
									inner join ordenexamen oe on oe.idexamen = e.idexamen
									inner join ordenmaterial om on om.idOrdenExamen = oe.idOrdenExamen
									inner join ordenmuestrarecepcion omr on om.IdOrden = omr.IdOrden
									inner join orden o on o.idorden= omr.idorden
									where e.iPruebaRapida = 1
									and o.IdOrden = @idOrden)	
End		

GO   
--
IF OBJECT_ID(N'pNLS_ExamenByNombreAndLaboratorio') IS NOT NULL 
    DROP PROCEDURE dbo.pNLS_ExamenByNombreAndLaboratorio ;
GO	
--
/*******************************************************************************        
Descripcion: Obtiene información de los examenes por Nombre(LOINC,CPT,Nombre) y genero.        
Creado por: Terceros        
Fecha Creacion: 01/01/2017        
Modificacion: Se agegaron comentarios.
-- JMuga - 04/11/2017 - Se agregó el campo iPruebaRapida  
*******************************************************************************/        
--exec pNLS_ExamenByNombreAndLaboratorio 'elis',1005635,1     
CREATE PROCEDURE [dbo].[pNLS_ExamenByNombreAndLaboratorio]        
@nombre varchar(50),        
@idLaboratorio int,        
@genero int        
AS        
BEGIN        
 SET NOCOUNT ON        
 --        
 DECLARE @Tmp_examen TABLE(  idExamen uniqueidentifier        
       ,LOINC varchar(100)        
       ,CPT varchar(100)        
       ,NOMBRE varchar(300)        
       ,DESCRIPCION varchar(300)
       ,PRUEBARAPIDA int)  
 --        
Insert INTO @Tmp_examen        
 SELECT distinct e.idExamen,        
   isnull(CAST(e.LOINC AS VARCHAR(8)),'') LOINC,        
   isnull(CAST(e.CPT AS VARCHAR(8)),'') CPT,        
   e.nombre,        
   e.descripcion,
   e.ipruebarapida 
 FROM Examen e (NOLOCK)        
 JOIN EnfermedadExamen ee ON e.idExamen = ee.idExamen        
 WHERE  e.estado = 1        
 and LTRIM(RTRIM(e.descripcion)) LIKE '%'+LTRIM(RTRIM(@nombre))+'%'       
 and ee.idEnfermedad = @idLaboratorio        
 AND (e.idGenero =  1  OR e.idGenero = 3)        
 --        
 SELECT  idExamen     
,     'LOINC: '+isnull(CAST(LTRIM(RTRIM(LOINC)) AS VARCHAR(10)),'') +           
 ' - CPT: ' + CAST(LTRIM(RTRIM(CPT)) AS VARCHAR(10))+          
 ' - '+ substring(LTRIM(RTRIM(Descripcion)),0,100) as 'nombre',PruebaRapida    
FROM @Tmp_examen       
END     				