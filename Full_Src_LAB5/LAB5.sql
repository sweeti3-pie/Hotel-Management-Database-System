CREATE DATABASE HotelManagement_Group8_1;
GO
USE HotelManagement_Group8_1;
GO



-- Bảng Role (Vai trò)
CREATE TABLE Role (
    RoleID INT PRIMARY KEY IDENTITY(1,1),
    PositionName NVARCHAR(100) NOT NULL UNIQUE, 
    Salary DECIMAL(18, 2) NOT NULL CHECK (Salary > 0) 
);

-- Bảng Employee (Nhân viên) 
CREATE TABLE Employee (
    EmployeeID INT PRIMARY KEY IDENTITY(1,1),
    FullName NVARCHAR(255) NOT NULL,
    Phone VARCHAR(15) NOT NULL UNIQUE,
    Email VARCHAR(100) UNIQUE, 
    RoleID INT NOT NULL,
    FOREIGN KEY (RoleID) REFERENCES Role(RoleID) 
);

-- Bảng Payroll (Tiền lương)
CREATE TABLE Payroll (
    PayrollID INT PRIMARY KEY IDENTITY(1,1),
    EmployeeID INT NOT NULL,
    PayDate DATE DEFAULT GETDATE(),
    BaseSalary DECIMAL(18,2) NOT NULL CHECK (BaseSalary > 0),
    Bonus DECIMAL (18,2) DEFAULT 0,
    Deductions DECIMAL(18,2) DEFAULT 0,
    TotalAmount AS (BaseSalary + Bonus - Deductions),
    FOREIGN KEY (EmployeeID) REFERENCES Employee(EmployeeID)
)

-- Bảng Customer (Khách hàng) 
CREATE TABLE Customer (
    CustomerID INT PRIMARY KEY IDENTITY(1,1),
    FullName NVARCHAR(255) NOT NULL,
    IDNumber VARCHAR(20) NOT NULL UNIQUE, 
    Email VARCHAR(100) UNIQUE, 
    Phone VARCHAR(15) UNIQUE, 
    DateOfBirth DATE CHECK (DateOfBirth < GETDATE()), 
    Nationality NVARCHAR(50)
);

-- Bảng RoomType (Loại phòng) 
CREATE TABLE RoomType (
    RoomTypeID INT PRIMARY KEY IDENTITY(1,1),
    TypeName NVARCHAR(100) NOT NULL,
    Description NVARCHAR(MAX),
    BasePrice DECIMAL(18, 2) NOT NULL CHECK (BasePrice > 0), 
    MaxGuests INT NOT NULL CHECK (MaxGuests > 0),
    BedType NVARCHAR(50),
    IsSmokingAllowed BIT DEFAULT 0 
);

-- Bảng Room (Phòng) 
CREATE TABLE Room (
    RoomID INT PRIMARY KEY IDENTITY(1,1),
    RoomNumber VARCHAR(10) NOT NULL UNIQUE, 
    Floor INT CHECK (Floor >= 0),
    Status NVARCHAR(50) NOT NULL DEFAULT 'Available',
    IsAccessible BIT,
    RoomTypeID INT NOT NULL,
    FOREIGN KEY (RoomTypeID) REFERENCES RoomType(RoomTypeID)
);

-- Bảng Service (Dịch vụ) 
CREATE TABLE Service (
    ServiceID INT PRIMARY KEY IDENTITY(1,1),
    ServiceName NVARCHAR(100) NOT NULL,
    Description NVARCHAR(MAX),
    Price DECIMAL(18, 2) NOT NULL CHECK (Price >= 0),
    Category NVARCHAR(50),
    DurationMinutes INT CHECK (DurationMinutes >= 0), 
    IsAvailable BIT DEFAULT 1 
);

-- Bảng Facility (Cơ sở vật chất)
CREATE TABLE Facility (
    FacilityID INT PRIMARY KEY IDENTITY(1,1),
    FacilityName NVARCHAR(100) NOT NULL,
    Description NVARCHAR(MAX),
    Category NVARCHAR(50),
    IsComplimentary BIT
);

