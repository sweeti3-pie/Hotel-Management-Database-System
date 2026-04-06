--truy van co ban 
--lay du lieu--
--Bảng 1:Customer
SELECT * FROM Customer WHERE Nationality = N'Việt Nam';
SELECT * FROM Customer WHERE YEAR(DateOfBirth) >= 2000;
SELECT * FROM Customer WHERE Phone LIKE '09%';
SELECT * FROM Customer WHERE Email LIKE '%@mail.com';
SELECT * FROM Customer WHERE IDNumber IS NOT NULL;

-- Bảng 2: Room 
SELECT * FROM Room WHERE Status = 'Available';
SELECT * FROM Room WHERE Status = 'Occupied';
SELECT * FROM Room WHERE Floor = 1;
SELECT * FROM Room WHERE IsAccessible = 1;
SELECT * FROM Room WHERE RoomNumber = 102;

-- Bảng 3: Booking 
SELECT * FROM Booking WHERE BookingStatus = 'Completed';
SELECT * FROM Booking WHERE BookingStatus = 'Pending';
SELECT * FROM Booking WHERE NumberOfGuests = 1;
SELECT * FROM Booking WHERE NumberOfGuests >= 2;
SELECT * FROM Booking WHERE EmployeeID = 2;



 --sap xep du lieu voi order by-- 
 -- Bảng 1: Customer 
SELECT * FROM Customer ORDER BY FullName ASC;
SELECT * FROM Customer ORDER BY FullName DESC;
SELECT * FROM Customer ORDER BY DateOfBirth ASC;
SELECT * FROM Customer ORDER BY DateOfBirth DESC;
SELECT * FROM Customer ORDER BY Nationality ASC;

-- Bảng 2: Room 
SELECT * FROM Room ORDER BY RoomNumber ASC;
SELECT * FROM Room ORDER BY RoomNumber DESC;
SELECT * FROM Room ORDER BY Floor DESC;
SELECT * FROM Room ORDER BY RoomTypeID ASC;
SELECT * FROM Room ORDER BY Status DESC;

-- Bảng 3: Invoice 
SELECT * FROM Invoice ORDER BY TotalAmount DESC;
SELECT * FROM Invoice ORDER BY TotalAmount ASC;
SELECT * FROM Invoice ORDER BY PaymentDate DESC;
SELECT * FROM Invoice ORDER BY PaymentMethod ASC;
SELECT * FROM Invoice ORDER BY BookingID DESC;


--ham tinh toan co ban 

-- Bảng 1: Customer 
SELECT COUNT(CustomerID) AS TongKhachHang FROM Customer;
SELECT MIN(DateOfBirth) AS NgaySinhNhoNhat FROM Customer;
SELECT MAX(DateOfBirth) AS NgaySinhLonNhat FROM Customer;
SELECT COUNT(DISTINCT Nationality) AS SoLuongQuocTich FROM Customer;
SELECT COUNT(*) AS KhachVietNam FROM Customer WHERE Nationality = N'Việt Nam';

-- Bảng 2: Room 
SELECT COUNT(RoomID) AS TongSoPhong FROM Room;
SELECT MAX(Floor) AS TangCaoNhat FROM Room;
SELECT MIN(Floor) AS TangThapNhat FROM Room;
SELECT COUNT(*) AS PhongTrong FROM Room WHERE Status = 'Available';
SELECT COUNT(*) AS SoPhongTang1 FROM Room WHERE Floor = 1;

-- Bảng 3: Invoice 
SELECT SUM(TotalAmount) AS TongDoanhThu FROM Invoice;
SELECT AVG(TotalAmount) AS TrungBinhMoiHoaDon FROM Invoice;
SELECT MAX(TotalAmount) AS HoaDonCaoNhat FROM Invoice;
SELECT MIN(TotalAmount) AS HoaDonThapNhat FROM Invoice;
SELECT COUNT(InvoiceID) AS TongSoHoaDon FROM Invoice;






--phan truy van trung binh--

--1(inner join) xem chi tiet ten khach hang va ngay nhan tra phong 
select c.FullName,b.CheckinDate,b.CheckoutDate
from Customer c
join booking b on c.CustomerID  = b.CustomerID;

--2xem nhan vien nao thuoc bo phan nao va muc luong bao nhieu 
select e.FullName,r.PositionName,r.Salary
from Employee e
join role r on e.RoleID = r.RoleID

--3liet ke tat ca dich vu va so luong duoc dat trong cac don (left join)
select s.ServiceName,bs.Quantity
from service s 
left join Booking_Service bs on s.ServiceID = bs.ServiceID;
--4khach hang nao dang o phong so may (multi-join)
select c.FullName,r.RoomNumber
from customer c 
join booking b on c.CustomerID = b.CustomerID
join Booking_Room br on b.BookingID = br.BookingID
join room r on br.RoomID = r.RoomID

