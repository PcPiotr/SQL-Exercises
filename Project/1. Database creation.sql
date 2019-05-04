CREATE DATABASE szkola;

USE szkola;
GO

CREATE TABLE Nauczyciele (
  nauczycielID INT IDENTITY(1,1),
  pesel CHAR(11) NOT NULL,
  imie VARCHAR(255) NOT NULL,
  nazwisko VARCHAR(255) NOT NULL,
  plec CHAR(1) NOT NULL,
  CHECK (plec='K' OR plec = 'M'),
  data_urodzenia DATE NOT NULL,
  CHECK ( ABS(DATEDIFF(year, GETDATE(), data_urodzenia)) >= 24 ),
  PRIMARY KEY (nauczycielID)
);

CREATE TABLE Stopnie (
  stopienID INT IDENTITY(1,1),
  nazwa VARCHAR(20) NOT NULL,
  mnoznik DECIMAL(3,2) NOT NULL -- 2 po przecinku: np. 1.25
  PRIMARY KEY (stopienID)
);
CREATE TABLE RodzajeUmowy (
  rodzajID INT IDENTITY(1,1),
  nazwa VARCHAR(40) NOT NULL,
  PRIMARY KEY (rodzajID)
);

CREATE TABLE Umowy (
  umowaID INT IDENTITY(1,1),
  nauczycielID INTEGER NOT NULL,
  stopien INTEGER NOT NULL,
  rodzaj_umowy INTEGER NOT NULL,
  data_rozpoczecia DATE NOT NULL,
  data_zakonczenia DATE NULL,
  pensja_bazowa MONEY NOT NULL,
  PRIMARY KEY (umowaID),
  CONSTRAINT FK_Nauczyciel FOREIGN KEY (nauczycielID)
  REFERENCES Nauczyciele(nauczycielID),
  CONSTRAINT FK_Rodzaj_Umowy FOREIGN KEY (rodzaj_umowy)
  REFERENCES RodzajeUmowy(rodzajID),
  CONSTRAINT FK_Stopien FOREIGN KEY (stopien)
  REFERENCES Stopnie(stopienID)
);

CREATE TABLE Klasy (
  klasaID VARCHAR(7) NOT NULL, -- 20XXYB2
  rok INTEGER NOT NULL, -- 1, 2, 3, 4, 5, 6, ...
  nazwa VARCHAR(5) NOT NULL, -- 3B1, 2C, 1D, ...
  profil VARCHAR(40) NOT NULL,
  wychowawca INTEGER NOT NULL,
  rocznik CHAR(4) NOT NULL, -- 2017; start klasy
  PRIMARY KEY (klasaID),
  CONSTRAINT FK_Wychowawca FOREIGN KEY (wychowawca)
  REFERENCES Nauczyciele(nauczycielID)
);

CREATE TABLE Uczniowie (
  uczenID INT IDENTITY(1,1),
  pesel CHAR(11) NOT NULL,
  imie VARCHAR(255) NOT NULL,
  nazwisko VARCHAR(255) NOT NULL,
  plec CHAR(1) NOT NULL,
  CHECK (plec='K' OR plec = 'M'),
  -- klasaID INTEGER,
  data_urodzenia DATE NOT NULL,
  CHECK ( ABS(DATEDIFF(year, GETDATE(), data_urodzenia)) >= 6 ),
  data_rozpoczecia_nauki DATE NOT NULL,
  data_zakonczenia_nauki DATE NULL,
  PRIMARY KEY (uczenID)-- ,
  -- CONSTRAINT FK_Klasa FOREIGN KEY (klasaID)
  -- REFERENCES Klasy(klasaID)
);

CREATE TABLE KlasyUczniow (
  klasaUczniaID INT IDENTITY(1,1),
  klasaID VARCHAR(7) NOT NULL,
  uczenID INTEGER NOT NULL,
  PRIMARY KEY (klasaUczniaID),
  CONSTRAINT FK_KlasaU FOREIGN KEY (klasaID)
  REFERENCES Klasy(klasaID),
  CONSTRAINT FK_UczenK FOREIGN KEY (uczenID)
  REFERENCES Uczniowie(uczenID)
);

CREATE TABLE Przedmioty (
  przedmiotID INT IDENTITY(1,1),
  nazwa VARCHAR(255) NOT NULL,
  PRIMARY KEY (przedmiotID)
);

CREATE TABLE Uczy (
  uczyID INT IDENTITY(1,1),
  nauczycielID INTEGER NOT NULL,
  przedmiotID INTEGER NOT NULL,
  data_rozpoczecia DATE NOT NULL,
  PRIMARY KEY (uczyID),
  CONSTRAINT FK_Nauczyciel_Przedmiotu FOREIGN KEY (nauczycielID)
  REFERENCES Nauczyciele(nauczycielID),
  CONSTRAINT FK_Przedmiot FOREIGN KEY (przedmiotID)
  REFERENCES Przedmioty(przedmiotID)
);

CREATE TABLE Oceny (
  ocenaID INT IDENTITY(1,1),
  uczenID INTEGER NOT NULL,
  przedmiotID INTEGER NOT NULL,
  ocena INTEGER NOT NULL,
  CHECK (ocena>0 AND ocena<7),
  waga DECIMAL NOT NULL,
  data_wystawienia DATE NOT NULL,
  nazwa VARCHAR(60) NOT NULL, -- temat kartkówki, itp.
  oceniajacy INTEGER NOT NULL,
  PRIMARY KEY (ocenaID),
  CONSTRAINT FK_Uczen FOREIGN KEY (uczenID)
  REFERENCES Uczniowie(uczenID),
  CONSTRAINT FK_Ocena_z_Przedmiotu FOREIGN KEY (przedmiotID)
  REFERENCES Przedmioty(przedmiotID),
  CONSTRAINT FK_Oceniajacy FOREIGN KEY (oceniajacy)
  REFERENCES Nauczyciele(nauczycielID)
);

CREATE TABLE KlasaPrzedmiotNauczyciel (
  kpnID INT IDENTITY(1,1),
  klasaID VARCHAR(7) NOT NULL,
  nauczycielID INTEGER NOT NULL,
  przedmiotID INTEGER NOT NULL,
  PRIMARY KEY (kpnID),
  CONSTRAINT FK_KlasaPN FOREIGN KEY (klasaID)
  REFERENCES Klasy(klasaID),
  CONSTRAINT FK_NauczycielKP FOREIGN KEY (nauczycielID)
  REFERENCES Nauczyciele(nauczycielID),
  CONSTRAINT FK_PrzedmiotKN FOREIGN KEY (przedmiotID)
  REFERENCES Przedmioty(przedmiotID)
);

-- CREATE TABLE SkalaOcen (
--   skalaID INT IDENTITY(1,1),
--   ocena INTEGER,
--   ocena_slowna VARCHAR(30),
--   PRIMARY KEY (skalaID)
-- );