-- Bảng Booking (Đặt phòng) 
CREATE TABLE Booking (
    BookingID INT PRIMARY KEY IDENTITY(1,1),
    BookingDate DATETIME NOT NULL DEFAULT GETDATE(), 
    CheckinDate DATETIME,
    CheckoutDate DATETIME,
    BookingStatus NVARCHAR(50) DEFAULT 'Pending', 
    NumberOfGuests INT CHECK (NumberOfGuests > 0), 
    CustomerID INT NOT NULL,
    EmployeeID INT NOT NULL,
    CONSTRAINT CHK_StayDuration CHECK (CheckoutDate > CheckinDate), 
    FOREIGN KEY (CustomerID) REFERENCES Customer(CustomerID),
    FOREIGN KEY (EmployeeID) REFERENCES Employee(EmployeeID)
);

-- Tạo Bảng Invoice (Không có chữ UNIQUE ở BookingID)
CREATE TABLE Invoice (
    InvoiceID INT PRIMARY KEY IDENTITY(1,1),
    BookingID INT NULL, 
    DepositAmount DECIMAL(18, 2),
    TotalAmount DECIMAL(18, 2) NOT NULL CHECK (TotalAmount >= 0), 
    PaymentDate DATETIME,
    PaymentMethod NVARCHAR(50),
    FOREIGN KEY (BookingID) REFERENCES Booking(BookingID)
);
GO

-- TẠO FILTERED UNIQUE INDEX (Đây là chốt chặn an toàn!)
CREATE UNIQUE NONCLUSTERED INDEX UQ_Invoice_BookingID 
ON Invoice(BookingID) 
WHERE BookingID IS NOT NULL;
GO

-- Bảng trung gian: Booking_Room 
CREATE TABLE Booking_Room (
    BookingID INT NOT NULL,
    RoomID INT NOT NULL,
    PriceAtTime DECIMAL(18, 2) NOT NULL CHECK (PriceAtTime >= 0), 
    PRIMARY KEY (BookingID, RoomID),
    FOREIGN KEY (BookingID) REFERENCES Booking(BookingID),
    FOREIGN KEY (RoomID) REFERENCES Room(RoomID)
);

-- Bảng trung gian: Booking_Service 
CREATE TABLE Booking_Service (
    BookingID INT NOT NULL,
    ServiceID INT NOT NULL,
    Quantity INT,
    PriceAtTime DECIMAL(18, 2) NOT NULL CHECK (PriceAtTime >= 0), 
    PRIMARY KEY (BookingID, ServiceID),
    FOREIGN KEY (BookingID) REFERENCES Booking(BookingID),
    FOREIGN KEY (ServiceID) REFERENCES Service(ServiceID)
);

-- Bảng trung gian: RoomType_Facility 
CREATE TABLE RoomType_Facility (
    RoomTypeID INT NOT NULL,
    FacilityID INT NOT NULL,
    PRIMARY KEY (RoomTypeID, FacilityID),
    FOREIGN KEY (RoomTypeID) REFERENCES RoomType(RoomTypeID),
    FOREIGN KEY (FacilityID) REFERENCES Facility(FacilityID)
);

-- Bảng trung gian: Room_Facility
CREATE TABLE Room_Facility (
    RoomID INT NOT NULL,
    FacilityID INT NOT NULL,
    PRIMARY KEY (RoomID, FacilityID),
    FOREIGN KEY (RoomID) REFERENCES Room(RoomID),
    FOREIGN KEY (FacilityID) REFERENCES Facility(FacilityID)
);

-- Bảng trung gian: Service_Invoice
CREATE TABLE Service_Invoice (
    ServiceID INT NOT NULL,
    InvoiceID INT NOT NULL,
    Quantity INT,
    PriceAtTime DECIMAL(18, 2) NOT NULL CHECK (PriceAtTime >= 0), 
    PRIMARY KEY (ServiceID, InvoiceID),
    FOREIGN KEY (ServiceID) REFERENCES Service(ServiceID),
    FOREIGN KEY (InvoiceID) REFERENCES Invoice(InvoiceID)
)
GO

-- Chèn 3 Vai trò (Role)
INSERT INTO Role (PositionName, Salary) VALUES 
(N'Quản lý', 20000000), 
(N'Lễ tân', 10000000), 
(N'Nhân viên buồng phòng', 7000000);
GO

-- Chèn 3 Nhân viên (Employee) lấy tên các thành viên trong nhóm 
INSERT INTO Employee (FullName, Phone, Email, RoleID) VALUES 
(N'Nguyễn Thị Hồng Anh', '0901234567', 'honganh@hotel.com', 1),
(N'Nguyễn Thanh Quốc Linh', '0907654321', 'quoclinh@hotel.com', 2),
(N'Lê Văn Tám', '0912345678', 'vantam@hotel.com', 3);
GO

