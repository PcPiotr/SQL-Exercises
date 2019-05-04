use szkola

-- Funkcje

--1
--Zwraca srednia ocen danego ucznia z danego roku z danej klasy z danego przedmiotu
GO
IF OBJECT_ID ('dbo.funZwrocSrednia','FN') IS NOT NULL
   DROP FUNCTION dbo.funZwrocSrednia;
GO

GO
CREATE FUNCTION funZwrocSrednia(@uczenid int, @rok int, @przedmiot int) returns float
BEGIN
	DECLARE	@srednia float, @ilosc int, @fetchprzedmiot int, @fetchuczenid int,
	@fetchdata date, @fetchocena int
	SET @srednia = 0
	SET @ilosc = 0
	DECLARE kur CURSOR FOR (SELECT uczenID, przedmiotID, data_wystawienia, ocenaID  FROM Oceny)
	OPEN kur 
	FETCH NEXT FROM kur INTO  @fetchuczenid, @fetchprzedmiot, @fetchdata, @fetchocena
	DECLARE @datastart date, @dataend date
	SET @datastart = CONVERT(varchar(4), @rok) + '0901'
	SET @dataend = CONVERT(varchar(4), @rok + 1) + '0701'
	WHILE @@FETCH_STATUS = 0
	BEGIN
		IF @fetchprzedmiot = @przedmiot AND @fetchuczenid = @uczenid AND 
		@fetchdata >= @datastart AND  @fetchdata <= @dataend 
			BEGIN
				SET @ilosc = @ilosc + (SELECT waga FROM Oceny WHERE ocenaID = @fetchocena)
				SET @srednia = @srednia + (SELECT ocena FROM Oceny WHERE ocenaID = @fetchocena)
				 * (SELECT waga FROM Oceny WHERE ocenaID = @fetchocena)
			END
			FETCH NEXT FROM kur INTO  @fetchuczenid, @fetchprzedmiot, @fetchdata, @fetchocena
	END
	CLOSE kur 
	DEALLOCATE kur

	IF @ilosc !=0
	RETURN @srednia / @ilosc	

	RETURN 0
END
GO

--uzycie
SELECT * FROM OCENY
print (dbo.funZwrocSrednia (23, 2014, 1))

--2
--Zwraca pelna pensje danego nauczyciela (najnowsza umowa)
GO
IF OBJECT_ID ('dbo.funZwrocZarobki','FN') IS NOT NULL
   DROP FUNCTION dbo.funZwrocZarobki;
GO

GO
create function funZwrocZarobki(@nauczycielid int) returns int
BEGIN
	DECLARE @kwota float

	SELECT @kwota = (SELECT TOP(1)pensja_bazowa
					 FROM Umowy
					 WHERE nauczycielID = @nauczycielid
					 ORDER by data_rozpoczecia)
					 *
					 (SELECT TOP(1) mnoznik
					  FROM Stopnie, Umowy
					  WHERE Umowy.stopien = Stopnie.stopienID AND Umowy.nauczycielID = @nauczycielid
					  ORDER by data_rozpoczecia)

	RETURN Convert(int, @kwota)
END
GO

--uzycie
select * from nauczyciele
print dbo.funZwrocZarobki(1)



--Procedury

--1
----Ustala date zakonczenia umowy z danym nauczycielem
GO  
IF OBJECT_ID ( 'procUstalDate', 'P' ) IS NOT NULL   
DROP PROCEDURE procUstalDate;  
GO  

create procedure procUstalDate @pesel CHAR(11), @dataZakonczenia date = null
AS
BEGIN
	IF @dataZakonczenia is null
		SET @dataZakonczenia = getdate()

	IF EXISTS (SELECT * FROM Nauczyciele WHERE pesel = @pesel)
		BEGIN
			DECLARE @numerNauczyciela int
			SELECT @numerNauczyciela = nauczycielID FROM Nauczyciele
													WHERE pesel = @pesel
			
			UPDATE Umowy SET data_zakonczenia = @dataZakonczenia
						 WHERE nauczycielID = @numerNauczyciela AND
						 data_zakonczenia is null
		END
	ELSE 
		BEGIN
			print('nie znaleziono nauczyciela')
		END
