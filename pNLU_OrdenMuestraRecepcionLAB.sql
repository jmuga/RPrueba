/*******************************************************************************    
Descripcion: Registra los recepcion de la muestra en Labortorio     
             Estado = 5    
Creado por: Terceros    
Fecha Creacion: 01/01/2017    
Modificacion: Se agegaron comentarios    
*******************************************************************************/    
ALTER PROCEDURE  [dbo].[pNLU_OrdenMuestraRecepcionLAB]    
@idOrdenMuestraRecepcion uniqueidentifier,    
@idUsuario int,  
@secuenObtencion int   
AS

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