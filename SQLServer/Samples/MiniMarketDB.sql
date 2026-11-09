/* =====================================================================
   MiniMarketDB - "Veriden Geleceğe: Modern Veritabanı Teknolojileri"
   Eğitim betiği (SQL Server 2019+ / Developer edition / LocalDB)

   Azure SQL Database notu: Bu betik Azure SQL Database'de baştan sona
   çalışmaz. Orada USE ile veritabanı değiştirilemez (yeni bağlantı
   gerekir), veritabanı DROP/CREATE ile değil portal veya CLI ile
   oluşturulur ve yedekler hizmet tarafından otomatik alınır. Azure'da
   denemek için: veritabanını portaldan oluşturun, betiğin 1. bölümündeki
   USE/DROP/CREATE DATABASE satırlarını ve 6. bölümü atlayın.

   Veri seti: 10.000 müşteri, 1.000 ürün, 100.000 sipariş, 250.000 satır
   Veriler deterministik üretilir: betik her çalıştırıldığında aynı sonuç.
   Bölümler:
     1. Şema            4. Hatalı JOIN
     2. Örnek veri      5. Performans (Index + Execution Plan)
     3. Sorgu + stok    6. Backup / Restore örnekleri (yorum satırı)
   ===================================================================== */

/* ---------- 1. ŞEMA ---------- */
USE master;
GO
IF DB_ID('MiniMarketDB') IS NOT NULL
BEGIN
    ALTER DATABASE MiniMarketDB SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
    DROP DATABASE MiniMarketDB;
END
GO
CREATE DATABASE MiniMarketDB;
GO
USE MiniMarketDB;
GO

CREATE TABLE dbo.Categories (
    CategoryId   int IDENTITY PRIMARY KEY,
    Name         nvarchar(50) NOT NULL
);

CREATE TABLE dbo.Customers (
    CustomerId   int IDENTITY PRIMARY KEY,
    FullName     nvarchar(100) NOT NULL,
    Email        nvarchar(200) NOT NULL UNIQUE,
    City         nvarchar(50)  NOT NULL,
    CreatedAt    datetime2(0)  NOT NULL
);

CREATE TABLE dbo.Products (
    ProductId     int IDENTITY PRIMARY KEY,
    CategoryId    int NOT NULL REFERENCES dbo.Categories(CategoryId),
    Name          nvarchar(100) NOT NULL,
    Price         decimal(10,2) NOT NULL CHECK (Price >= 0),
    StockQuantity int NOT NULL CHECK (StockQuantity >= 0)   -- güvenlik ağı
);

CREATE TABLE dbo.Orders (
    OrderId      int IDENTITY PRIMARY KEY,                  -- clustered index
    CustomerId   int NOT NULL REFERENCES dbo.Customers(CustomerId),
    OrderDate    datetime2(0) NOT NULL,
    Status       varchar(20) NOT NULL
                 CHECK (Status IN ('Completed', 'Cancelled', 'Pending'))
);

CREATE TABLE dbo.OrderItems (
    OrderItemId  int IDENTITY PRIMARY KEY,
    OrderId      int NOT NULL REFERENCES dbo.Orders(OrderId),
    ProductId    int NOT NULL REFERENCES dbo.Products(ProductId),
    Quantity     int NOT NULL CHECK (Quantity > 0),
    UnitPrice    decimal(10,2) NOT NULL      -- satış anındaki fiyat
);

-- Raporlara sonradan eklenen tablo (Hatalı JOIN örneği için)
CREATE TABLE dbo.Promotions (
    PromotionId  int IDENTITY PRIMARY KEY,
    ProductId    int NOT NULL REFERENCES dbo.Products(ProductId),
    Name         nvarchar(100) NOT NULL,
    DiscountRate decimal(4,2) NOT NULL
);
GO

/* ---------- 2. ÖRNEK VERİ ---------- */
SET NOCOUNT ON;

INSERT dbo.Categories (Name) VALUES
 (N'Elektronik'), (N'Gıda'), (N'Kırtasiye'), (N'Ev ve Yaşam'),
 (N'Kişisel Bakım'), (N'Oyuncak'), (N'Spor'), (N'İçecek');