-- Chèn 3 Khách hàng (Customer) lấy tên các thành viên trong nhóm 
INSERT INTO Customer (FullName, IDNumber, Email, Phone, DateOfBirth, Nationality) VALUES 
(N'Mai Xuân Sinh', '079099123456', 'sinh.mx@mail.com', '0981112222', '2000-01-01', N'Việt Nam'),
(N'Thái Hoàng Phát', '079099654321', 'phat.th@mail.com', '0983334444', '1999-05-15', N'Việt Nam'),
(N'Trần Bùi Đạt Thành', '079099987654', 'thanh.tbd@mail.com', '0985556666', '2001-10-10', N'Việt Nam');
GO

-- Chèn 3 Loại phòng (RoomType)
INSERT INTO RoomType (TypeName, Description, BasePrice, MaxGuests, BedType, IsSmokingAllowed) VALUES 
(N'Phòng Tiêu Chuẩn', N'Phòng cơ bản, đầy đủ tiện nghi', 500000, 2, N'Giường Đôi', 0),
(N'Phòng Cao Cấp', N'Phòng rộng, view đẹp', 1200000, 2, N'Giường King', 0),
(N'Phòng Tổng Thống', N'Không gian sang trọng bậc nhất', 5000000, 4, N'2 Giường King', 1);
GO

-- Chèn 3 Phòng (Room)
INSERT INTO Room (RoomNumber, Floor, Status, IsAccessible, RoomTypeID) VALUES 
('101', 1, N'Available', 1, 1),
('202', 2, N'Occupied', 0, 2),
('501', 5, N'Available', 1, 3);
GO
USE HotelManagement_Group8_1;
GO

-- 1. Bảng Role (15 dòng)
INSERT INTO Role (PositionName, Salary) VALUES 
(N'Giám đốc điều hành', 50000000),
(N'Quản lý nhân sự', 25000000),
(N'Kế toán trưởng', 22000000),
(N'Trưởng bộ phận Lễ tân', 18000000),
(N'Giám sát buồng phòng', 15000000),
(N'Bếp trưởng', 30000000),
(N'Nhân viên bảo vệ', 8000000),
(N'Nhân viên hành lý (Bellboy)', 7500000),
(N'Nhân viên IT', 15000000),
(N'Nhân viên Spa', 12000000),
(N'Pha chế (Bartender)', 11000000),
(N'Phục vụ nhà hàng', 8000000),
(N'Tài xế', 10000000),
(N'Nhân viên bảo trì', 9000000),
(N'Nhân viên kinh doanh', 14000000);
GO

-- 2. Bảng Customer (15 dòng)
INSERT INTO Customer (FullName, IDNumber, Email, Phone, DateOfBirth, Nationality) VALUES 
(N'Lê Tấn Phát', '079123450001', 'phat.le@mail.com', '0901000001', '1985-02-20', N'Việt Nam'),
(N'Nguyễn Ánh Tuyết', '079123450002', 'tuyet.na@mail.com', '0901000002', '1992-07-11', N'Việt Nam'),
(N'Trần Minh Khang', '079123450003', 'khang.tm@mail.com', '0901000003', '1988-11-05', N'Việt Nam'),
(N'Phạm Thu Hà', '079123450004', 'ha.pt@mail.com', '0901000004', '1995-09-22', N'Việt Nam'),
(N'Vũ Hải Đăng', '079123450005', 'dang.vh@mail.com', '0901000005', '1990-12-12', N'Việt Nam'),
(N'John Smith', 'US987654321', 'john.s@mail.com', '0901000006', '1980-04-18', N'Mỹ'),
(N'Maria Garcia', 'ES123456789', 'maria.g@mail.com', '0901000007', '1987-08-30', N'Tây Ban Nha'),
(N'Lee Min Ho', 'KR456789123', 'lee.mh@mail.com', '0901000008', '1993-01-25', N'Hàn Quốc'),
(N'Tanaka Ken', 'JP789123456', 'tanaka.k@mail.com', '0901000009', '1975-06-14', N'Nhật Bản'),
(N'Bùi Thị Thanh', '079123450010', 'thanh.bt@mail.com', '0901000010', '1998-03-08', N'Việt Nam'),
(N'Đặng Văn Lâm', '079123450011', 'lam.dv@mail.com', '0901000011', '1991-05-19', N'Việt Nam'),
(N'Hoàng Cảnh Du', 'CN321654987', 'hoang.cd@mail.com', '0901000012', '1994-10-02', N'Trung Quốc'),
(N'Ngô Bảo Châu', '079123450013', 'chau.nb@mail.com', '0901000013', '1972-06-28', N'Việt Nam'),
(N'Lý Mạc Sầu', '079123450014', 'sau.lm@mail.com', '0901000014', '1986-12-01', N'Việt Nam'),
(N'Anna Taylor', 'UK159753486', 'anna.t@mail.com', '0901000015', '1996-02-14', N'Anh');
GO

