use biuro

--0

SELECT * FROM wynajecia
SELECT * FROM klienci
SELECT * FROM wizyty
SELECT * FROM rejestracje
SELECT * FROM biura
SELECT * FROM biura2
SELECT * FROM personel
SELECT * FROM wlasciciele
SELECT * FROM nieruchomosci
SELECT * FROM nieruchomosci2

--1

SELECT nieruchomosci.nieruchomoscnr,
	(SELECT COUNT(wizyty.nieruchomoscnr) FROM wizyty WHERE nieruchomosci.nieruchomoscnr = wizyty.nieruchomoscnr) AS ile_wizyt, 
	(SELECT COUNT(wynajecia.nieruchomoscNr) FROM wynajecia WHERE nieruchomosci.nieruchomoscnr = wynajecia.nieruchomoscNr) AS ile_wynajmow
FROM nieruchomosci
GROUP BY nieruchomosci.nieruchomoscnr

--2

SELECT DISTINCT nieruchomosci.nieruchomoscnr, STR (ABS(nieruchomosci.czynsz*100/wynajecia.czynsz)-100)+'%' AS podwyzka  FROM nieruchomosci, wynajecia
WHERE nieruchomosci.nieruchomoscnr=wynajecia.nieruchomoscNr and wynajecia.czynsz=(
	SELECT MIN(wynajecia.czynsz) 
	FROM wynajecia 
	WHERE nieruchomosci.nieruchomoscnr=wynajecia.nieruchomoscNr)
ORDER BY nieruchomosci.nieruchomoscnr ASC


--3

SELECT DISTINCT nieruchomosci.nieruchomoscnr, 
	(SELECT SUM(wynajecia.czynsz*(DATEDIFF(month, od_kiedy, do_kiedy)+1)) 
	 FROM wynajecia 
	 WHERE nieruchomosci.nieruchomoscnr = wynajecia.nieruchomoscnr) AS ile
FROM nieruchomosci

--4
SELECT biura.biuroNr, 
			(SELECT SUM(wynajecia.czynsz*(DATEDIFF(month, od_kiedy, do_kiedy)+1)*0.3)  
			 FROM nieruchomosci, wynajecia
			 WHERE biura.biuroNr=nieruchomosci.biuroNr and nieruchomosci.nieruchomoscnr=wynajecia.nieruchomoscNr) AS ile
FROM biura
WHERE		(SELECT SUM(wynajecia.czynsz*(DATEDIFF(month, od_kiedy, do_kiedy)+1)*0.3)  
			 FROM nieruchomosci, wynajecia
			 WHERE biura.biuroNr=nieruchomosci.biuroNr and nieruchomosci.nieruchomoscnr=wynajecia.nieruchomoscNr) is not null
--5a

SELECT TOP(1)nieruchomosci.miasto, COUNT(wynajecia.czynsz) As ilosc
FROM nieruchomosci, wynajecia
WHERE wynajecia.nieruchomoscnr = nieruchomosci.nieruchomoscnr 
GROUP BY nieruchomosci.miasto
ORDER BY ilosc DESC

--5b

SELECT TOP(1)nieruchomosci.miasto, SUM(DATEDIFF(DAY, od_kiedy, do_kiedy)) As ilosc
FROM nieruchomosci, wynajecia
WHERE wynajecia.nieruchomoscnr = nieruchomosci.nieruchomoscnr 
GROUP BY nieruchomosci.miasto
ORDER BY ilosc DESC

--6

SELECT DISTINCT wizyty.klientnr, wizyty.nieruchomoscnr 
FROM wizyty, wynajecia
WHERE wynajecia.nieruchomoscNr = wizyty.nieruchomoscnr AND wynajecia.klientnr = wizyty.klientnr
ORDER BY wizyty.klientnr

--7

SELECT wizyty.klientnr, COUNT(wizyty.data_wizyty) 
FROM wizyty, klienci
WHERE wizyty.klientnr = klienci.klientnr
GROUP BY wizyty.klientnr

--8

SELECT DISTINCT klienci.klientnr 
FROM klienci, wynajecia
WHERE wynajecia.klientnr=klienci.klientnr AND wynajecia.czynsz>klienci.max_czynsz

--9

SELECT biura.biuronr 
FROM biura 
WHERE not exists (SELECT * FROM nieruchomosci WHERE nieruchomosci.biuroNr = biura.biuroNr)

--10a

SELECT DISTINCT 
	(SELECT COUNT(personel.imie) FROM personel WHERE personel.plec = 'K') AS panie, 
	(SELECT COUNT(personel.imie) FROM personel WHERE personel.plec = 'M') AS panowie 

--10b

SELECT biuronr,
	(SELECT COUNT(personel.imie) FROM personel WHERE plec = 'K' AND biuroNr=biura.biuroNr) AS panie, 
	(SELECT COUNT(personel.imie) FROM personel WHERE plec = 'M' AND biuroNr=biura.biuroNr) AS panowie 
FROM biura

--10c

SELECT DISTINCT miasto,
	(SELECT COUNT(personel.imie) FROM personel, biura AS biura2 WHERE personel.plec = 'K' AND biura.miasto=biura2.miasto AND personel.biuroNr=biura2.biuroNr) AS panie, 
	(SELECT COUNT(personel.imie) FROM personel, biura AS biura2 WHERE personel.plec = 'M' AND biura.miasto=biura2.miasto AND personel.biuroNr=biura2.biuroNr) AS panowie 
FROM biura

--10d

SELECT DISTINCT stanowisko,
	(SELECT COUNT(personel2.imie) FROM personel AS personel2 WHERE personel2.plec='K' and personel2.stanowisko=personel.stanowisko) AS panie,
	(SELECT COUNT(personel2.imie) FROM personel AS personel2 WHERE personel2.plec='M' and personel2.stanowisko=personel.stanowisko) AS panowie
FROM personel