;WITH n AS (
    SELECT TOP (100000) ROW_NUMBER() OVER (ORDER BY (SELECT NULL)) AS i
    FROM sys.all_objects a CROSS JOIN sys.all_objects b
)
SELECT i INTO #n FROM n;

INSERT dbo.Customers (FullName, Email, City, CreatedAt)
SELECT CONCAT(N'Müşteri ', i),
       CONCAT('musteri', i, '@ornek.com'),
       CHOOSE(1 + i % 5, N'İstanbul', N'Ankara', N'İzmir', N'Bursa', N'Antalya'),
       DATEADD(DAY, -(i % 1500), '2025-01-01')
FROM #n WHERE i <= 10000;

INSERT dbo.Products (CategoryId, Name, Price, StockQuantity)
SELECT 1 + i % 8,
       CONCAT(N'Ürün ', i),
       CAST(5 + (i * 37) % 2000 AS decimal(10,2)),
       20 + (i * 13) % 300
FROM #n WHERE i <= 1000;

-- Deterministik "rastgele" sayı: HASHBYTES ile 0..16.777.215 arası
-- Siparişler: ilk 200 müşteri (%2) siparişlerin %30'unu veriyor,
-- %10'u Kasım kampanya döneminde, %5 iptal, %2 beklemede.
INSERT dbo.Orders (CustomerId, OrderDate, Status)
SELECT CASE WHEN h.r1 % 10 < 3 THEN 1 + h.r2 % 200
            ELSE 1 + h.r2 % 10000 END,
       CASE WHEN h.r1 % 10 = 9
            THEN DATEADD(MINUTE, h.r3 % (30 * 1440), '2025-11-01')
            ELSE DATEADD(MINUTE, h.r3 % (670 * 1440), '2025-01-01') END,
       CASE WHEN i % 20 = 0 THEN 'Cancelled'
            WHEN i % 50 = 1 THEN 'Pending'
            ELSE 'Completed' END
FROM #n
CROSS APPLY (SELECT
    CAST(CAST(HASHBYTES('MD5', CONCAT('a', i)) AS binary(3)) AS int) AS r1,
    CAST(CAST(HASHBYTES('MD5', CONCAT('b', i)) AS binary(3)) AS int) AS r2,
    CAST(CAST(HASHBYTES('MD5', CONCAT('c', i)) AS binary(3)) AS int) AS r3) AS h
ORDER BY h.r3;   -- siparişler tarih sırasına yakın eklenir

-- Her siparişte 1-4 satır (ortalama 2,5) => 250.000 satır.
-- İlk 50 ürün "popüler": satırların yaklaşık dörtte biri bunlardan.
INSERT dbo.OrderItems (OrderId, ProductId, Quantity, UnitPrice)
SELECT o.OrderId, p.ProductId, 1 + h.r % 3, p.Price
FROM dbo.Orders AS o
CROSS JOIN (VALUES (1), (2), (3), (4)) AS k(k)
CROSS APPLY (SELECT CAST(CAST(HASHBYTES('MD5',
        CONCAT('d', o.OrderId, '-', k.k)) AS binary(3)) AS int) AS r) AS h
JOIN dbo.Products AS p
  ON p.ProductId = CASE WHEN h.r % 4 = 0
                        THEN 1 + (h.r / 4) % 50
                        ELSE 1 + (h.r / 4) % 1000 END
WHERE k.k <= 1 + o.OrderId % 4;

-- Popüler ürünlerde iki promosyon, sonraki 250 üründe bir promosyon
INSERT dbo.Promotions (ProductId, Name, DiscountRate)
SELECT ProductId, N'Hafta sonu indirimi', 0.10 FROM dbo.Products WHERE ProductId <= 300
UNION ALL
SELECT ProductId, N'Sepette ek indirim', 0.05 FROM dbo.Products WHERE ProductId <= 50;

DROP TABLE #n;
GO

SELECT 'Customers' AS TableName, COUNT(*) AS RowCnt FROM dbo.Customers UNION ALL
SELECT 'Products',  COUNT(*) FROM dbo.Products  UNION ALL
SELECT 'Orders',    COUNT(*) FROM dbo.Orders    UNION ALL
SELECT 'OrderItems',COUNT(*) FROM dbo.OrderItems UNION ALL
SELECT 'Promotions',COUNT(*) FROM dbo.Promotions;
GO

