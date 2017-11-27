USE [NetLab2-Ogis]
GO

/****** Object:  Table [dbo].[Ubigeo]    Script Date: 11/24/2017 17:47:55 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[UbigeoPaciente]') AND type in (N'U'))
DROP TABLE [dbo].[UbigeoPaciente]
GO

select * from UbigeoPaciente
/****** Object:  Table [dbo].[Ubigeo]    Script Date: 11/24/2017 17:46:22 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

SET ANSI_PADDING ON
GO

CREATE TABLE [dbo].[UbigeoPaciente](
	[idUbigeo] [varchar](10) NOT NULL,
	[descripcion] [varchar](500) NOT NULL,
	[estado] [int] NOT NULL,
	[fechaRegistro] [datetime] NOT NULL,
	[idUsuarioRegistro] [int] NULL,
	[fechaEdicion] [datetime] NULL,
	[idUsuarioEdicion] [int] NULL,
 CONSTRAINT [PK_UbigeoPaciente] PRIMARY KEY CLUSTERED 
(
	[idUbigeo] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]

GO

SET ANSI_PADDING OFF
GO

ALTER TABLE [dbo].[UbigeoPaciente] ADD  CONSTRAINT [DF_UbigeoPaciente_estado]  DEFAULT ((1)) FOR [estado]
GO

ALTER TABLE [dbo].[UbigeoPaciente] ADD  CONSTRAINT [DF_UbigeoPaciente_fechaRegistro]  DEFAULT (getdate()) FOR [fechaRegistro]
GO


insert into UbigeoPaciente select * from Ubigeo