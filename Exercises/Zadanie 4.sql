
--1
declare @s varchar(15)
set @s='Czesc, to ja'
print @s

--2
declare @ss varchar(15)
declare @x int
set @x=10
set @ss='ZMIENNA = '
print @s + CONVERT(varchar, @x)

--3
declare @xx int
set @xx=-10
IF @xx<0 print('x ujemne')
else print('x nieujemne')

--4
declare @y int
declare @yy varchar(20)
set @yy='zmienna ma wartosc '
set @y=1
while ( @y<5 )
begin
	print @yy +  CONVERT(varchar, @y)
	set @y=@y+1
end

--5
declare @z int
declare @zz varchar(20)
set @z=3
while ( @z<=7 )
begin
	set @zz=''
	if( @z=3 ) set @zz=' poczatek'
	if( @z=5 ) set @zz=' srodek'
	if( @z=7 ) set @zz=' koniec'
	print CONVERT(varchar, @z) +  @zz
	set @z=@z+1
end

--6
--create database test_database
use test_database

CREATE TABLE ODDZIALY (
    NR_ODD INT,
    NAZWA_ODD VARCHAR(30),
);

INSERT INTO ODDZIALY (NR_ODD, NAZWA_ODD)
VALUES (1, 'raz'), (2, 'dwa'), (3, 'trzy'), (4, 'cztery'), (5, 'piêæ');

SELECT * FROM ODDZIALY

--7
declare @numer int
set @numer = 3
declare @nazwa varchar(30)
set @nazwa=(SELECT NAZWA_ODD FROM ODDZIALY WHERE NR_ODD = @numer )
print 'Nazwa oddzialu to: '+ @nazwa

--8
DECLARE @I INT, @II varchar(30)
declare kur SCROLL cursor for 
select NR_ODD from ODDZIALY ORDER BY NR_ODD
OPEN kur;
FETCH FIRST FROM kur INTO @I;
while @@FETCH_STATUS = 0
begin
	PRINT 'NUMER ODDZIALU TO: ' + CONVERT(varchar, @I) + ', NAZWA ODDZIALU TO: ' + @II 
	set @II=(SELECT NAZWA_ODD FROM ODDZIALY WHERE NR_ODD = @I )
	FETCH NEXT FROM kur INTO @I;
end
CLOSE kur;
DEALLOCATE kur;

--9
DECLARE @III INT, @IV INT
set @IV = 0
declare kur SCROLL cursor for 
select NR_ODD from ODDZIALY ORDER BY NR_ODD
OPEN kur;
FETCH FIRST FROM kur INTO @III;
while @@FETCH_STATUS = 0
begin
	if(@III>2)
	BEGIN
		DELETE FROM ODDZIALY WHERE NR_ODD=@III
		set @IV=@IV+1
	END
	FETCH NEXT FROM kur INTO @III;	
end
print 'Liczba usunietych rekordow to: ' +  CONVERT(varchar, @IV)
CLOSE kur;
DEALLOCATE kur;
SELECT * FROM ODDZIALY

--10
DECLARE kur cursor for (SELECT NR_ODD FROM ODDZIALY  )
OPEN kur 
DECLARE  @doZmiany INT=3, @zmienna INT, @flaga INT=0
FETCH NEXT FROM kur INTO @zmienna
WHILE @@FETCH_STATUS = 0
BEGIN
	IF @zmienna = @doZmiany
	BEGIN
		UPDATE ODDZIALY
		SET NAZWA_ODD = 'Zmieniona nazwa'
		WHERE NR_ODD = @zmienna
		set @flaga = 1
	END
	FETCH NEXT FROM kur INTO @zmienna
END
CLOSE kur 
DEALLOCATE kur

IF @flaga =0
BEGIN
INSERT ODDZIALY VALUES (@doZmiany, 'NOWY STWORZONY ODDZIAL')
END

SELECT * FROM ODDZIALY