END

--uzycie

SELECT UMOWY.* FROM UMOWY, NAUCZYCIELE WHERE pesel = '44020382652' AND Nauczyciele.nauczycielID = Umowy.nauczycielID
exec procUstalDate '44020382652'
SELECT UMOWY.* FROM UMOWY, NAUCZYCIELE WHERE pesel = '44020382652' AND Nauczyciele.nauczycielID = Umowy.nauczycielID




--2
--Usuwa uczniowi oceny nadane w danym przedziale czasu
GO  
IF OBJECT_ID ( 'procUsunOcenyData', 'P' ) IS NOT NULL   
DROP PROCEDURE procUsunOcenyData;  
GO  

create procedure procUsunOcenyData @pesel CHAR(11), @dataStart date, @dataKoniec date = null
AS
BEGIN

	IF @dataKoniec is null
		BEGIN
			SET @dataKoniec = getdate()
		END

	DECLARE @numerUcznia int
	SELECT @numerUcznia = uczenID FROM Uczniowie
								  WHERE pesel = @pesel

	DELETE FROM OCENY
		   WHERE uczenID = @numerUcznia AND
				 data_wystawienia >= @dataStart AND
				 data_wystawienia <= @dataKoniec
END

--uzycie
SELECT Oceny.ocena, Oceny.ocenaID FROM Oceny, Uczniowie WHERE Uczniowie.uczenID = Oceny.uczenID AND Uczniowie.pesel = '04282276841' 
exec procUsunOcenyData '', 
SELECT Oceny.ocena, Oceny.ocenaID FROM Oceny, Uczniowie WHERE Uczniowie.uczenID = Oceny.uczenID AND Uczniowie.pesel = '' 





--3
--Stworz ucznia i dodaj go do klasy
GO  
IF OBJECT_ID ( 'procNowyUczen', 'P' ) IS NOT NULL   
DROP PROCEDURE procNowyUczen;  
GO  
create procedure procNowyUczen @pesel CHAR(11), @imie VARCHAR(255), @nazwisko VARCHAR(255), @plec CHAR(1), @data_urodzenia DATE, @klasa VARCHAR(7), @data_rozpoczenia_nauki date = null
AS
BEGIN

	IF @data_rozpoczenia_nauki is null
		BEGIN
			SET @data_rozpoczenia_nauki = getdate()
		END

	IF EXISTS (SELECT * FROM Klasy WHERE klasaID = @klasa) AND LEN(@pesel) = 11 AND @imie is not null AND @nazwisko is not null AND (@plec = 'K' OR @plec = 'M')
	BEGIN
		INSERT INTO Uczniowie VALUES (
		@pesel,
		@imie,
		@nazwisko,
		@plec,
		@data_urodzenia,
		@data_rozpoczenia_nauki,
		NULL
		);

		DECLARE @numerUcznia int
		SELECT @numerUcznia = uczenID FROM Uczniowie
									  WHERE pesel = @pesel

		INSERT INTO KlasyUczniow VALUES(@klasa, @numerUcznia)

	END
	ELSE
		BEGIN
			print('nieprawidłowe dane')
		END
END


--uzycie
SELECT * FROM KlasyUczniow WHERE klasaID = '3C2018'
exec procNowyUczen '71101237969', 'Angelika', 'Majewska', 'K', '2007-10-12', '3C2018'
SELECT * FROM KlasyUczniow WHERE klasaID = '3C2018'
SELECT * FROM Uczniowie WHERE Uczniowie.pesel = '71101237969'




