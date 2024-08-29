-- PostgreSQL dump

BEGIN;

-- Database: projektbd

-- Functions
CREATE OR REPLACE FUNCTION calculate_discount(product_id INT, discount_percentage NUMERIC(5,2))
RETURNS NUMERIC(10,2) AS $$
DECLARE
    original_price NUMERIC(10, 2);
    discounted_price NUMERIC(10, 2);
BEGIN
    SELECT cena INTO original_price FROM produkty WHERE idProduktu = product_id;
    discounted_price = original_price - (original_price * discount_percentage / 100);
    RETURN discounted_price;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION get_total_sales(store_id INT)
RETURNS NUMERIC(10,2) AS $$
DECLARE
    total_sales NUMERIC(10, 2);
BEGIN
    SELECT SUM(sp.ilosc * p.cena) INTO total_sales
    FROM sklepy_produktow sp
    JOIN produkty p ON sp.idProduktu = p.idProduktu
    WHERE sp.idSklepu = store_id;
    RETURN total_sales;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION oblicz_wartosc_sklepu(id_sklepu INT)
RETURNS NUMERIC(10,2) AS $$
DECLARE
    total_value NUMERIC(10, 2);
BEGIN
    SELECT SUM(p.cena * sp.ilosc) INTO total_value
    FROM produkty p
    JOIN sklepy_produktow sp ON p.idProduktu = sp.idProduktu
    WHERE sp.idSklepu = id_sklepu;
    RETURN total_value;
END;
$$ LANGUAGE plpgsql;

-- Tables
CREATE TABLE produkty (
  idProduktu SERIAL PRIMARY KEY,
  nazwa VARCHAR(255) NOT NULL,
  cena NUMERIC(10,2),
  stan_magazynowy INT,
  kategoria VARCHAR(100)
);

INSERT INTO produkty (idProduktu, nazwa, cena, stan_magazynowy, kategoria) VALUES
(1, 'Laptop', 1200.00, 33, 'Electronics'),
(2, 'Smartwatch', 400.00, 68, 'Wearables'),
(3, 'Coffee Maker', 85.00, 117, 'Home Appliances'),
(4, 'Wireless Mouse', 25.00, 153, 'Accessories'),
(5, 'Gaming Chair', 350.00, 15, 'Furniture'),
(6, 'Camera', 0.00, 5, 'Photography');