--5khach nao da thanh toan hoa don voi so tien la bao nhieu 
select c.FullName,i.TotalAmount,i.PaymentMethod
from Customer c
join Booking b on c.CustomerID = b.CustomerID
join Invoice i on b.BookingID = i.BookingID;

-- 6. Xem nhân viên nào đã phụ trách xử lý đơn đặt phòng nào
SELECT e.FullName AS NhanVienPhuTrach, b.BookingID, b.CheckinDate
FROM Employee e
JOIN Booking b ON e.EmployeeID = b.EmployeeID;

-- 7. Xem chi tiết thông tin phòng kèm theo mô tả của loại phòng đó
SELECT r.RoomNumber, rt.TypeName, rt.Description 
FROM Room r
JOIN RoomType rt ON r.RoomTypeID = rt.RoomTypeID;

-- 8. Liệt kê các khách hàng đã dùng dịch vụ và tên dịch vụ họ dùng
SELECT c.FullName, s.ServiceName, bs.Quantity 
FROM Customer c
JOIN Booking b ON c.CustomerID = b.CustomerID
JOIN Booking_Service bs ON b.BookingID = bs.BookingID
JOIN Service s ON bs.ServiceID = s.ServiceID;

-- 9. Quản lý xem hóa đơn nào do nhân viên nào phụ trách chốt
SELECT i.InvoiceID, i.TotalAmount, e.FullName AS NhanVienChotDon
FROM Invoice i
JOIN Booking b ON i.BookingID = b.BookingID
JOIN Employee e ON b.EmployeeID = e.EmployeeID;

-- 10. Lấy danh sách trạng thái của tất cả các đơn đặt phòng và số phòng tương ứng
SELECT b.BookingID, b.BookingStatus, r.RoomNumber 
FROM Booking b
JOIN Booking_Room br ON b.BookingID = br.BookingID
JOIN Room r ON br.RoomID = r.RoomID;






--su dung group by va having
--1dem so luong phong moi tang
select Floor as Tang, count (RoomID) as SoLuongPhong
from room r
group by Floor;

--2tinh tong doanh thu theo tung phuong thuc thanh toan 
select i.PaymentMethod, sum(i.TotalAmount) as DoanhThu
from invoice i
group by i.PaymentMethod;

--3dem so luong khach theo tung quoc tich 
select c.Nationality , count(c.CustomerID) as SoLuong
from Customer c
group by c.Nationality;

--4(having) tim nhung chuc vu (role) co muc luong tren 8.000.000
select PositionName,avg(salary) as MucLuong
from Role
group by PositionName 
having avg (salary) >8000000;

--5tim cac tang co tu 2 phong tro len 
select floor,count(RoomID) as SoPhong
from room 
group by floor
having count(RoomID)>=2;
-- 6. Đếm số lượng đơn đặt phòng do mỗi nhân viên xử lý
SELECT e.FullName, COUNT(b.BookingID) AS SoDonDaXuLy
FROM Employee e
JOIN Booking b ON e.EmployeeID = b.EmployeeID
GROUP BY e.FullName;

-- 7. Thống kê tổng số lượng đã bán ra của từng loại dịch vụ
SELECT s.ServiceName, SUM(bs.Quantity) AS TongSoLuongDaBan
FROM Service s
JOIN Booking_Service bs ON s.ServiceID = bs.ServiceID
GROUP BY s.ServiceName;

-- 8. Thống kê doanh thu theo từng tháng thanh toán
SELECT MONTH(PaymentDate) AS Thang, SUM(TotalAmount) AS TongDoanhThuThang
FROM Invoice
GROUP BY MONTH(PaymentDate);

-- 9. (HAVING) Tìm những ngày có từ 2 đơn check-in trở lên
SELECT CheckinDate, COUNT(BookingID) AS SoLuongDon
FROM Booking
GROUP BY CheckinDate
HAVING COUNT(BookingID) >= 2;

-- 10. (HAVING) Tìm khách hàng có số ngày ở trung bình từ 2 ngày trở lên
SELECT CustomerID, AVG(DATEDIFF(day, CheckinDate, CheckoutDate)) AS TrungBinhSoNgayO
FROM Booking
GROUP BY CustomerID
HAVING AVG(DATEDIFF(day, CheckinDate, CheckoutDate)) >= 2;





--truy van con trong where/from 
--1tim thong tin cua hoa don co gia tri lon nhat 
select *
from Invoice
where TotalAmount = (select max(TotalAmount) from Invoice);