--4
--Sprawdzanie zgodnosci peselu u nauczycieli
GO  
IF OBJECT_ID ( 'procPesel', 'P' ) IS NOT NULL   
DROP PROCEDURE procPesel;  
GO  
create procedure procPesel
AS
BEGIN
	DECLARE	@Data DATE, @plec CHAR(1), @fetch CHAR(11), @fetch2 date, @tempDatevarchar varchar(20)
	DECLARE kur CURSOR FOR (SELECT pesel, data_urodzenia  FROM Nauczyciele)
	OPEN kur 
	FETCH NEXT FROM kur INTO @fetch, @fetch2
	WHILE @@FETCH_STATUS = 0
	BEGIN
		SET @Data = ('19' + SUBSTRING(@fetch, 1, 2) + SUBSTRING(@fetch, 3, 2) + SUBSTRING(@fetch, 5,2))
		IF(@fetch2 != @Data)
			BEGIN
				print('Znaleziono błędne dane! Próba poprawy dla Peselu: ' + @fetch)

				UPDATE nauczyciele
				SET data_urodzenia = @Data
				WHERE pesel = @fetch
			END
			FETCH NEXT FROM kur INTO @fetch, @fetch2
	END
	CLOSE kur 
	DEALLOCATE kur	
END

--Triggery

--1
-- Blokuje dodanie nauczyciela jako uczacego danej klasy, jesli dany nauczyciel nie uczy juz w tej szkole
GO
IF OBJECT_ID ('dbo.NauczycielNieuczy','TR') IS NOT NULL
   DROP TRIGGER dbo.NauczycielNieuczy;
GO

CREATE TRIGGER dbo.NauczycielNieuczy 
ON dbo.KlasaPrzedmiotNauczyciel
INSTEAD OF INSERT
AS
BEGIN
	IF EXISTS(SELECT umowaID 
	          FROM Umowy, Nauczyciele, KlasaPrzedmiotNauczyciel
			  WHERE Umowy.nauczycielID = Nauczyciele.nauczycielID AND 
			  Umowy.data_zakonczenia IS NULL AND KlasaPrzedmiotNauczyciel.nauczycielID in(SELECT nauczycielID FROM inserted)
			  )
		BEGIN
			INSERT INTO KlasaPrzedmiotNauczyciel(klasaID, nauczycielID, przedmiotID) 
			SELECT klasaID, nauczycielID, przedmiotID FROM inserted
		END
	ELSE
		BEGIN
			print 'Wskazany nauczyciel nie uczy'
		END
END


--2
-- Przy ustawieniu zerowej pensji, pensja nauczyciela zostaje zminiona na pensje srednia
GO
IF OBJECT_ID ('dbo.PensjaZero','TR') IS NOT NULL
   DROP TRIGGER dbo.PensjaZero;
GO
CREATE TRIGGER dbo.PensjaZero 
ON dbo.Umowy
AFTER UPDATE
AS
BEGIN
	IF (SELECT pensja_bazowa FROM inserted) = 0 
		BEGIN
			DECLARE @srednia int;
			SELECT  @srednia = AVG(pensja_bazowa) FROM Umowy
			UPDATE Umowy
			SET pensja_bazowa = @srednia 
			WHERE umowaID IN(SELECT umowaID FROM inserted )
			print 'Poprawiono pensje bazowa'
		END
END


--3
-- Usuniecie ucznia usuwa jego oceny i przypisanie do klas
GO
IF OBJECT_ID ('dbo.SprzataniePoUczniu','TR') IS NOT NULL
   DROP TRIGGER dbo.SprzataniePoUczniu;
GO
CREATE TRIGGER dbo.SprzataniePoUczniu 
ON dbo.Uczniowie
INSTEAD OF DELETE
AS
BEGIN
	DECLARE @idDoUsuniecia int
	SELECT @idDoUsuniecia =  uczenID FROM deleted

	DELETE FROM KlasyUczniow
	WHERE uczenID = @idDoUsuniecia

	DELETE FROM Oceny
	WHERE uczenID = @idDoUsuniecia

	DELETE FROM Uczniowie
	WHERE uczenID  = @idDoUsuniecia
END

--uzycie

SELECT * FROM Uczniowie where uczenID = 1
SELECT * FROM KlasyUczniow where uczenID = 1

DELETE FROM Uczniowie where uczenID = 1

SELECT * FROM Uczniowie where uczenID = 1
SELECT * FROM KlasyUczniow where uczenID = 1