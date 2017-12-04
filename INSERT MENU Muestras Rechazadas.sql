USE [NetLab2-Ogis]
GO

/*******************************************************************************          
Descripcion: Registra una nueva opción "Muestras Rechazadas"          
Creado por: Marcos Mejia
Fecha Creacion: 01/12/2017          
*******************************************************************************/  

INSERT INTO [dbo].[Menu]
           ([idMenu]
           ,[nombre]
           ,[descripcion]
           ,[URL]
           ,[idMenuPadre]
           ,[orden]
           ,[estado]
           ,[fechaRegistro]
           ,[idUsuarioRegistro]
           ,[fechaEdicion]
           ,[idUsuarioEdicion]
           ,[icon])
     VALUES
           (50
           ,'Busqueda Rechazos'
           ,'Busqueda Rechazos'
           ,'/OrdenMuestra/BusquedaMuestraRechazar'
           ,2
           ,5
           ,1
           ,GETDATE()
           ,1
           ,NULL
           ,NULL
           ,'busqueda_ordenes.png')
GO