-- 3. Bảng RoomType (15 dòng)
INSERT INTO RoomType (TypeName, Description, BasePrice, MaxGuests, BedType, IsSmokingAllowed) VALUES 
(N'Standard Single', N'Phòng đơn tiêu chuẩn', 400000, 1, N'1 Giường Đơn', 0),
(N'Standard Twin', N'Phòng 2 giường đơn', 600000, 2, N'2 Giường Đơn', 0),
(N'Superior Double', N'Phòng đôi tiện nghi', 800000, 2, N'1 Giường Đôi', 0),
(N'Superior Twin', N'Phòng 2 giường cao cấp', 900000, 2, N'2 Giường Đơn', 0),
(N'Deluxe Double', N'Phòng Deluxe sang trọng', 1500000, 2, N'1 Giường King', 0),
(N'Deluxe City View', N'Phòng Deluxe hướng phố', 1700000, 2, N'1 Giường King', 0),
(N'Deluxe Ocean View', N'Phòng Deluxe hướng biển', 2000000, 2, N'1 Giường King', 0),
(N'Executive Suite', N'Phòng Suite thương gia', 3000000, 2, N'1 Giường King', 0),
(N'Family Suite', N'Phòng cho gia đình', 2500000, 4, N'2 Giường Đôi', 0),
(N'Connecting Room', N'Hai phòng thông nhau', 2800000, 4, N'2 Giường Đôi', 0),
(N'Studio Apartment', N'Phòng dạng căn hộ có bếp', 2200000, 2, N'1 Giường Queen', 0),
(N'Presidential Suite', N'Phòng Tổng thống VIP', 10000000, 4, N'2 Giường King', 1),
(N'Honeymoon Suite', N'Phòng trăng mật lãng mạn', 3500000, 2, N'1 Giường King Tròn', 0),
(N'Accessible Room', N'Phòng cho người khuyết tật', 700000, 2, N'1 Giường Đôi thấp', 0),
(N'Penthouse', N'Căn hộ áp mái cao cấp', 8000000, 6, N'3 Giường King', 1);
GO

-- 4. Bảng Service (15 dòng)
INSERT INTO Service (ServiceName, Description, Price, Category, DurationMinutes, IsAvailable) VALUES 
(N'Giặt ủi nhanh', N'Giặt và ủi trong 4 tiếng', 150000, N'Laundry', 240, 1),
(N'Giặt khô', N'Giặt khô đồ vest/đầm dạ hội', 200000, N'Laundry', 1440, 1),
(N'Massage toàn thân', N'Thư giãn cơ bắp', 500000, N'Spa', 60, 1),
(N'Xông hơi (Sauna)', N'Xông hơi khô/ướt', 200000, N'Spa', 45, 1),
(N'Đưa đón sân bay', N'Xe 4 chỗ đưa đón 1 chiều', 300000, N'Transport', 40, 1),
(N'Thuê xe máy', N'Thuê xe tay ga theo ngày', 150000, N'Transport', 1440, 1),
(N'Bữa sáng tận phòng', N'Set ăn sáng kiểu Âu', 250000, N'F&B', 30, 1),
(N'Buffet hải sản tối', N'Ăn tối tại nhà hàng', 800000, N'F&B', 120, 1),
(N'Minibar', N'Combo đồ uống nhẹ', 100000, N'F&B', 0, 1),
(N'Tour tham quan thành phố', N'Xe điện dạo quanh thành phố', 400000, N'Tour', 180, 1),
(N'Trông trẻ (Babysitting)', N'Chăm sóc bé theo giờ', 100000, N'Care', 60, 1),
(N'Trang trí phòng trăng mật', N'Hoa hồng, bóng bay, rượu vang', 1000000, N'Event', 0, 1),
(N'Phòng Gym', N'Sử dụng phòng tập thể hình', 0, N'Fitness', 0, 1), -- Giá 0 vì có thể miễn phí
(N'Thuê phòng họp', N'Phòng họp sức chứa 20 người', 2000000, N'Business', 240, 1),
(N'Đánh thức (Wake-up call)', N'Gọi điện báo thức buổi sáng', 0, N'Care', 0, 1);
GO

