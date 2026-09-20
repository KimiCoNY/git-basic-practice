-- 1. Tạo cơ sở dữ liệu QuanLyBanHang
CREATE DATABASE IF NOT EXISTS QuanLyBanHang;
USE QuanLyBanHang;

-- 2. Tạo bảng Customer (Khách hàng)
CREATE TABLE Customer (
    cID INT AUTO_INCREMENT PRIMARY KEY,
    cName VARCHAR(25) NOT NULL,
    cAge TINYINT
);

-- 3. Tạo bảng `Order` (Hóa đơn mua hàng)
-- Lưu ý: 'Order' là từ khóa hạn chế trong SQL nên cần đặt trong dấu backtick ``
CREATE TABLE `Order` (
    oID INT AUTO_INCREMENT PRIMARY KEY,
    cID INT NOT NULL,
    oDate DATETIME NOT NULL,
    oTotalPrice INT,
    CONSTRAINT fk_order_customer FOREIGN KEY (cID) REFERENCES Customer(cID)
);

-- 4. Tạo bảng Product (Sản phẩm)
CREATE TABLE Product (
    pID INT AUTO_INCREMENT PRIMARY KEY,
    pName VARCHAR(25) NOT NULL,
    pPrice INT NOT NULL
);

-- 5. Tạo bảng OrderDetail (Chi tiết hóa đơn - Bảng trung gian n - n giữa Order và Product)
CREATE TABLE OrderDetail (
    oID INT NOT NULL,
    pID INT NOT NULL,
    odQTY INT NOT NULL,
    PRIMARY KEY (oID, pID),
    CONSTRAINT fk_orderdetail_order FOREIGN KEY (oID) REFERENCES `Order`(oID),
    CONSTRAINT fk_orderdetail_product FOREIGN KEY (pID) REFERENCES Product(pID)
);
