use test_pracownicy

--1
CREATE TABLE dziennik (
    tabela varchar(15),
    data date,
    l_wierszy int,
    komunikat varchar(300)
); 

--2
DECLARE @kwota INT = 500, @ilosczmian int = 0, @fetch VARCHAR(18)
DECLARE kur CURSOR FOR (SELECT stanowisko FROM pracownicy)
OPEN kur 
FETCH NEXT FROM kur INTO @fetch
WHILE @@FETCH_STATUS = 0
BEGIN
	IF @fetch = 'DYREKTOR' or  @fetch = 'PREZES'
	BEGIN	
		UPDATE pracownicy
		SET placa = placa + @kwota
		WHERE stanowisko = @fetch
		SET @ilosczmian = @ilosczmian + 1
	END
	FETCH NEXT FROM kur INTO @fetch
END		
CLOSE kur 
DEALLOCATE kur

BEGIN
	DECLARE @komunikat VARCHAR(300)= 'Wprowadzono dodatek funkcyjny w wysokosci: ' + CONVERT(varchar, @kwota) + ' PLN'
	INSERT dziennik VALUES ('pracownicy', GETDATE(), @ilosczmian, @komunikat)
END

SELECT * FROM test_pracownicy.dbo.pracownicy;
SELECT * FROM test_pracownicy.dbo.dziennik;

--3
DECLARE @rok INT = 1990, @fetch3 date, @iloscpracownikow int = 0
DECLARE kur CURSOR FOR (SELECT data_zatr FROM pracownicy)
OPEN kur 
FETCH NEXT FROM kur INTO @fetch3
WHILE @@FETCH_STATUS = 0
BEGIN
	IF YEAR(@fetch3) = @rok
	BEGIN	
		SET @iloscpracownikow = @iloscpracownikow + 1
	END
	FETCH NEXT FROM kur INTO @fetch3
END		
CLOSE kur 
DEALLOCATE kur

BEGIN
	DECLARE @komunikat2 VARCHAR(300)
	IF @iloscpracownikow>0
	SET @komunikat2 = 'Zatrudniono ' + CONVERT(varchar, @iloscpracownikow) +' pracownikow'
	IF @iloscpracownikow=0
	SET @komunikat2 = 'Nikogo nie zatrudniono'
	INSERT dziennik VALUES ('pracownicy', GETDATE(), @iloscpracownikow, @komunikat2)
END

SELECT * FROM test_pracownicy.dbo.dziennik

--4
DECLARE @numerpracownika INT = 8902, @fetch4 INT, @okres INT
DECLARE kur CURSOR FOR (SELECT nr_akt FROM pracownicy)
OPEN kur 
FETCH NEXT FROM kur INTO @fetch4
WHILE @@FETCH_STATUS = 0
BEGIN
	IF @fetch4 = @numerpracownika
	BEGIN	
		UPDATE pracownicy
		SET @okres = DATEDIFF(year, data_zatr, data_zwol)
		WHERE nr_akt = @fetch4
		if @okres is null
		BEGIN
			UPDATE pracownicy
			SET @okres = DATEDIFF(year, data_zatr, GETDATE())
		END
	END
	FETCH NEXT FROM kur INTO @fetch4
END		
CLOSE kur 
DEALLOCATE kur

BEGIN
	DECLARE @komunikat4 VARCHAR(300)
	IF @okres>=15
	SET @komunikat4 = 'Pracownik jest zatrudniony dluzej niz 15 lat'
	ELSE
	SET @komunikat4 = 'Pracownik jest zatrudniony krocej niz 15 lat'
	INSERT dziennik VALUES ('pracownicy', GETDATE(), @okres, @komunikat4)
END

SELECT * FROM test_pracownicy.dbo.dziennik

--5
--DROP PROCEDURE PIERWSZA
GO
CREATE PROCEDURE PIERWSZA
(
  @parametr INT
)
AS
PRINT ('Wartosc parametru wynosila: ' + CONVERT(varchar, @parametr))
GO

EXEC PIERWSZA 60

--6
--DROP PROCEDURE DRUGA
GO
CREATE PROCEDURE DRUGA
(
	@pierwszy varchar(20) = NULL,
	@drugi varchar(20) OUTPUT,
	@trzeci INT = 1
)
AS
DECLARE @lokalna varchar(20) = 'DRUGA'
SET @drugi = @lokalna + @pierwszy + CONVERT(varchar, @trzeci)
GO

--7
GO
--DROP PROCEDURE PODWYZKA
CREATE PROCEDURE PODWYZKA
(
	@dzial int,
	@procent int
)
AS
	DECLARE kur CURSOR FOR (SELECT id_dzialu FROM pracownicy)
	OPEN kur 
	DECLARE @fetch7 int, @liczbamody int = 0
	FETCH NEXT FROM kur INTO @fetch7

	WHILE @@FETCH_STATUS = 0
	BEGIN
		IF @fetch7 = @dzial OR @dzial = 0
		BEGIN
			UPDATE pracownicy
			SET placa = placa + placa*(@procent/100.0)
			SET @liczbamody = @liczbamody + 1
		END
		FETCH NEXT FROM kur INTO @fetch7
	END
	CLOSE kur 
	DEALLOCATE kur

    BEGIN
		DECLARE @komunikat7 VARCHAR(300)
		SET @komunikat7 = 'Wprowadzono podwyzke o ' + CONVERT(varchar, @procent) + ' procent'
		INSERT dziennik VALUES ('pracownicy', GETDATE(), @liczbamody, @komunikat7)
	END
GO

--8
--drop function fn_procent
go
create function fn_procent(@dzial int) returns int
BEGIN
	DECLARE @placa int
	DECLARE kur CURSOR FOR (SELECT id_dzialu, placa FROM pracownicy)
	OPEN kur 
	DECLARE @fetchfunkcyjny int, @kasadzialu int = 0, @kasafirmy int = 0
	FETCH NEXT FROM kur INTO @fetchfunkcyjny, @placa

	WHILE @@FETCH_STATUS = 0
	BEGIN
		IF @fetchfunkcyjny = @dzial
		BEGIN
			SET @kasadzialu = @kasadzialu + @placa
		END
		SET @kasafirmy = @kasafirmy + @placa
		FETCH NEXT FROM kur INTO @fetchfunkcyjny, @placa
	END
	DECLARE @wynik int = @kasadzialu*100
	RETURN @wynik/@kasafirmy
END
go
-- strata 5% z zaokraglania przy int
select distinct id_dzialu, dbo.fn_procent(id_dzialu)  as udzial_w_budzecie
from pracownicy
where id_dzialu is not null
group by id_dzialu

--9
GO
CREATE TRIGGER trigger1
ON pracownicy
AFTER DELETE
AS 
insert into prac_archiw select * from deleted
GO
