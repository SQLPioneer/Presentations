CREATE TABLE [dbo].[Courses] (
    [CourseID] INT            IDENTITY (1, 1) NOT NULL,
    [Title]    NVARCHAR (MAX) NULL,
    [Credits]  INT            NOT NULL,
    CONSTRAINT [PK_dbo.Courses] PRIMARY KEY CLUSTERED ([CourseID] ASC)
);