/* ---------- 3a. SATIŞ ANALİZİ: En çok satan 5 ürün ---------- */
SELECT TOP (5)
    p.Name,
    SUM(oi.Quantity) AS TotalSold
FROM dbo.Orders AS o
JOIN dbo.OrderItems AS oi ON oi.OrderId = o.OrderId
JOIN dbo.Products   AS p  ON p.ProductId = oi.ProductId
WHERE o.Status = 'Completed'
GROUP BY p.ProductId, p.Name
ORDER BY TotalSold DESC;
GO

/* ---------- 3b. STOK: Son ürünü iki kişi alırsa? ----------
   YANLIŞ desen (iki ayrı adım):
     SELECT @stok = StockQuantity FROM dbo.Products WHERE ProductId = @p;
     IF @stok >= 1 UPDATE dbo.Products SET StockQuantity = @stok - 1 ...
   İki oturum aynı anda okursa ikisi de 1 görür, ikisi de 0 yazar:
   iki sipariş, tek ürün (lost update).

   DOĞRU desen: kontrol ve azaltma TEK atomik UPDATE içinde.          */
CREATE OR ALTER PROCEDURE dbo.PlaceOrder
    @CustomerId int,
    @ProductId  int,
    @Quantity   int
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;            -- hata olursa transaction tamamen geri alınır

    BEGIN TRAN;
        UPDATE dbo.Products
           SET StockQuantity = StockQuantity - @Quantity
         WHERE ProductId = @ProductId
           AND StockQuantity >= @Quantity;      -- koşul + azaltma tek adımda

        IF @@ROWCOUNT = 0                       -- stok yetmedi
        BEGIN
            ROLLBACK;
            THROW 50001, N'Yetersiz stok', 1;
        END

        DECLARE @OrderId int;
        INSERT dbo.Orders (CustomerId, OrderDate, Status)
        VALUES (@CustomerId, SYSDATETIME(), 'Completed');
        SET @OrderId = SCOPE_IDENTITY();

        INSERT dbo.OrderItems (OrderId, ProductId, Quantity, UnitPrice)
        SELECT @OrderId, ProductId, @Quantity, Price
        FROM dbo.Products WHERE ProductId = @ProductId;
    COMMIT;
END
GO
-- Deneme: stoğu 1'e çekip iki SSMS penceresinden aynı anda çalıştırın.
-- UPDATE dbo.Products SET StockQuantity = 1 WHERE ProductId = 7;
-- EXEC dbo.PlaceOrder @CustomerId = 1, @ProductId = 7, @Quantity = 1;

/* ---------- 4. HATALI JOIN: doğru görünen yanlış rapor ---------- */
-- Yanlış: Promotions 1:N olduğu için satırlar çoğalır
SELECT SUM(oi.Quantity * oi.UnitPrice) AS Revenue_Wrong
FROM dbo.Orders AS o
JOIN dbo.OrderItems AS oi ON oi.OrderId = o.OrderId
LEFT JOIN dbo.Promotions AS pr ON pr.ProductId = oi.ProductId
WHERE o.Status = 'Completed';

-- Doğru: önce satışı topla, promosyon bilgisini ayrıca bağla
SELECT SUM(oi.Quantity * oi.UnitPrice) AS Revenue_Correct
FROM dbo.Orders AS o
JOIN dbo.OrderItems AS oi ON oi.OrderId = o.OrderId
WHERE o.Status = 'Completed';

-- Kontrol: JOIN sonrası satır sayısı arttı mı?
SELECT
  (SELECT COUNT(*) FROM dbo.OrderItems) AS ItemRows,
  (SELECT COUNT(*) FROM dbo.OrderItems AS oi
     LEFT JOIN dbo.Promotions AS pr ON pr.ProductId = oi.ProductId) AS RowsAfterJoin;
GO

/* ---------- 5. PERFORMANS ----------
   SSMS'te Ctrl+M (Include Actual Execution Plan) açın, sonra çalıştırın.
   Messages sekmesinde "logical reads" değerlerini karşılaştırın.        */
SET STATISTICS IO, TIME ON;

