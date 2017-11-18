/*******************************************************************************
Descripcion: Obtiene informacion de TODOS LOS establecimientoS para el ROM en generador de Muestras
Creado por: SOTERO BUSTAMANTE
Fecha Creacion: 31/10/2017
Modificacion: Se agegaron comentarios
*******************************************************************************/

CREATE PROCEDURE pNLS_GetAllEstablecimiento

AS

SELECT distinct idEstablecimiento,codigounico,nombre
		FROM Establecimiento
		where estado = 1