--2tim nhung khach hang da tung dat phong 
select c.FullName,c.Phone
from Customer c where c.CustomerID in (select CustomerID from Booking); 

--3tim cac phong co gia cao hon gia trung binh cua khach san 
select rt.TypeName,rt.BasePrice
from RoomType rt 
where rt.BasePrice>(select avg (BasePrice) from RoomType);

-- 4. Tìm những khách hàng CHƯA TỪNG đặt phòng bao giờ (Khách ảo)
SELECT FullName, Phone 
FROM Customer 
WHERE CustomerID NOT IN (SELECT CustomerID FROM Booking);

-- 5. Tìm các nhân viên có mức lương cao hơn mức lương trung bình của toàn khách sạn
SELECT e.FullName, r.Salary 
FROM Employee e
JOIN Role r ON e.RoleID = r.RoleID
WHERE r.Salary > (SELECT AVG(Salary) FROM Role);

-- 6. Tìm danh sách các phòng thuộc loại 'Standard' bằng Subquery
SELECT RoomNumber, Floor 
FROM Room 
WHERE RoomTypeID = (SELECT RoomTypeID FROM RoomType WHERE TypeName like 'Standard');

-- 7. Tìm các mã đơn đặt phòng có sử dụng dịch vụ 'Massage'
SELECT BookingID, Quantity 
FROM Booking_Service 
WHERE ServiceID = (SELECT ServiceID FROM Service WHERE ServiceName like N'Massage');

-- 8. Tìm những dịch vụ chưa từng được khách hàng nào sử dụng
SELECT ServiceName, Price 
FROM Service 
WHERE ServiceID NOT IN (SELECT ServiceID FROM Booking_Service);

-- 9. Tìm khách hàng có năm sinh lớn tuổi hơn độ tuổi trung bình của tập khách hàng
SELECT FullName, DateOfBirth 
FROM Customer 
WHERE YEAR(DateOfBirth) < (SELECT AVG(YEAR(DateOfBirth)) FROM Customer);

-- 10. (Subquery trong FROM) Tính mức doanh thu cao nhất trong các tháng
SELECT MAX(DoanhThuThang) AS DoanhThuThangCaoNhat 
FROM (
    SELECT MONTH(PaymentDate) AS Thang, SUM(TotalAmount) AS DoanhThuThang
    FROM Invoice
    GROUP BY MONTH(PaymentDate)
) AS BangThongKeThang;





--truy van nang cao --
-- 1. Truy vấn lồng nhau nhiều cấp (Nested Subqueries)
-- Bảng 1: Customer 
-- 1. Khách hàng đã ở phòng 101
SELECT FullName FROM Customer WHERE CustomerID IN (SELECT CustomerID FROM Booking WHERE BookingID IN (SELECT BookingID FROM Booking_Room WHERE RoomID = (SELECT RoomID FROM Room WHERE RoomNumber = '101')));
-- 2. Khách hàng có hóa đơn cao nhất
SELECT FullName FROM Customer WHERE CustomerID IN (SELECT CustomerID FROM Booking WHERE BookingID IN (SELECT BookingID FROM Invoice WHERE TotalAmount = (SELECT MAX(TotalAmount) FROM Invoice)));
-- 3. Khách hàng đã dùng dịch vụ Massage
SELECT FullName FROM Customer WHERE CustomerID IN (SELECT CustomerID FROM Booking WHERE BookingID IN (SELECT BookingID FROM Booking_Service WHERE ServiceID = (SELECT ServiceID FROM Service WHERE ServiceName = N'Massage')));
-- 4. Khách hàng được phục vụ bởi quản lý
SELECT FullName FROM Customer WHERE CustomerID IN (SELECT CustomerID FROM Booking WHERE EmployeeID IN (SELECT EmployeeID FROM Employee WHERE RoleID = (SELECT RoleID FROM Role WHERE PositionName = N'Quản lý')));
-- 5. Khách hàng ở tầng 5
SELECT FullName FROM Customer WHERE CustomerID IN (SELECT CustomerID FROM Booking WHERE BookingID IN (SELECT BookingID FROM Booking_Room WHERE RoomID IN (SELECT RoomID FROM Room WHERE Floor = 5)));

