
/*******************************************************************************  
Descripcion: SOLICITA ORDEN PARA INGRESO DE RESULTADOS.  
Creado por: SOTERO BUSTAMANTE  
Fecha Creacion: 01/01/2017  
Modificacion: AUTORIZACION DE INGRESO DE RESULTADOS
*******************************************************************************/  
ALTER PROCEDURE  [dbo].[pNLU_OrdenSolicitaIngresoResultados]  
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