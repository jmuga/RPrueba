create procedure pNLS_GetNumeroExamenByMuestra

	@idPaciente uniqueidentifier,
	@idEnfermedad int,
	@idTipoMuestra int,
	@idExamen uniqueidentifier,
	@nroMuestra int OUTPUT
 
 
 as

SET @nroMuestra = (select COUNT(idPaciente) from Orden o
inner join OrdenExamen oe
on o.idOrden = oe.idOrden
where o.idPaciente= @idPaciente and oe.idEnfermedad = @idEnfermedad 
and oe.idTipoMuestra = @idTipoMuestra and oe.idExamen= @idExamen)