-- 5. Bảng Facility (15 dòng)
INSERT INTO Facility (FacilityName, Description, Category, IsComplimentary) VALUES 
(N'Wifi tốc độ cao', N'Phủ sóng toàn khách sạn', N'Network', 1),
(N'Smart TV 55 inch', N'Kết nối Netflix, YouTube', N'Entertainment', 1),
(N'Điều hòa trung tâm', N'Chỉnh nhiệt độ độc lập', N'Appliance', 1),
(N'Tủ lạnh Mini', N'Bảo quản đồ uống', N'Appliance', 1),
(N'Két sắt điện tử', N'Bảo mật tài sản cá nhân', N'Security', 1),
(N'Bồn tắm nằm', N'Có hệ thống massage sục khí', N'Bathroom', 0),
(N'Vòi sen đứng', N'Nóng lạnh tự động', N'Bathroom', 1),
(N'Máy sấy tóc', N'Công suất lớn', N'Bathroom', 1),
(N'Bàn làm việc', N'Gỗ sồi, kèm đèn đọc sách', N'Furniture', 1),
(N'Ban công riêng', N'View đẹp, có ghế lười', N'Architecture', 1),
(N'Hồ bơi vô cực', N'Hồ bơi trên sân thượng', N'Recreation', 1),
(N'Máy pha cà phê', N'Kèm viên nén capsule', N'Appliance', 0),
(N'Bộ ghế Sofa', N'Sofa da cao cấp', N'Furniture', 1),
(N'Cửa sổ kính cách âm', N'Kính cường lực 2 lớp', N'Architecture', 1),
(N'Thảm lót sàn', N'Thảm lông cừu chống trượt', N'Furniture', 1);
GO

-- 6. Bảng Employee (15 dòng) -> Lưu ý: RoleID giả định từ 1 đến 15 tương ứng với 15 roles ở trên
INSERT INTO Employee (FullName, Phone, Email, RoleID) VALUES 
(N'Phan Văn Trường', '0912000001', 'truong.pv@hotel.com', 1),
(N'Đinh Thị Hoa', '0912000002', 'hoa.dt@hotel.com', 2),
(N'Lưu Trọng Lư', '0912000003', 'lu.lt@hotel.com', 3),
(N'Cao Thái Sơn', '0912000004', 'son.ct@hotel.com', 4),
(N'Hồ Ngọc Hà', '0912000005', 'ha.hn@hotel.com', 5),
(N'Gordon Ramsay VN', '0912000006', 'gordon@hotel.com', 6),
(N'Lê Văn Luyện', '0912000007', 'luyen.lv@hotel.com', 7),
(N'Trương Thế Vinh', '0912000008', 'vinh.tt@hotel.com', 8),
(N'Bill Gates VN', '0912000009', 'bill@hotel.com', 9),
(N'Ngọc Trinh', '0912000010', 'trinh.nt@hotel.com', 10),
(N'Trấn Thành', '0912000011', 'thanh.tt@hotel.com', 11),
(N'Trường Giang', '0912000012', 'giang.t@hotel.com', 12),
(N'Lý Hải', '0912000013', 'hai.l@hotel.com', 13),
(N'Cường Đô La', '0912000014', 'cuong.dl@hotel.com', 14),
(N'Sơn Tùng MTP', '0912000015', 'tung.st@hotel.com', 15);
GO

