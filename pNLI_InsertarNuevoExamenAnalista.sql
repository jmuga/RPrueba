USE [NetLab2-Ogis]
GO
/****** Object:  StoredProcedure [dbo].[pNLI_InsertarNuevoExamenVerificador]    Script Date: 11/19/2017 13:00:48 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
--877d88eb-8d3f-4e21-bcb7-1afa7d64ae3c|991|1005635|8b4a5e51-6cea-425f-8789-b2fe7bf7abe1|1|NaN|NaN|94|0|1|1|1  
ALTER PROCEDURE [dbo].[pNLI_InsertarNuevoExamenAnalista]  
 @Lista varchar(max),  
 @idEstablecimiento int,  
 @idUsuario int  
AS  
BEGIN  
SET NOCOUNT ON      
  
 BEGIN TRANSACTION  
 Declare @Tabla table (id int identity(1,1),valor varchar(50))  
 insert @Tabla Select * From fnSplitString(@Lista,'|')  
   
    
 Declare @idOrden uniqueidentifier  
 Declare @idLaboratorio int  
 Declare @idEnfermedad int  
 Declare @idExamen uniqueidentifier  
 Declare @idTipoMuestra int  
 Declare @fechaColeccion DATETIME
 Declare @horaColeccion TIME(7)  
 Declare @idMaterial int   
 Declare @noPrecisaVolumen int    
 Declare @volumen decimal(18,2)  
 Declare @cantidad int  
 Declare @tipoMaterial int  
   
 DECLARE @newIdOrdenExamen uniqueidentifier    
 DECLARE @newIdOrdenMuestra uniqueidentifier       
 DECLARE @newIdOrdenMaterial uniqueidentifier  
 DECLARE @newIdOrdenMuestraRecepcion uniqueidentifier       
 DECLARE @newIdOrdenResultadoAnalito uniqueidentifier      
 --DECLARE @tablaAnalito table (idExamen varchar(50),idAnalito varchar(50),ordenAnalito int)  
 DECLARE @idOrdenExAnt varchar (50)  
    
  set @idOrden   = (select valor from @Tabla where id = 1)  
  set @idLaboratorio  = (select valor from @Tabla where id = 2)  
  set @idEnfermedad  = (select valor from @Tabla where id = 3)  
  set @idExamen   = (select valor from @Tabla where id = 4)  
  set @idTipoMuestra  = (select valor from @Tabla where id = 5)  
  --set @fechaColeccion  = (select valor from @Tabla where id = 6)  
  --set @horaColeccion  = (select valor from @Tabla where id = 7)  
  set @idMaterial   = (select valor from @Tabla where id = 8)  
  set @noPrecisaVolumen =   (select valor from @Tabla where id = 9)  
  set @volumen   =   (select valor from @Tabla where id = 10)  
  set @cantidad   =   (select valor from @Tabla where id = 11)  
  set @tipoMaterial  =   (select valor from @Tabla where id = 12)  
    
     
  if @idEstablecimiento <> @idLaboratorio  
    
  BEGIN  
    
  /*ACTUALZAMOS TABLA ORDEN**/  
  UPDATE Orden  
  SET tipoO = 1  
  WHERE idOrden = @idOrden    
    
  /*INSERTAMOS TABLA ORDENEXAMEN**/  
  SET @newIdOrdenExamen = NEWID()   
  INSERT INTO OrdenExamen (idOrdenExamen,idOrden,idEnfermedad,idTipoMuestra,idExamen,estatusE,estatus,estado,  
         fechaRegistro,idUsuarioRegistro,fechaEdicion,idUsuarioEdicion)  
           
      SELECT  TOP 1       @newIdOrdenExamen, @idOrden, @idEnfermedad, @idTipoMuestra, @idExamen, 7,  1,  1,   
         fechaRegistro, idUsuarioRegistro, GETDATE(),@idUsuario FROM OrdenExamen WHERE idOrden = @idOrden and estatusE = 7  
         --and fechaIngreso = (select MIN(fechaIngreso)from OrdenExamen where idOrden = @idOrden)  
           
  /*INSERTAMOS TABLA ORDENMUESTRA**/  
  SET @newIdOrdenMuestra = NEWID()  
  INSERT INTO OrdenMuestra (idOrdenMuestra,idOrden,idTipoMuestra,idProyecto,idMuestraCod,fechaColeccion,horaColeccion,   
          numero,seriado,estatus,estado,fechaRegistro,idUsuarioRegistro,fechaEdicion,idUsuarioEdicion)  
            
         SELECT TOP 1  @newIdOrdenMuestra,@idOrden,@idTipoMuestra,idProyecto,idMuestraCod,fechaColeccion,horaColeccion,numero,  
         seriado,1,1,fechaRegistro,idUsuarioRegistro,GETDATE(),@idUsuario from OrdenMuestra WHERE idOrden = @idOrden 
         --and fechaColeccion = (select MIN(fechaColeccion)from OrdenMuestra where idOrden = @idOrden)   
    
  /*INSERTAMOS OrdenExamenOrdenMuestra*/  
  INSERT INTO OrdenExamenOrdenMuestra (idOrdenExamen, idOrdenMuestra, estatus, estado,fechaRegistro, idUsuarioRegistro)  
      VALUES      (@newIdOrdenExamen,@newIdOrdenMuestra,1,1,GETDATE(),@idUsuario)   
    
    
  /*INSERTAMOS TABLA ORDENMATERIAL**/  
  set @newIdOrdenMaterial = NEWID()  
  INSERT INTO OrdenMaterial (idOrdenMaterial, idOrden, idOrdenMuestra, idOrdenExamen, idMaterial, idLaboratorio, Tipo, fechaEnvio, horaEnvio, cantidad,   
         volumenMuestraColectada, noPrecisaVolumen, estatus, estado, fechaRegistro, idUsuarioRegistro, fechaEdicion, idUsuarioEdicion)  
        
      SELECT TOP 1   @newIdOrdenMaterial,@idOrden,@newIdOrdenMuestra,@newIdOrdenExamen,idMaterial,@idLaboratorio,tipo,GETDATE(),convert(varchar(10), GETDATE(), 108),  
           @cantidad,@volumen,@noPrecisaVolumen,1,1,fechaRegistro,idUsuarioRegistro,GETDATE(),@idUsuario FROM OrdenMaterial WHERE idOrden=@idOrden  
           --and fechaEnvio = (select MIN(fechaEnvio) from OrdenMaterial where idOrden = @idOrden)  
    
  /*INSERTAMOS TABLA ORDENMUESTRARECEPCION**/  
  SET @newIdOrdenMuestraRecepcion = NEWID()  
  INSERT INTO OrdenMuestraRecepcion (idOrdenMuestraRecepcion, idOrden, idOrdenMaterial, fechaRecepcion, horaRecepcion, idLaboratorioOrigen, idLaboratorioDestino, fechaEnvio,   
           horaEnvio, estatusR, estatus, estado,fechaRegistro, idUsuarioRegistro,idOrdenMuestraRecepcionAnterior)  
        
      SELECT TOP 1    @newIdOrdenMuestraRecepcion,@idOrden,@newIdOrdenMaterial,GETDATE(),convert(varchar(10), GETDATE(), 108),@idEstablecimiento,@idLaboratorio,GETDATE(),  
             convert(varchar(10), GETDATE(), 108),2,1,1,GETDATE(),@idUsuario,idOrdenMuestraRecepcion FROM OrdenMuestraRecepcion where idOrden = @idOrden   
             and fechaRecepcion = (select MIN(fechaRecepcion) from OrdenMuestraRecepcion where idOrden = @idOrden)  
    
  /*InsertOrdenResultadoAnalito*/  
    
  INSERT INTO OrdenResultadoAnalito(idOrdenResultadoAnalito, idOrdenExamen,idSecuen,idUsuarioRegistro,idAnalito,orden)  
      SELECT               NEWID(),@newIdOrdenExamen,1,@idUsuario,idAnalito,ordenAnalito from ExamenAnalito where idExamen = @idExamen  
  
    
      
 END  
    
    
    ELSE  
      
    BEGIN  
    
  /*ACTUALZAMOS TABLA ORDEN**/  
  UPDATE Orden  
  SET tipoO = 1  
  WHERE idOrden = @idOrden    
    
  /*INSERTAMOS TABLA ORDENEXAMEN**/  
  SET @newIdOrdenExamen = NEWID()   
  INSERT INTO OrdenExamen (idOrdenExamen,idOrden,idEnfermedad,idTipoMuestra,idExamen,estatusE,estatus,estado,  
         fechaRegistro,idUsuarioRegistro,fechaEdicion,idUsuarioEdicion)  
           
      SELECT  TOP 1        @newIdOrdenExamen, @idOrden, @idEnfermedad, @idTipoMuestra, @idExamen, 7,  1,  1,   
         fechaRegistro, idUsuarioRegistro, GETDATE(),@idUsuario FROM OrdenExamen WHERE idOrden = @idOrden and estatusE = 7  
         --and fechaIngreso = (select MIN(fechaIngreso)from OrdenExamen where idOrden = @idOrden)   
    
  /*INSERTAMOS TABLA ORDENMUESTRA**/  
  SET @newIdOrdenMuestra = NEWID()  
  INSERT INTO OrdenMuestra (idOrdenMuestra,idOrden,idTipoMuestra,idProyecto,idMuestraCod,fechaColeccion,horaColeccion,   
          numero,seriado,estatus,estado,fechaRegistro,idUsuarioRegistro,fechaEdicion,idUsuarioEdicion)  
            
         SELECT TOP 1 @newIdOrdenMuestra,@idOrden,@idTipoMuestra,idProyecto,idMuestraCod,fechaColeccion,horaColeccion,numero,  
         seriado,1,1,fechaRegistro,idUsuarioRegistro,GETDATE(),@idUsuario from OrdenMuestra WHERE idOrden = @idOrden 
         --and  fechaColeccion = (select MIN(fechaColeccion)from OrdenMuestra where idOrden = @idOrden)    
    
  /*INSERTAMOS OrdenExamenOrdenMuestra*/  
  INSERT INTO OrdenExamenOrdenMuestra (idOrdenExamen, idOrdenMuestra, estatus, estado,fechaRegistro, idUsuarioRegistro)  
      VALUES      (@newIdOrdenExamen,@newIdOrdenMuestra,1,1,GETDATE(),@idUsuario)   
    
    
  /*INSERTAMOS TABLA ORDENMATERIAL**/  
  set @newIdOrdenMaterial = NEWID()  
  INSERT INTO OrdenMaterial (idOrdenMaterial, idOrden, idOrdenMuestra, idOrdenExamen, idMaterial, idLaboratorio, Tipo, fechaEnvio, horaEnvio, cantidad,   
         volumenMuestraColectada, noPrecisaVolumen, estatus, estado, fechaRegistro, idUsuarioRegistro, fechaEdicion, idUsuarioEdicion)  
        
      SELECT  TOP 1         @newIdOrdenMaterial,@idOrden,@newIdOrdenMuestra,@newIdOrdenExamen,idMaterial,@idLaboratorio,tipo,GETDATE(),convert(varchar(10), GETDATE(), 108),  
           @cantidad,@volumen,@noPrecisaVolumen,1,1,fechaRegistro,idUsuarioRegistro,GETDATE(),@idUsuario FROM OrdenMaterial WHERE idOrden=@idOrden  
           --and fechaEnvio = (select MIN(fechaEnvio) from OrdenMaterial where idOrden = @idOrden)  
             
  /*INSERTAMOS TABLA ORDENMUESTRARECEPCION**/  
  SET @newIdOrdenMuestraRecepcion = NEWID()  
  INSERT INTO OrdenMuestraRecepcion (idOrdenMuestraRecepcion, idOrden, idOrdenMaterial,conformeR, fechaRecepcion, horaRecepcion, idLaboratorioOrigen, idLaboratorioDestino, fechaEnvio,   
           horaEnvio,fechaRecepcionP,horaRecepcionP,idUsuarioRecepcionP,conformeP,fechaValidarMuestra,idUsuarioValidarMuestra, estatusR,estatusP, estatus, estado,fechaRegistro, idUsuarioRegistro,idOrdenMuestraRecepcionAnterior)  
        
      SELECT TOP 1     @newIdOrdenMuestraRecepcion,@idOrden,@newIdOrdenMaterial,1,GETDATE(),convert(varchar(10), GETDATE(), 108),@idEstablecimiento,@idLaboratorio,GETDATE(),  
             convert(varchar(10), GETDATE(), 108),GETDATE(),convert(varchar(10), GETDATE(), 108),@idUsuario,1,getdate(),@idUsuario,3,6,3,1,GETDATE(),@idUsuario,idOrdenMuestraRecepcion FROM OrdenMuestraRecepcion where idOrden = @idOrden and estatusP=6  
             --and fechaRecepcion = (select MIN(fechaRecepcion) from OrdenMuestraRecepcion where idOrden = @idOrden)  
    
  /*InsertOrdenResultadoAnalito*/  
      
    
  INSERT INTO OrdenResultadoAnalito(idOrdenResultadoAnalito, idOrdenExamen,idSecuen,idUsuarioRegistro,idAnalito,orden)  
      SELECT            NEWID(),@newIdOrdenExamen,1,@idUsuario,idAnalito,ordenAnalito from ExamenAnalito where idExamen = @idExamen  
  
    
    
    
    
      
 END  
 Commit Transaction     
               
   
   
END 