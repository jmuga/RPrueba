/*******************************************************************************  
Descripcion: Registra información de Analitos y sus opciones.  
Creado por: Terceros  
Fecha Creacion: 01/01/2017  
Modificacion: Se agegaron comentarios  
*******************************************************************************/  
ALTER PROCEDURE [dbo].[pNLI_AnalitoOpcion]  
@idAnalito uniqueidentifier,  
@glosa varchar(500),  
@orden varchar(3),  
@idUsuarioRegistro int,
@idopcionParent varchar(50)  
AS  
BEGIN  
SET NOCOUNT ON  
 IF rtrim(ltrim(@glosa))!='' and LEN(rtrim(ltrim(@glosa)))>0  
 BEGIN  
  IF NOT EXISTS(SELECT 1 FROM AnalitoOpcionResultado WHERE idAnalito=@idAnalito AND glosa=rtrim(ltrim(@glosa)))  
  BEGIN  
   INSERT INTO AnalitoOpcionResultado  
   (idAnalito,idOpcionParent,glosa,ordenOpcR,idUsuarioRegistro)  
   VALUES  
   (@idAnalito,@idopcionParent,UPPER(rtrim(ltrim(@glosa))),@orden,@idUsuarioRegistro)  
  END  
 END  
END  