CREATE TABLE [dbo].[Students] (
    [ID]             INT            IDENTITY (1, 1) NOT NULL,
    [LastName]       NVARCHAR (MAX) NULL,
    [FirstMidName]   NVARCHAR (MAX) NULL,
    [EnrollmentDate] DATETIME       NOT NULL,
    CONSTRAINT [PK_dbo.Students] PRIMARY KEY CLUSTERED ([ID] ASC)
);

