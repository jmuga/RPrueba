sp_helptext pNLS_UbigeoById


/*******************************************************************************  
Descripcion: Obtiene el ubigeo(departamento-Provincia-Distrito) por Id,  
Creado por: Terceros  
Fecha Creacion: 01/01/2017  
Modificacion: Se agegaron comentarios  
*******************************************************************************/  
ALTER PROCEDURE [dbo].[pNLS_UbigeoById]  
@idUbigeo varchar(6),  
@departamento varchar(500) OUTPUT,  
@provincia varchar(500) OUTPUT,  
@distrito varchar(500) OUTPUT  
AS  
BEGIN  
  
SET NOCOUNT ON  
  
SELECT    
 @departamento =   
 (SELECT descripcion FROM UbigeoPaciente where idUbigeo = SUBSTRING(@idUbigeo,1,2)+'0000' ),   
 @provincia =  
 (SELECT descripcion FROM UbigeoPaciente where idUbigeo = SUBSTRING(@idUbigeo,1,4)+'00' ),  
 @distrito = descripcion   
FROM UbigeoPaciente u  
WHERE  
 u.idUbigeo = @idUbigeo  
END  

