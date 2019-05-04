use biblioteka

--2.1
declare @x int, @s
varchar(10)

set @x=10
set @s='napis'

print @x+2
print @s

--2.2
declare @imieP varchar(20), @nazwiskoP varchar(20)
select @imieP=imie, @nazwiskoP=nazwisko from biblioteka..pracownicy where id=7
print @imieP+' '+@nazwiskoP

--3.1, ostatni
declare @imieP varchar(20), @nazwiskoP varchar(20)
select @imieP=imie, @nazwiskoP=nazwisko from biblioteka..pracownicy
print @imieP+' '+@nazwiskoP

--str3.2

--1 Jan Borsuk
declare @imieP varchar(20), @nazwiskoP varchar(20)
set @imieP='Teofil'
set @nazwiskoP='Szczerbaty'
select @imieP=imie, @nazwiskoP=nazwisko from biblioteka..pracownicy where id=1
print @imieP+' '+@nazwiskoP

--2 Teofil Szczerbaty
declare @imieP varchar(20), @nazwiskoP varchar(20)
set @imieP='Teofil'
set @nazwiskoP='Szczerbaty'
select @imieP=imie, @nazwiskoP=nazwisko from biblioteka..pracownicy where id=20
print @imieP+' '+@nazwiskoP

--4

--WAITFOR
create table biblioteka..liczby ( licz1 int, czas datetime default getdate());
go
declare @x int
set @x=2
insert into biblioteka..liczby(licz1) values( @x );
waitfor delay '00:00:10'
insert into biblioteka..liczby(licz1) values( @x+2);
select * from biblioteka..liczby;

-- IF..ELSE
if EXISTS( select * from biblioteka..wypozyczenia) print('Były wypożyczenia')
else print('Nie było żadnych wypożyczeń')

--5

--WHILE
declare @y int
set @y=0
while ( @y<10 )
begin
	print @y
	if ( @y=5 ) break
	set @y=@y+1
end

-- CASE
select tytul as tytulK, cena as cenaK, [cena jest]=CASE
	when cena<20.00 then 'Niska'
	when cena between 20.00 and 40.00 then 'Przystêpna'
	when cena>40 then 'Wysoka'
	else 'Nieznana'
	end
from biblioteka..ksiazki

--6

--NULLIF
select
count(*) as [Ilość wypożyczeń],
avg( nullif( kara, 0 ) ) as [Średnia kara],
min( nullif( kara, 0 ) ) as [kara minimalna]
from biblioteka.dbo.wypozyczenia

--ISNULL
select id_w,data_z, isnull( data_z, ( select max(data_z) from biblioteka..wypozyczenia ))
	from biblioteka..wypozyczenia

--7

-- Komunikaty o błędzie
raiserror (21000, 10, 1)
print @@error
raiserror (21000, 10, 1) with seterror
print @@error
raiserror (21000, 11, 1)
print @@error
raiserror ('Ala ma kota', 11, 1)
print @@error

--8
declare @d1 datetime, @d2 datetime
set @d1='20091020'
set @d2='20091025'

select dateadd(hour, 112, @d1)
select dateadd(day, 112, @d1)

select datediff(minute, @d1, @d2)
select datediff(day, @d1, @d2)

select datename(month, @d1)
select datepart(month, @d1)

select cast(day(@d1) as varchar)
+'-'+cast(month(@d1) as varchar)+'-'+cast(year(@d1) as varchar)

--9
select col_length('biblioteka..pracownicy', 'imie')

select DATALENGTH(2+3.4)

select db_id('master')

select db_name(1)

select user_id()

select host_name()

use biblioteka;

select object_id('Pracownicy')

select object_name(object_id('Pracownicy'))

--10

-- 1 --
if exists(select 1 from master.dbo.sysdatabases where name = 'test_cwiczenia')
drop database test_cwiczenia
go
create database test_cwiczenia
go
use test_cwiczenia
go
create table test_cwiczenia..liczby (liczba int)
go
declare @i int
set @i=1
while @i<100
begin
	insert test_cwiczenia..liczby values( @i)
	set @i=@i+1
end
go
select * from test_cwiczenia..liczby;

--11

-- 2 --
use test_cwiczenia
go
if exists (select 1 from sys.objects where TYPE = 'P' and name = 'proc_liczby')
drop procedure proc_liczby
go
create procedure proc_liczby @max int = 10
as 
begin
	select liczba from test_cwiczenia..liczby
	where liczba<=@max
end
go
exec test_cwiczenia..proc_liczby 3
exec test_cwiczenia..proc_liczby
go

--12

-- 3 --
use test_cwiczenia
go
if exists(select 1 from sys.objects where TYPE = 'P' and name = 'proc_statystyka')
drop procedure proc_statystyka
go
create procedure proc_statystyka @max int output, @min int output, @aux int output
as
begin
	set @max=( select max(liczba) from test_cwiczenia..liczby )
	set @max=( select min(liczba) from test_cwiczenia..liczby )
	set @aux=10
end
go
declare @max int, @min int, @aux2 int
exec test_cwiczenia..proc_statystyka @max output, @min output, @aux=@aux2 output
select @max 'Max', @min 'Min', @aux2
go

--13

-- 1 --

--drop function fn_srednia

create function fn_srednia(@rodzaj varchar (40)) returns int
begin
	return ( select AVG( cena ) from biblioteka.dbo.ksiazki where gatunek=@rodzaj )
end

select dbo.fn_srednia('dla dzieci') as srednia_cena

-- 2 --

--drop function funkcja

create function funkcja(@max int) returns table
return (select * from biblioteka.dbo.wypozyczenia where id_p<=@max)

select * from funkcja(5)