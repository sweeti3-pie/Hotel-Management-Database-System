USE HotelManagement_Group8_1
GO

-- ========================================================
-- PHẦN 4: TẠO VIEWS VÀ INDEXES (KHUNG NHÌN & CHỈ MỤC)
-- ========================================================

-- --------------------------------------------------------
-- 1. TẠO VIEWS (Tối thiểu 2 Views)
-- --------------------------------------------------------

-- View 1: Đơn giản hóa truy vấn xem Chi tiết Đặt phòng (Kết hợp 4 bảng)
-- Công dụng: Lễ tân chỉ cần MỞ VIEW NÀY lên là thấy hết tên khách, số phòng, ngày đến/đi mà không cần gõ JOIN lằng nhằng.
CREATE VIEW vw_ChiTietDatPhong 
AS
SELECT 
    b.BookingID,
    c.FullName AS TenKhachHang,
    c.Phone AS SoDienThoai,
    r.RoomNumber AS SoPhong,
    b.CheckinDate AS NgayNhanPhong,
    b.CheckoutDate AS NgayTraPhong,
    b.BookingStatus AS TrangThai
FROM Booking b
JOIN Customer c ON b.CustomerID = c.CustomerID
JOIN Booking_Room br ON b.BookingID = br.BookingID
JOIN Room r ON br.RoomID = r.RoomID;
GO

-- View 2: Xem danh sách các phòng Đang Trống kèm theo giá tiền
-- Công dụng: Lọc nhanh các phòng 'Available' để báo giá cho khách.
CREATE VIEW vw_DanhSachPhongTrong
AS
SELECT 
    r.RoomNumber AS SoPhong,
    r.Floor AS Tang,
    rt.TypeName AS LoaiPhong,
    rt.BedType AS LoaiGiuong,
    rt.BasePrice AS GiaPhong
FROM Room r
JOIN RoomType rt ON r.RoomTypeID = rt.RoomTypeID
WHERE r.Status = 'Available';
GO

-- --------------------------------------------------------
-- 2. TẠO INDEXES (Tối thiểu 2 Indexes)
-- --------------------------------------------------------

-- Index 1: Chỉ mục trên cột đơn lẻ (Single column index)
-- Công dụng: Tăng tốc độ tìm kiếm khi Lễ tân lọc danh sách khách đến nhận phòng theo ngày (CheckinDate).
CREATE INDEX idx_Booking_CheckinDate 
ON Booking(CheckinDate);
GO

-- Index 2: Chỉ mục phức hợp (Composite index) trên 2 cột
-- Công dụng: Tăng tốc cực nhanh khi tìm kiếm thông tin khách hàng cũ bằng cả Tên và Số điện thoại.
CREATE INDEX idx_Customer_Name_Phone 
ON Customer(FullName, Phone);
GO

