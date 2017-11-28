--  
/*******************************************************************************          
Descripcion: Obtiene información de los examenes por Nombre(LOINC,CPT,Nombre) y genero.          
Creado por: Terceros          
Fecha Creacion: 01/01/2017          
Modificacion: Se agegaron comentarios.    
*******************************************************************************/          
--exec pNLS_ExamenByNombreAndLaboratorioRecepcion 'elis',996,1       
Create PROCEDURE [dbo].[pNLS_ExamenByNombreAndLaboratorioRecepcion]          
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
 INNER JOIN examenestablecimiento ee ON e.idExamen = ee.idExamen          
 WHERE  e.estado = 1          
 and LTRIM(RTRIM(e.descripcion)) LIKE '%'+LTRIM(RTRIM(@nombre))+'%'         
 and ee.idEstablecimiento = @idLaboratorio
 AND (e.idGenero =  1  OR e.idGenero = 3)          
 --          
 SELECT  idExamen ,Descripcion as 'nombre',PruebaRapida  FROM @Tmp_examen         
END         
Go
/*******************************************************************************    
Descripcion: Metodo para obtener informacion del detalle de las ordenes y sus muestras  
             por establecimiento    
Creado por: Juan Muga    
Fecha Creacion: 01/01/2017    
Modificacion: Se agegaron comentarios    
*******************************************************************************/    
ALTER PROCEDURE [dbo].[pNLS_DetalleOrdenRecepcion]  
 @IdLaboratorioUsuario int    
AS    
BEGIN    
--Declare @IdLaboratorioUsuario int   
--set @IdLaboratorioUsuario = 991 
SELECT * FROM       
 (   
select distinct    
  IdOrden = o.idOrden,    
  FechaSolicitud = o.fechaSolicitud,    
  FechaObtencion = om.fechaColeccion,  
  Hora = om.HoraColeccion,    
  CodigoOrden = o.codigoOrden,    
  EstablecimientoOrigen = e.nombre,          
  CodigoMuestra = mc.codificacion,    
  Enfermedad = enf.nombre ,    
  Examen = ex.nombre,  
  TipoMuestra = tm.Nombre,  
  EstablecimientoDestino = (select top 1 e.Nombre as pertenceLab from OrdenMuestraRecepcion omrp (nolock) 
							inner join Establecimiento e on omrp.idLaboratorioDestino = e.idestablecimiento     
							 where omrp.idOrden = o.idOrden and omrp.estatus in (1,2)         
							 and omrp.idLaboratorioDestino = @IdLaboratorioUsuario and omrp.estado = 1),  
  (select top 1 1 as pertenceLab from OrdenMuestraRecepcion omrp (nolock)      
 where omrp.idOrden = o.idOrden and omrp.estatus in (1,2)         
 and omrp.idLaboratorioDestino = @IdLaboratorioUsuario and omrp.estado = 1) as EXISTE_PENDIENTE,      
 (select top 1 1 as pertenceLab from OrdenMuestraRecepcion omrp  (nolock)      
 where omrp.idOrden = o.idOrden and omrp.estatus in (3,5)         
 and omrp.idLaboratorioDestino = @IdLaboratorioUsuario and omrp.estado = 1) as EXISTE_RECIBIDO,  
 (select top 1 1 as pertenceLab from  OrdenMuestraRecepcion omrp  (nolock)      
 inner join      OrdenMuestraRecepcionRechazo omrR  (nolock) on omrp.idordenmuestrarecepcion = omrR.idordenmuestrarecepcion  
 where omrp.idOrden = o.idOrden and omrp.idLaboratorioDestino = @IdLaboratorioUsuario) as EXISTE_RECHAZO,  
 omr.estatus,omr.conformeR,omr.idLaboratorioDestino,omr.fecharecepcion,omr.horarecepcion,mc.idMuestraCod, 
 Tipo = (Case oma.tipo When 1 Then 'Muestra Primaria' else 'Alícuota' end),omr.idOrdenMuestraRecepcion
from Orden o (nolock)          
inner join OrdenExamen oe (nolock) on oe.idOrden = o.idOrden           
inner join Examen ex (nolock) on ex.idExamen = oe.idExamen           
inner join Enfermedad enf (nolock) on enf.idEnfermedad = oe.idEnfermedad           
left join ExamenMetodo em (nolock) on em.idExamenMetodo = oe.idExamenMetodo           
left  join OrdenResultadoAnalito ora (nolock) on ora.idOrdenExamen = oe.idOrdenExamen          
inner join Establecimiento e (nolock) on e.idEstablecimiento = o.idEstablecimiento and e.tipo = 1          
inner join OrdenMuestra om (nolock) on om.idOrden = o.idOrden           
inner join TipoMuestra tm (nolock) on om.idTipoMuestra= tm.idTipoMuestra  
inner join MuestraCodificacion mc (nolock) on mc.idMuestraCod = om.idMuestraCod           
inner join OrdenMaterial oma (nolock) on oma.idOrdenMuestra = om.idOrdenMuestra and oma.idOrden=o.idOrden           
and oma.idOrden=om.idOrden and oma.idOrden=oe.idOrden and oma.idOrdenExamen=oe.idOrdenExamen          
left join OrdenMuestraRecepcion omr (nolock) on omr.idOrdenMaterial = oma.idOrdenMaterial           
and omr.idOrden=o.idOrden and om.idOrden=omr.idOrden and oma.idOrden=omr.idOrden and omr.idOrden=oe.idOrden     
inner join Paciente p (nolock) on p.idPaciente = o.idPaciente                       
where  
(EXISTS(select '' from OrdenMuestra oxs inner join MuestraCodificacion mcx on oxs.idMuestraCod = mcx.idMuestraCod       
 where (LTRIM(RTRIM(mcx.codificacion))= mc.codificacion  and oxs.idOrden = o.idOrden)))) o2  
   
  WHERE o2.idLaboratorioDestino = @IdLaboratorioUsuario  
End   