-- 7. Bảng Room (15 dòng) -> Lưu ý: RoomTypeID giả định từ 1 đến 15
INSERT INTO Room (RoomNumber, Floor, Status, IsAccessible, RoomTypeID) VALUES 
('102', 1, N'Available', 1, 1),
('103', 1, N'Occupied', 0, 2),
('201', 2, N'Maintenance', 0, 3),
('203', 2, N'Available', 0, 4),
('301', 3, N'Available', 0, 5),
('302', 3, N'Occupied', 0, 6),
('401', 4, N'Available', 0, 7),
('402', 4, N'Cleaning', 0, 8),
('502', 5, N'Available', 0, 9),
('503', 5, N'Occupied', 0, 10),
('601', 6, N'Available', 0, 11),
('701', 7, N'Occupied', 0, 12),
('702', 7, N'Available', 0, 13),
('104', 1, N'Available', 1, 14),
('801', 8, N'Available', 0, 15);
GO

-- 8. Bảng RoomType_Facility (15 dòng)
INSERT INTO RoomType_Facility (RoomTypeID, FacilityID) VALUES 
(1, 1), (1, 3), (2, 2), (3, 4), (4, 5), 
(5, 6), (6, 7), (7, 8), (8, 9), (9, 10), 
(10, 11), (11, 12), (12, 13), (13, 14), (15, 15);
GO

-- 9. Bảng Room_Facility (15 dòng)
INSERT INTO Room_Facility (RoomID, FacilityID) VALUES
(15, 14), (15, 10), (14, 13), (13, 12), (12, 11), 
(11, 10),(10, 9), (9, 8), (8, 7), (7, 6), 
(6, 5), (5, 4), (4, 3), (3, 2), (2, 1)
GO

-- 9. Bảng Payroll (15 dòng)
INSERT INTO Payroll (EmployeeID, PayDate, BaseSalary, Bonus, Deductions) VALUES 
(1, '2023-10-31', 50000000, 5000000, 0),
(2, '2023-10-31', 25000000, 2000000, 500000),
(3, '2023-10-31', 22000000, 1000000, 0),
(4, '2023-10-31', 18000000, 3000000, 200000),
(5, '2023-10-31', 15000000, 1500000, 0),
(6, '2023-10-31', 30000000, 4000000, 1000000),
(7, '2023-10-31', 8000000, 500000, 0),
(8, '2023-10-31', 7500000, 800000, 0),
(9, '2023-10-31', 15000000, 1000000, 0),
(10, '2023-10-31', 12000000, 2000000, 0),
(11, '2023-10-31', 11000000, 1500000, 100000),
(12, '2023-10-31', 8000000, 2500000, 0),
(13, '2023-10-31', 10000000, 500000, 0),
(14, '2023-10-31', 9000000, 0, 200000),
(15, '2023-10-31', 14000000, 5000000, 0);
GO

-- 10. Bảng Booking (15 dòng) -> Lưu ý: CheckOut > CheckIn
INSERT INTO Booking (BookingDate, CheckinDate, CheckoutDate, BookingStatus, NumberOfGuests, CustomerID, EmployeeID) VALUES 
('2023-10-01', '2023-10-10', '2023-10-12', N'Completed', 1, 1, 4),
('2023-10-02', '2023-10-11', '2023-10-15', N'Completed', 2, 2, 4),
('2023-10-05', '2023-10-20', '2023-10-22', N'Completed', 2, 3, 4),
('2023-10-10', '2023-10-25', '2023-10-28', N'Completed', 1, 4, 4),
('2023-10-15', '2023-10-26', '2023-10-30', N'Completed', 2, 5, 4),
('2023-10-20', '2023-11-01', '2023-11-05', N'Confirmed', 1, 6, 4),
('2023-10-21', '2023-11-02', '2023-11-10', N'Confirmed', 2, 7, 4),
('2023-10-22', '2023-11-05', '2023-11-08', N'Confirmed', 2, 8, 4),
('2023-10-23', '2023-11-10', '2023-11-12', N'Pending', 1, 9, 4),
('2023-10-24', '2023-11-15', '2023-11-18', N'Pending', 4, 10, 4),
('2023-10-25', '2023-11-20', '2023-11-22', N'Cancelled', 2, 11, 4),
('2023-10-26', '2023-11-25', '2023-11-30', N'Confirmed', 4, 12, 4),
('2023-10-27', '2023-12-01', '2023-12-05', N'Pending', 2, 13, 4),
('2023-10-28', '2023-12-10', '2023-12-15', N'Confirmed', 2, 14, 4),
('2023-10-29', '2023-12-24', '2023-12-26', N'Pending', 6, 15, 4);
GO

