/*******************************************************************************  
Descripcion: Obtener informacion de los examenes o pruebas por codigo de orden  
Creado por: Terceros  
Fecha Creacion: 01/01/2017  
Modificacion: Se agegaron comentarios  
*******************************************************************************/  
alter PROCEDURE [dbo].[pNLS_OrdenExamenByOrden]  
@IdOrden uniqueidentifier  
  
AS  
BEGIN  
  
SELECT ex.idExamen as idExamen, ex.nombre as nombreExamen,   
  ef.idEnfermedad as idEnfermedad, ef.nombre as nombreEnfermedad,t.nombre NombreTM, * FROM OrdenExamen oe  
INNER JOIN Examen ex ON oe.idExamen = ex.idExamen  
INNER JOIN Enfermedad ef ON oe.idEnfermedad = ef.idEnfermedad 
--SOTERO BUSTAMANTE PARA NOMBRE DE TIPO DE MUESTRA
inner join TipoMuestra t
on oe.idTipoMuestra= t.idTipoMuestra 
WHERE oe.idOrden = @IdOrden AND oe.estado = 1 AND oe.estatus = 1  
  
END
