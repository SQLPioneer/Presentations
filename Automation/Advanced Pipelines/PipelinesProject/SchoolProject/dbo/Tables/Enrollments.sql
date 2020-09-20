CREATE TABLE [dbo].[Enrollments] (
    [EnrollmentID] INT IDENTITY (1, 1) NOT NULL,
    [CourseID]     INT NOT NULL,
    [StudentID]    INT NOT NULL,
    [Grade]        INT NULL,
    CONSTRAINT [PK_dbo.Enrollments] PRIMARY KEY CLUSTERED ([EnrollmentID] ASC),
    CONSTRAINT [FK_dbo.Enrollments_dbo.Courses_CourseID] FOREIGN KEY ([CourseID]) REFERENCES [dbo].[Courses] ([CourseID]) ON DELETE CASCADE,
    CONSTRAINT [FK_dbo.Enrollments_dbo.Students_StudentID] FOREIGN KEY ([StudentID]) REFERENCES [dbo].[Students] ([ID]) ON DELETE CASCADE
);


GO
CREATE NONCLUSTERED INDEX [IX_StudentID]
    ON [dbo].[Enrollments]([StudentID] ASC);


GO
CREATE NONCLUSTERED INDEX [IX_CourseID]
    ON [dbo].[Enrollments]([CourseID] ASC);

