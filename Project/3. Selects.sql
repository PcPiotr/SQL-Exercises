--1 Uczniowie starsi niż 14 lat
SELECT *
  FROM Uczniowie u
  WHERE
    YEAR(GETDATE()) - YEAR(u.data_urodzenia) > 14;

--2 Wszyscy nauczyciele klasy K
SELECT DISTINCT  Nauczyciele.imie, Nauczyciele.nazwisko
  FROM Klasy, Nauczyciele , KlasaPrzedmiotNauczyciel 
  WHERE
    Klasy.klasaID = KlasaPrzedmiotNauczyciel .klasaID
    AND
    Nauczyciele.nauczycielID = KlasaPrzedmiotNauczyciel .nauczycielID
    AND
    Klasy.klasaID = '2015A3';

--3 Wszystkie klasy do których należał uczeń o peselu P='06221233609'
SELECT DISTINCT k.*
  FROM Uczniowie u, Klasy k, KlasyUczniow ku
  WHERE
    u.uczenID = ku.uczenID
    AND
    k.klasaID = ku.klasaID
    AND
    u.pesel = '06221233609';

--4 Nauczyciele i  uczeniowie
SELECT n.imie, n.nazwisko
  FROM Nauczyciele n
  WHERE plec = 'M'
UNION ALL
SELECT u.imie, u.nazwisko
  FROM Uczniowie u
  WHERE plec = 'M';

--5 Wszystkie klasy uczone przez nauczyciela o id=3
SELECT DISTINCT k.*
  FROM Klasy k, Nauczyciele n, KlasaPrzedmiotNauczyciel kpn
  WHERE
    k.klasaID = kpn.klasaID
    AND
    n.nauczycielID = kpn.nauczycielID
    AND
    n.nauczycielID = 3;

--6 Uczniowie i nauczyciele z imieniem 'Zygfryd'
SELECT u.imie, u.nazwisko, u.data_urodzenia
  FROM Uczniowie u
  WHERE u.imie = 'Zygfryd'
UNION ALL
SELECT n.imie, n.nazwisko, n.data_urodzenia
  FROM Nauczyciele n
  WHERE n.imie = 'Zygfryd';

 --7 Nauczyciele powyżej 60 roku życia
 SELECT n.imie, n.nazwisko, n.data_urodzenia
 FROM Nauczyciele n
 WHERE YEAR(GETDATE()) - YEAR(n.data_urodzenia) > 60;

 --8 Nauczyciele uczący chemii
 SELECT n.imie, n.nazwisko, p.nazwa
 FROM Nauczyciele n, Przedmioty p, Uczy u
 WHERE u.nauczycielID=n.nauczycielID
 AND u.przedmiotID=p.przedmiotID
 AND p.nazwa='Chemia';

 --9 liczba nauczycieli na danym kontrakcie
select count(*) as ile
from Nauczyciele, Umowy, RodzajeUmowy
where Nauczyciele.nauczycielID = Umowy.nauczycielID AND
    Umowy.rodzaj_umowy = RodzajeUmowy.rodzajID AND
    RodzajeUmowy.nazwa = 'na czas określony'

--10 lista nauczycieli o danym stopniu
select imie, nazwisko 
from Nauczyciele, stopnie, umowy
where Nauczyciele.nauczycielID = umowy.nauczycielID AND
      umowy.stopien = stopnie.stopienID AND
      stopnie.nazwa = 'dyplomowany'

--11 lista nauczycieli co przestala uczyc
select imie, nazwisko
from Nauczyciele, Umowy
where Nauczyciele.nauczycielID = Umowy.nauczycielID AND
      umowy.data_zakonczenia is not null

--12 nauczyciele którzy uczą przedmiotu krócej niż 5 lat
 SELECT DISTINCT n.imie, n.nazwisko
 FROM Nauczyciele n, Przedmioty p, Uczy u
 WHERE YEAR(GETDATE()) - YEAR(U.data_rozpoczecia) < 5
 AND u.nauczycielID=n.nauczycielID
 AND u.przedmiotID=p.przedmiotID

--13 Średnie ocen uczniów z języka angielskiego
SELECT DISTINCT u.imie, u.nazwisko, AVG(o.ocena) AS srednia_ocen
  FROM Oceny o, Uczniowie u, Przedmioty p
  WHERE
    o.uczenID = u.uczenID
    AND
    o.przedmiotID = p.przedmiotID
    AND
    p.nazwa = 'Język angielski'
GROUP BY u.imie, u.nazwisko;

 --14 uczeniowie którzy mają 5 z Polskiego
 SELECT DISTINCT Uczniowie.imie, Uczniowie.nazwisko, Przedmioty.nazwa
 FROM Uczniowie, Oceny, Przedmioty
 WHERE Oceny.uczenID=Uczniowie.uczenID
 and Oceny.przedmiotID=Przedmioty.przedmiotID
 and Przedmioty.nazwa='Polski'
 and Oceny.ocena = 5;

--15 Podopieczni danego wychowawcy
 SELECT DISTINCT Uczniowie.imie, Uczniowie.nazwisko
 FROM Uczniowie, Klasy, KlasyUczniow
 WHERE Klasy.wychowawca = 28 AND
       Klasy.klasaID = KlasyUczniow.klasaID AND 
       KlasyUczniow.uczenID = Uczniowie.uczenID