-- Müşteri 42 sık sipariş veren bir müşteri: 5 Kasım 2025'ten bu yana 87 sipariş.
-- Eğitim verisi sabittir (Ocak 2025 - Kasım 2026); tarih filtresi bu veriye
-- göre seçildi, sonuç betiğin çalıştırıldığı günden bağımsızdır.
-- Örnek ölçüm (SQL Server 2019 LocalDB): 447 / ≈350 / 3 logical reads.
-- Key Lookup değeri index her oluşturulduğunda birkaç sayfa oynar (346–349);
-- 447 ve 3 sabittir.

-- Bölüm tekrar çalıştırılabilsin diye önce varsa index'i kaldır
DROP INDEX IF EXISTS IX_Orders_CustomerId_OrderDate ON dbo.Orders;

-- 5a. Index yok: Clustered Index Scan + Sort beklenir
SELECT OrderId, OrderDate, Status
FROM dbo.Orders
WHERE CustomerId = 42 AND OrderDate >= '2025-11-05'
ORDER BY OrderDate DESC;

-- 5b. Index var ama Status index'te değil: Index Seek + Key Lookup
CREATE INDEX IX_Orders_CustomerId_OrderDate
    ON dbo.Orders (CustomerId, OrderDate);

SELECT OrderId, OrderDate, Status
FROM dbo.Orders
WHERE CustomerId = 42 AND OrderDate >= '2025-11-05'
ORDER BY OrderDate DESC;

-- 5c. INCLUDE ile kapsayan index: yalnızca Index Seek
DROP INDEX IX_Orders_CustomerId_OrderDate ON dbo.Orders;
CREATE INDEX IX_Orders_CustomerId_OrderDate
    ON dbo.Orders (CustomerId, OrderDate) INCLUDE (Status);

SELECT OrderId, OrderDate, Status
FROM dbo.Orders
WHERE CustomerId = 42 AND OrderDate >= '2025-11-05'
ORDER BY OrderDate DESC;

SET STATISTICS IO, TIME OFF;
GO

/* ---------- 6. BACKUP / RESTORE (örnek, yorum satırı) ----------
   Yol ve dosya adlarını kendi ortamınıza göre değiştirin.

ALTER DATABASE MiniMarketDB SET RECOVERY FULL;

BACKUP DATABASE MiniMarketDB TO DISK = N'C:\Backup\MiniMarket_full.bak'  WITH CHECKSUM, INIT;  -- Pazar
BACKUP DATABASE MiniMarketDB TO DISK = N'C:\Backup\MiniMarket_diff.bak'  WITH DIFFERENTIAL, CHECKSUM, INIT; -- Pazartesi
BACKUP LOG      MiniMarketDB TO DISK = N'C:\Backup\MiniMarket_log1.trn'  WITH CHECKSUM, INIT;  -- 15 dk'da bir

-- Arıza anında: önce tail-log (henüz yedeklenmemiş son log parçası).
-- Normal durum (veritabanı çevrim içi):
BACKUP LOG MiniMarketDB TO DISK = N'C:\Backup\MiniMarket_tail.trn' WITH NORECOVERY;

-- YALNIZCA veritabanı hasarlıysa (veri dosyası bozuk, log dosyası sağlam):
-- BACKUP LOG MiniMarketDB TO DISK = N'C:\Backup\MiniMarket_tail.trn'
--     WITH CONTINUE_AFTER_ERROR;
-- Bu durumda yedek eksik meta veri içerebilir; sonuç dikkatle kontrol edilmeli.

-- Geri yükleme sırası: Full -> son Differential -> sonraki Log'lar -> tail-log
-- (Tail-log alındığı için REPLACE gerekmez; REPLACE bu güvenlik kontrolünü atlar.)
RESTORE DATABASE MiniMarketDB FROM DISK = N'C:\Backup\MiniMarket_full.bak' WITH NORECOVERY;
RESTORE DATABASE MiniMarketDB FROM DISK = N'C:\Backup\MiniMarket_diff.bak' WITH NORECOVERY;
RESTORE LOG      MiniMarketDB FROM DISK = N'C:\Backup\MiniMarket_log1.trn' WITH NORECOVERY;
RESTORE LOG      MiniMarketDB FROM DISK = N'C:\Backup\MiniMarket_tail.trn' WITH RECOVERY;

-- Yanlışlıkla silme: silmeden hemen önceki ana dön (point-in-time)
-- RESTORE LOG ... WITH STOPAT = '2026-11-10T14:36:00', RECOVERY;
*/