CREATE TABLE produkty_log (
  id SERIAL PRIMARY KEY,
  idProduktu INT REFERENCES produkty(idProduktu),
  old_cena NUMERIC(10,2),
  new_cena NUMERIC(10,2),
  changed_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

INSERT INTO produkty_log (id, idProduktu, old_cena, new_cena, changed_at) VALUES
(1, 1, 1100.00, 1200.00, '2024-01-15 09:00:00'),
(2, 2, 280.00, 300.00, '2024-02-20 11:00:00'),
(3, 3, 80.00, 85.00, '2024-03-25 13:30:00'),
(4, 4, 20.00, 25.00, '2024-04-30 14:45:00'),
(5, 5, 340.00, 350.00, '2024-05-05 16:15:00'),
(6, 1, 1200.00, 1200.00, '2024-05-21 10:49:46'),
(7, 2, 300.00, 300.00, '2024-05-21 10:49:46'),
(8, 3, 85.00, 85.00, '2024-05-21 10:49:46'),
(9, 4, 25.00, 25.00, '2024-05-21 10:49:46'),
(10, 5, 350.00, 350.00, '2024-05-21 10:49:46'),
(11, 1, 1200.00, 1200.00, '2024-05-21 10:49:46'),
(12, 2, 300.00, 300.00, '2024-05-21 10:49:46'),
(13, 3, 85.00, 85.00, '2024-05-21 10:49:47'),
(14, 4, 25.00, 25.00, '2024-05-21 10:49:47'),
(15, 5, 350.00, 350.00, '2024-05-21 10:49:47'),
(16, 2, 300.00, 400.00, '2024-06-07 11:59:09'),
(17, 6, 0.00, 0.00, '2024-06-07 12:15:27');

CREATE TABLE sklepy (
  idSklepu SERIAL PRIMARY KEY,
  nazwa VARCHAR(255) NOT NULL,
  adres VARCHAR(255),
  telefon VARCHAR(20),
  email VARCHAR(100)
);

INSERT INTO sklepy (idSklepu, nazwa, adres, telefon, email) VALUES
(1, 'M-Market', 'Wrocław', '123-456-7890', 'info@mmarket.com'),
(2, 'H&N', 'Malbork', '234-567-8901', 'contact@handn.com'),
(3, 'fauchan', 'Krakow', '345-678-9012', 'support@fauchan.com'),
(4, 'Xpress', 'Warsaw', '456-789-0123', 'sales@xpress.com'),
(5, 'NewBoy', 'Gdańsk', '567-890-1234', 'help@newboy.com');

CREATE TABLE sklepy_produktow (
  idSklepu INT REFERENCES sklepy(idSklepu),
  idProduktu INT REFERENCES produkty(idProduktu),
  ilosc INT,
  PRIMARY KEY (idSklepu, idProduktu)
);

INSERT INTO sklepy_produktow (idSklepu, idProduktu, ilosc) VALUES
(1, 1, 10),
(1, 2, 20),
(2, 3, 15),
(2, 4, 25),
(3, 1, 7),
(3, 5, 5),
(4, 2, 12),
(4, 3, 18),
(5, 4, 22),
(5, 5, 10),
(5, 6, 5);

-- Triggers
CREATE OR REPLACE FUNCTION aktualizuj_stan_magazynowy()
RETURNS TRIGGER AS $$
BEGIN
    UPDATE produkty
    SET stan_magazynowy = stan_magazynowy - NEW.ilosc
    WHERE idProduktu = NEW.idProduktu;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER aktualizuj_stan_magazynowy
AFTER INSERT ON sklepy_produktow
FOR EACH ROW
EXECUTE FUNCTION aktualizuj_stan_magazynowy();

CREATE OR REPLACE FUNCTION after_update_produkty()
RETURNS TRIGGER AS $$
BEGIN
    INSERT INTO produkty_log (idProduktu, old_cena, new_cena)
    VALUES (OLD.idProduktu, OLD.cena, NEW.cena);
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER after_update_produkty
AFTER UPDATE ON produkty
FOR EACH ROW
EXECUTE FUNCTION after_update_produkty();

CREATE OR REPLACE FUNCTION before_insert_produkty()
RETURNS TRIGGER AS $$
BEGIN
    IF NEW.cena < 0 THEN
        NEW.cena = 0;
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER before_insert_produkty
BEFORE INSERT ON produkty
FOR EACH ROW
EXECUTE FUNCTION before_insert_produkty();

-- Views
CREATE OR REPLACE VIEW view_product_discount AS
SELECT 
    p.idProduktu AS product_id,
    p.nazwa AS product_name,
    p.cena AS original_price,
    calculate_discount(p.idProduktu, 10) AS discounted_price
FROM 
    produkty p;

CREATE OR REPLACE VIEW view_store_inventory AS
SELECT 
    s.idSklepu AS store_id,
    s.nazwa AS store_name,
    p.idProduktu AS product_id,
    p.nazwa AS product_name,
    sp.ilosc AS quantity
FROM 
    sklepy s
JOIN 
    sklepy_produktow sp ON s.idSklepu = sp.idSklepu
JOIN 
    produkty p ON sp.idProduktu = p.idProduktu;

CREATE OR REPLACE VIEW view_total_sales_by_store AS
SELECT 
    s.idSklepu AS store_id,
    s.nazwa AS store_name,
    get_total_sales(s.idSklepu) AS total_sales
FROM 
    sklepy s;

COMMIT;
