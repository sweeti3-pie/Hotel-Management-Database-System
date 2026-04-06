
--tạo đơn khách vãng lai 
INSERT INTO Invoice (BookingID, DepositAmount, TotalAmount, PaymentDate, PaymentMethod)
VALUES (NULL, 0, 0, NULL, N'Chờ thanh toán');
--lấy mã hóa đơn tự động được sinh ra
SELECT SCOPE_IDENTITY() AS MaHoaDonVừaTạo;
--chọn loại dịch vụ 
EXEC sp_ThemDichVuVangLai @InvoiceID = 21, @ServiceID = 6, @Quantity = 2;
SELECT * FROM Service_Invoice WHERE InvoiceID = 23;
--thanh toán 
exec sp_ThanhToanDichVuVangLai 23,  N'Tiền mặt'


select * 
from Invoice