-- Bảng 2: Room 
-- 1. Các phòng đã được khách VN đặt
SELECT RoomNumber FROM Room WHERE RoomID IN (SELECT RoomID FROM Booking_Room WHERE BookingID IN (SELECT BookingID FROM Booking WHERE CustomerID IN (SELECT CustomerID FROM Customer WHERE Nationality = N'Việt Nam')));
-- 2. Các phòng mang lại hóa đơn trên 2 triệu
SELECT RoomNumber FROM Room WHERE RoomID IN (SELECT RoomID FROM Booking_Room WHERE BookingID IN (SELECT BookingID FROM Invoice WHERE TotalAmount > 2000000));
-- 3. Các phòng loại President
SELECT RoomNumber FROM Room WHERE RoomTypeID = (SELECT RoomTypeID FROM RoomType WHERE TypeName = 'President');
-- 4. Các phòng được đặt vào tháng 3
SELECT RoomNumber FROM Room WHERE RoomID IN (SELECT RoomID FROM Booking_Room WHERE BookingID IN (SELECT BookingID FROM Booking WHERE MONTH(CheckinDate) = 3));
-- 5. Các phòng chưa từng được đặt
SELECT RoomNumber FROM Room WHERE RoomID NOT IN (SELECT RoomID FROM Booking_Room WHERE BookingID IN (SELECT BookingID FROM Booking));


-- 
-- 2. Toán tử EXISTS, IN, ANY, ALL
-- 
-- Bảng 1: Customer 
SELECT FullName FROM Customer WHERE CustomerID IN (SELECT CustomerID FROM Booking);
SELECT FullName FROM Customer c WHERE EXISTS (SELECT 1 FROM Booking b WHERE b.CustomerID = c.CustomerID);
SELECT FullName FROM Customer c WHERE NOT EXISTS (SELECT 1 FROM Booking b WHERE b.CustomerID = c.CustomerID);
SELECT FullName FROM Customer WHERE CustomerID = ANY (SELECT CustomerID FROM Booking WHERE NumberOfGuests > 2);
SELECT FullName FROM Customer WHERE DateOfBirth <= ALL (SELECT DateOfBirth FROM Customer); -- Tìm người già nhất

-- Bảng 2: Room 
SELECT RoomNumber FROM Room WHERE RoomID IN (SELECT RoomID FROM Booking_Room);
SELECT RoomNumber FROM Room r WHERE EXISTS (SELECT 1 FROM Booking_Room br WHERE br.RoomID = r.RoomID);
SELECT RoomNumber FROM Room r WHERE NOT EXISTS (SELECT 1 FROM Booking_Room br WHERE br.RoomID = r.RoomID);
SELECT RoomNumber FROM Room WHERE RoomTypeID = ANY (SELECT RoomTypeID FROM RoomType WHERE BasePrice > 1000000);
SELECT RoomNumber FROM Room WHERE Floor >= ALL (SELECT Floor FROM Room); -- Tìm phòng ở tầng cao nhất



-- 3. Toán tử tập hợp (Set Operations: UNION, INTERSECT, EXCEPT)
-- (Phần này áp dụng gộp các bảng do đặc thù lệnh)

-- 5 câu UNION
SELECT FullName AS Ten, 'Khach Hang' AS VaiTro FROM Customer UNION SELECT FullName, 'Nhan Vien' FROM Employee;
SELECT Phone AS LienHe FROM Customer UNION SELECT Phone FROM Employee;
SELECT Email AS ThuDienTu FROM Customer UNION SELECT Email FROM Employee;
SELECT IDNumber AS MaDinhDanh FROM Customer UNION SELECT Phone FROM Employee;
SELECT CheckinDate AS NgayGiaoDich FROM Booking UNION SELECT PaymentDate FROM Invoice;

-- 5 câu INTERSECT / EXCEPT
SELECT CustomerID FROM Customer INTERSECT SELECT CustomerID FROM Booking;
SELECT EmployeeID FROM Employee INTERSECT SELECT EmployeeID FROM Booking;
SELECT RoomID FROM Room EXCEPT SELECT RoomID FROM Booking_Room;
SELECT ServiceID FROM Service EXCEPT SELECT ServiceID FROM Booking_Service;
SELECT CustomerID FROM Customer EXCEPT SELECT CustomerID FROM Booking;


-- lấy tất cả tiện ích của 1 p cụ thể 
-- Lấy tiện ích tiêu chuẩn của loại phòng
SELECT f.FacilityName 
FROM Room r
JOIN RoomType_Facility rtf ON r.RoomTypeID = rtf.RoomTypeID
JOIN Facility f ON rtf.FacilityID = f.FacilityID
WHERE r.RoomID = '101'

UNION -- Gộp với các tiện ích "đặc biệt" chỉ phòng này mới có

-- Lấy tiện ích riêng biệt của căn phòng đó
SELECT f.FacilityName 
FROM Room_Facility rf
JOIN Facility f ON rf.FacilityID = f.FacilityID
WHERE rf.RoomID = '101';