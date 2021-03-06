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