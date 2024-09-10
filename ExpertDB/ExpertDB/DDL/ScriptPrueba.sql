
CREATE DATABASE ExpertPruebaDB
GO
USE ExpertPruebaDB
Go 
--tabla usuario punto 1
CREATE TABLE tbl_Usuario(
id int identity primary key,
Nombre nvarchar(200),
Apellido nvarchar(200),
Edad int,
Correo nvarchar(200),
Hobbies nvarchar(2000),
Activo bit,
FechaInsercion date,
FechaActualizacion date
)

GO

--procedimiento almacenado para insertar el dato
CREATE PROC Sp_InsertarUsuario 
@Nombre nvarchar(200),
@Apellido nvarchar(200),
@Edad int,
@Correo nvarchar(200),
@Hobbies nvarchar(2000)
AS

	INSERT INTO tbl_Usuario 
	VALUES (@Nombre,@Apellido, @Edad, @Correo, dbo.OrdenarPalabras(@Hobbies), 1, getdate(), null)


Go


--funcion para ordenar las palabras 
CREATE FUNCTION OrdenarPalabras
(
    @Cadena NVARCHAR(MAX)
)
RETURNS NVARCHAR(MAX)
AS
BEGIN
    DECLARE @TablaPalabras TABLE (Palabra NVARCHAR(255));
    DECLARE @Palabra NVARCHAR(255);
    DECLARE @Posicion INT;

   SET @Cadena = REPLACE(@Cadena, '-', ',');
    
    WHILE LEN(@Cadena) > 0
    BEGIN
       
        SET @Posicion = CHARINDEX(',', @Cadena);

        IF @Posicion > 0
        BEGIN
           
            SET @Palabra = LTRIM(RTRIM(SUBSTRING(@Cadena, 1, @Posicion - 1)));
            SET @Cadena = SUBSTRING(@Cadena, @Posicion + 1, LEN(@Cadena) - @Posicion);
        END
        ELSE
        BEGIN
            SET @Palabra = LTRIM(RTRIM(@Cadena));
            SET @Cadena = '';
        END

      
        INSERT INTO @TablaPalabras (Palabra) VALUES (@Palabra);
    END

  
    DECLARE @Resultado NVARCHAR(MAX) = '';

    SELECT @Resultado = @Resultado + CASE WHEN LEN(@Resultado) > 0 THEN ',' ELSE '' END + Palabra
    FROM @TablaPalabras
    ORDER BY Palabra;

   
    RETURN @Resultado;
END;

GO

--procedimiento almacenado que trae los usuarios mayores o iguales a unas edad

CREATE PROCEDURE Sp_ListadoEdadUsuario
@Edad INT
AS

 SELECT  id
      ,Nombre
      ,Apellido
      ,Edad
      ,Correo
      ,dbo.OrdenarPalabras(Hobbies)
      ,Activo
      ,FechaInsercion
      ,FechaActualizacion
  FROM [ExpertPruebaDB].[dbo].[tbl_Usuario]
  WHERE [Edad] >= @Edad
  ORDER BY Edad ASC
  
  
  Go

 --procedimiento almacenado para traer lo usuarios creados las dos ultimas horas

 CREATE PROCEDURE Sp_ListarUsuariosCreados
 AS
  SELECT  id
      ,Nombre
      ,Apellido
      ,Edad
      ,Correo
      ,dbo.OrdenarPalabras(Hobbies)
      ,Activo
      ,FechaInsercion
      ,FechaActualizacion
  FROM [ExpertPruebaDB].[dbo].[tbl_Usuario]
  WHERE FechaInsercion >= DATEADD(HOUR, -2, GETDATE())
  ORDER BY FechaInsercion ASC
