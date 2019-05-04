USE biuro

--1
--DROP PROCEDURE PROCEDURA1
GO
CREATE PROCEDURE PROCEDURA1
(
        @imie varchar(30),
        @nazwisko varchar(30),
        @adres varchar(100),
        @telefon varchar(30)
)
AS

DECLARE @numerwlasciciela varchar(5), @numer int = 0, @warunek int = 0
DECLARE kur CURSOR FOR (select * from(SELECT TOP 999 wlascicielnr FROM wlasciciele ORDER BY wlascicielnr ASC) AS STH)
OPEN kur
DECLARE @fetch varchar(8)
FETCH NEXT FROM kur INTO @fetch

WHILE @@FETCH_STATUS = 0 and @warunek = 0
BEGIN
        IF(@numer < 10)
        SET @numerwlasciciela = 'CO0' + convert(varchar, @numer)
        IF(@numer >= 10)
        SET @numerwlasciciela = 'CO' + convert(varchar, @numer)
        PRINT @fetch + @numerwlasciciela
        IF @fetch != @numerwlasciciela
        BEGIN
                SET @warunek = 1
        END
        SET @numer = @numer + 1
        FETCH NEXT FROM kur INTO @fetch
END
CLOSE kur
DEALLOCATE kur

INSERT INTO wlasciciele VALUES (@numerwlasciciela,@imie,@nazwisko,@adres,@telefon)

GO

EXEC PROCEDURA1 'Piotr', 'Janicki', 'Lodz', '123123123'
SELECT  * FROM wlasciciele ORDER BY wlascicielnr ASC

--2
GO
--drop function fn_przychodybiura
create function fn_przychodybiura(@biuro varchar(4)) returns int
BEGIN

	RETURN (SELECT SUM(wynajecia.czynsz)
			FROM wynajecia, nieruchomosci
			WHERE wynajecia.nieruchomoscNr = nieruchomosci.nieruchomoscnr AND nieruchomosci.biuroNr = @biuro
		   )
END
GO

SELECT DISTINCT biura.biuroNr, dbo.fn_przychodybiura(biura.biuroNr) AS przychody_z_wynajmu
FROM biura
WHERE dbo.fn_przychodybiura(biura.biuroNr) is not null

--3
GO
CREATE TRIGGER trigger1
ON wynajecia
AFTER INSERT
AS 
BEGIN
	IF (SELECT czynsz FROM inserted) > ( SELECT max_czynsz FROM klienci, inserted WHERE klienci.klientnr = inserted.klientnr)
	BEGIN
		UPDATE wynajecia
		SET wynajecia.czynsz = klienci.max_czynsz
		FROM klienci, inserted
		WHERE  klienci.klientnr = inserted.klientnr

		PRINT('Wprowadzony czynsz jest zbyt wysoki! Dokonano poprawy')
	END
END
GO

--4
GO
CREATE TRIGGER trigger2
ON klienci
AFTER INSERT
AS 
BEGIN
	DECLARE @klient varchar(4) = (SELECT klientnr FROM inserted), @data varchar(10) = CONVERT(varchar(10), GETDATE())
	INSERT INTO rejestracje VALUES (@klient, 'B003', 'SB21', @data)
END
GO

--5
drop function fn_prowizja
GO
create function fn_prowizja(@pracownik varchar(4), @od SMALLDATETIME, @do SMALLDATETIME) returns int
BEGIN
	RETURN(		( SELECT  COUNT(wizyty.klientnr)
				  FROM wizyty, nieruchomosci, rejestracje
			      WHERE wizyty.nieruchomoscnr = nieruchomosci.nieruchomoscnr AND nieruchomosci.personelnr = @pracownik AND wizyty.data_wizyty >= @od 
		        )*0.25*
			    ( SELECT pensja
				  FROM personel
				  WHERE personel.personelNr = @pracownik	
				)*0.02 + 
				(
				  SELECT COUNT(wynajecia.umowanr)
				  FROM wynajecia, nieruchomosci
				  WHERE wynajecia.nieruchomoscNr = nieruchomosci.nieruchomoscnr AND nieruchomosci.personelNr = @pracownik AND wynajecia.od_kiedy >= @od AND wynajecia.do_kiedy <= @do
				)*0.1*
				( SELECT pensja
				  FROM personel
				  WHERE personel.personelNr = @pracownik	
				)
		  )
END
GO

SELECT DISTINCT personel.personelNr, dbo.fn_prowizja(personel.personelNr,'2004-9-01','2020-11-01') AS prowizja
FROM personel
WHERE dbo.fn_prowizja(personel.personelNr,'2004-9-01','2020-11-01')is not null

--6
drop procedure NIEZAPLACONE
GO
CREATE PROCEDURE NIEZAPLACONE

AS			
	DECLARE kur CURSOR FOR (select * from(SELECT TOP 999 zaplacona,nieruchomoscnr, od_kiedy, do_kiedy FROM wynajecia ORDER BY od_kiedy ASC) AS STH)
	OPEN kur 
	DECLARE @fetch int, @nr varchar(4), @od datetime, @do datetime, @imie varchar(20)
	FETCH NEXT FROM kur INTO @fetch, @nr, @od, @do

	WHILE @@FETCH_STATUS = 0
	BEGIN
		IF @fetch = 0
		BEGIN
			SET @imie = (SELECT DISTINCT nazwisko FROM klienci, wynajecia WHERE klienci.klientnr = wynajecia.klientnr AND wynajecia.nieruchomoscnr = @nr)
			print('Brak wpaly od ' + @imie + ' za nieruchomosc nr ' + @nr + ' za okres ' + convert(varchar, DATEDIFF(MONTH, @od, @do)) + ' miesiecy.')
		END
		FETCH NEXT FROM kur INTO @fetch, @nr, @od, @do
	END
	CLOSE kur 
	DEALLOCATE kur
GO

EXEC NIEZAPLACONE