-- 11. Bảng trung gian Booking_Room (15 dòng)
INSERT INTO Booking_Room (BookingID, RoomID, PriceAtTime) VALUES 
(1, 1, 400000), (2, 2, 600000), (3, 3, 800000),
(4, 4, 900000), (5, 5, 1500000), (6, 6, 1700000),
(7, 7, 2000000), (8, 8, 3000000), (9, 9, 2500000),
(10, 10, 2800000), (11, 11, 2200000), (12, 12, 10000000),
(13, 13, 3500000), (14, 14, 700000), (15, 15, 8000000);
GO

-- 12. Bảng trung gian Booking_Service (15 dòng)
INSERT INTO Booking_Service (BookingID, ServiceID, Quantity, PriceAtTime) VALUES 
(1, 1, 1, 150000), (2, 2, 2, 200000), (3, 3, 1, 500000),
(4, 4, 1, 200000), (5, 5, 1, 300000), (6, 6, 2, 150000),
(7, 7, 2, 250000), (8, 8, 2, 800000), (9, 9, 3, 100000),
(10, 10, 4, 400000), (11, 11, 1, 100000), (12, 12, 1, 1000000),
(13, 13, 2, 0), (14, 14, 1, 2000000), (15, 15, 1, 0);
GO

-- 13. Bảng Invoice (15 dòng) -> UNIQUE trên BookingID
INSERT INTO Invoice (BookingID, DepositAmount, TotalAmount, PaymentDate, PaymentMethod) VALUES 
(1, 0, 950000, '2023-10-12', N'Tiền mặt'),
(2, 500000, 2300000, '2023-10-15', N'Chuyển khoản'),
(3, 0, 2100000, '2023-10-22', N'Thẻ tín dụng'),
(4, 0, 2900000, '2023-10-28', N'Tiền mặt'),
(5, 1000000, 6300000, '2023-10-30', N'Chuyển khoản'),
(6, 1000000, 7100000, NULL, N'Thẻ tín dụng'),
(7, 2000000, 16500000, NULL, N'Chuyển khoản'),
(8, 2000000, 10600000, NULL, N'Tiền mặt'),
(9, 1000000, 5300000, NULL, N'Thẻ tín dụng'),
(10, 3000000, 10000000, NULL, N'Chuyển khoản'),
(11, 500000, 0, NULL, N'Hoàn tiền'), -- Cancelled
(12, 10000000, 51000000, NULL, N'Thẻ tín dụng'),
(13, 2000000, 14000000, NULL, N'Chuyển khoản'),
(14, 0, 5500000, NULL, N'Tiền mặt'),
(15, 5000000, 16000000, NULL, N'Thẻ tín dụng');
GO

-- 14. Bảng trung gian Service_Invoice (15 dòng)
INSERT INTO Service_Invoice (ServiceID, InvoiceID, Quantity, PriceAtTime) VALUES 
(1, 1, 1, 150000), (2, 2, 2, 200000), (3, 3, 1, 500000),
(4, 4, 1, 200000), (5, 5, 1, 300000), (6, 6, 2, 150000),
(7, 7, 2, 250000), (8, 8, 2, 800000), (9, 9, 3, 100000),
(10, 10, 4, 400000), (11, 11, 1, 100000), (12, 12, 1, 1000000),
(13, 13, 2, 0), (14, 14, 1, 2000000), (15, 15, 1, 0);
GO


-- Thêm 2 khách vãng lai (Chỉ vào dùng dịch vụ, không thuê phòng -> BookingID = NULL)
INSERT INTO Invoice (BookingID, DepositAmount, TotalAmount, PaymentDate, PaymentMethod) 
VALUES 
(NULL, 0, 500000, GETDATE(), N'Tiền mặt'),      -- Khách vãng lai 1: Massage
(NULL, 0, 1600000, GETDATE(), N'Chuyển khoản'); -- Khách vãng lai 2: Buffet tối 2 người

-- Giả sử 2 hóa đơn trên tự động được cấp ID là 16 và 17. 
-- Ta thêm chi tiết dịch vụ họ dùng vào bảng Service_Invoice:
INSERT INTO Service_Invoice (ServiceID, InvoiceID, Quantity, PriceAtTime) 
VALUES 
(3, 16, 1, 500000),   -- Hóa đơn 16 dùng 1 Massage (ServiceID = 3)
(8, 17, 2, 800000);   -- Hóa đơn 17 dùng 2 Buffet (ServiceID = 8)