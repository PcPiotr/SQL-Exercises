use narciarze

--1
SELECT * FROM ZAWODNICY
SELECT * FROM KRAJE
SELECT * FROM uczestnictwa_w_zawodach
SELECT * FROM skocznie
SELECT * FROM trenerzy
SELECT * FROM zawody

--2
SELECT COUNT(k.kraj) as liczba_krajow from kraje as k
SELECT DISTINCT k.kraj from kraje as k, zawodnicy as z where k.id_kraju = z.id_kraju

--3
SELECT DISTINCT k.kraj, count(z.id_skoczka) as Ilosc from kraje as k, zawodnicy as z where k.id_kraju = z.id_kraju
group by k.kraj

--4
select zawodnicy.nazwisko from zawodnicy, uczestnictwa_w_zawodach where uczestnictwa_w_zawodach.id_skoczka is NULL;

--5
SELECT zawodnicy.nazwisko, count(uczestnictwa_w_zawodach.id_zawodow) as liczba from zawodnicy, uczestnictwa_w_zawodach
WHERE uczestnictwa_w_zawodach.id_skoczka = zawodnicy.id_skoczka
group by zawodnicy.nazwisko

--6
SELECT DISTINCT zawodnicy.nazwisko, skocznie.nazwa from skocznie, zawodnicy, zawody, uczestnictwa_w_zawodach
WHERE skocznie.id_skoczni = zawody.id_skoczni AND zawody.id_zawodow = uczestnictwa_w_zawodach.id_zawodow AND uczestnictwa_w_zawodach.id_skoczka = zawodnicy.id_skoczka

--7
SELECT DISTINCT zawodnicy.nazwisko, DATEDIFF(Year, data_ur, getdate()) as wiek from zawodnicy order by wiek

--8
SELECT DISTINCT zawodnicy.nazwisko, DATEDIFF(Year, zawodnicy.data_ur, zawody.DATA) as wiek from zawodnicy, zawody, uczestnictwa_w_zawodach
WHERE  zawody.DATA=(select min(zawody.DATA) from zawody, zawodnicy, uczestnictwa_w_zawodach where zawodnicy.id_skoczka = uczestnictwa_w_zawodach.id_skoczka)

--9
SELECT DISTINCT skocznie.nazwa, (sedz - k) as roznica from skocznie 

--10
SELECT DISTINCT skocznie.nazwa, (sedz - k) as roznica from skocznie 
WHERE (sedz - k)=(select max(sedz - k) from skocznie)

--11
SELECT DISTINCT kraje.kraj from kraje ,zawody, skocznie
WHERE zawody.id_skoczni = skocznie.id_skoczni and skocznie.id_kraju = kraje.id_kraju

--12
SELECT DISTINCT zawodnicy.nazwisko, kraje.kraj, COUNT(uczestnictwa_w_zawodach.id_zawodow) as ilosc from kraje ,zawody, skocznie, zawodnicy, uczestnictwa_w_zawodach
WHERE zawody.id_skoczni = skocznie.id_skoczni and skocznie.id_kraju = kraje.id_kraju and zawodnicy.id_kraju = kraje.id_kraju and uczestnictwa_w_zawodach.id_skoczka = zawodnicy.id_skoczka and uczestnictwa_w_zawodach.id_zawodow = zawody.id_zawodow
group by  zawodnicy.nazwisko, kraje.kraj

--13
INSERT INTO trenerzy VALUES (7, 'Corby', 'Fisher', '1975-07-20');
select * from trenerzy;

--14
ALTER TABLE zawodnicy add trener int;
select * from zawodnicy;

--15
UPDATE zawodnicy 
SET zawodnicy.trener = t.id_trenera
FROM dbo.trenerzy t, dbo.zawodnicy z
WHERE t.id_kraju = z.id_kraju

select * from zawodnicy WHERE data_ur='1974-04-13';

--16
alter table zawodnicy
ADD CONSTRAINT FK_Trener_Zawodnik
foreign key (trener) REFERENCES dbo.trenerzy(id_trenera);

--17
UPDATE trenerzy
SET trenerzy.data_ur_t = (
	SELECT MIN(zawodnicy.data_ur) - YEAR(5)
	FROM zawodnicy, trenerzy
	WHERE trenerzy.id_trenera = zawodnicy.trener AND kraje.id_kraju =  trenerzy.id_kraju AND kraje.id_kraju = zawodnicy.id_kraju
	)
FROM zawodnicy, trenerzy, kraje
WHERE trenerzy.data_ur_t is null AND trenerzy.id_trenera = zawodnicy.trener AND kraje.id_kraju =  trenerzy.id_kraju AND kraje.id_kraju =  zawodnicy.id_kraju

select distinct trenerzy.data_ur_t, trenerzy.nazwisko_t from trenerzy, zawodnicy
