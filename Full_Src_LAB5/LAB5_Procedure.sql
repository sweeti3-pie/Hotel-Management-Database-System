use HotelManagement_Group8_1 ;
go 

-- thu tuc dat phong (them booking, gan phong, doi trang thai sang Oppcuied)
create procedure sp_DatPhongMoi 
    @CustomerId int,
    @EmployeeId int,
    @RoomID int,
    @CheckinDate Datetime,
    @CheckoutDate Datetime,
    @NumberOfGuests  int
    as 
    begin 
    --them booking moi 
    insert into Booking (CheckinDate,CheckoutDate,BookingStatus,NumberOfGuests,CustomerID,EmployeeID)
    values (@CheckinDate,@CheckoutDate,'Confirmed',@NumberOfGuests,@CustomerId,@EmployeeId);
  -- lay id booking vua duoc them 
     declare @newbookingid int = scope_identity();
     --dong lenh scope_identity chinh la tu dong lay mot ma ngam duoc cap ben cau lenh insert cho mot booking

     -- lay gia phong goc (baseprice) tu roomtype
     declare @price decimal (18,2);
     select @price = rt.BasePrice
     from RoomType rt join room r on rt.RoomTypeID=r.RoomTypeID
     where r.RoomID = @RoomID;
      -- luu lich su gia vao bang booking room 
      insert into Booking_Room (BookingID,RoomID,PriceAtTime)
      values (@newbookingid,@RoomID,@price);

      --khoa phong chuyen thanh Occupied
      update Room set Status ='Occupied' where RoomID = @RoomID;
      print N'Đặt phòng thành công !';
    end;
    go






    --thu tuc them dich vu vao booking (tu dong lay gia hien tai)

    create procedure sp_themdichvukhachhang
     @BookingID int,
     @ServiceID int,
     @Quantity int

     as 
     begin 
     --lay gia dich vu hien tai
     declare @currentprice decimal (18,2);
     select @currentprice = s.Price 
     from Service s
     where ServiceID = @ServiceID

     -- them vao bang hoa don dich vu 
     insert into Booking_Service (BookingID,ServiceID,Quantity,PriceAtTime)
     values (@BookingID, @ServiceID,@Quantity,@currentprice);

     print N'thêm dịch vụ thành công !';
     end;

     go





     -- thu tuc huy dat phong
     create procedure sp_huydatphong 
     @bookingID int 
     as 
     begin
     --thay trang thai booking
     update Booking set BookingStatus = 'Cancelled' where BookingID=@bookingID;
     -- tra lai phong thanh available
     update room
     set Status ='Available'
     where roomID in (
     select RoomID
     from Booking_Room 
     where BookingID=@bookingID
     );
     print N'Hủy phòng thành công, phòng đã trống !'
     end;

go 







--thu tuc bao cao doanh thu tong hop theo thang va nam
create procedure sp_baocaodoanhthuthang
@thang int ,
@nam int
as begin 
select 
month(PaymentDate) as Thang,
year(PaymentDate) as Nam,
count(InvoiceID)as  SoLuongHoaDon,
sum(TotalAmount) as TongDoanhThu

from invoice 
where MONTH(PaymentDate)  =@thang and year(PaymentDate) = @nam
group by MONTH(PaymentDate),year(PaymentDate);
end;
go

--thu tuc tra phong va thanh toan

CREATE PROCEDURE sp_TraPhongVaThanhToan
    @BookingID INT,
    @PaymentMethod NVARCHAR(50),
    @DepositAmount DECIMAL(18,2)
AS
BEGIN
    -- 1. Khai báo các biến để tính toán
    DECLARE @RoomCost DECIMAL(18,2) = 0;
    DECLARE @ServiceCost DECIMAL(18,2) = 0;
    DECLARE @TotalAmount DECIMAL(18,2) = 0;
    DECLARE @StayDays INT;

    -- 2. Tính số ngày khách ở
    SELECT @StayDays = DATEDIFF(DAY, CheckinDate, CheckoutDate)
    FROM Booking 
    WHERE BookingID = @BookingID;

    -- 3. Tính tổng tiền phòng
    SELECT @RoomCost = SUM(PriceAtTime) * @StayDays
    FROM Booking_Room 
    WHERE BookingID = @BookingID;

    -- 4. Tính tổng tiền dịch vụ (Dùng ISNULL phòng trường hợp khách không dùng dịch vụ nào)
    SELECT @ServiceCost = ISNULL(SUM(Quantity * PriceAtTime), 0)
    FROM Booking_Service 
    WHERE BookingID = @BookingID;

    -- 5. Cộng tổng tiền và Tạo hóa đơn
    SET @TotalAmount = @RoomCost + @ServiceCost;

    INSERT INTO Invoice (BookingID, DepositAmount, TotalAmount, PaymentDate, PaymentMethod)
    VALUES (@BookingID, @DepositAmount, @TotalAmount, GETDATE(), @PaymentMethod);

    -- 6. Cập nhật trạng thái Booking và Phòng
    UPDATE Booking 
    SET BookingStatus = 'Completed' 
    WHERE BookingID = @BookingID;

    UPDATE Room 
    SET Status = 'Cleaning' 
    WHERE RoomID IN (SELECT RoomID FROM Booking_Room WHERE BookingID = @BookingID);

    PRINT N'Trả phòng và thanh toán thành công!';
END;
GO




CREATE OR ALTER PROCEDURE sp_ThanhToanDichVuVangLai
    @InvoiceID INT,          -- Phải nạp ID hóa đơn vào đây
    @PaymentMethod NVARCHAR(50)
AS
BEGIN
    BEGIN TRY
        BEGIN TRAN;

        -- 1. Kiểm tra xem hóa đơn này có thực sự là của khách vãng lai (BookingID IS NULL) không
        IF NOT EXISTS (SELECT 1 FROM Invoice WHERE InvoiceID = @InvoiceID AND BookingID IS NULL)
        BEGIN
            PRINT N'Lỗi: Không tìm thấy hóa đơn vãng lai với ID này!';
            ROLLBACK TRAN;
            RETURN;
        END

        -- 2. Tính tổng tiền từ bảng Service_Invoice (các món lẻ đã nhập trước đó)
        DECLARE @Total DECIMAL(18,2);
        SELECT @Total = ISNULL(SUM(Quantity * PriceAtTime), 0)
        FROM Service_Invoice
        WHERE InvoiceID = @InvoiceID;

        -- 3. Cập nhật con số tổng tiền, ngày thanh toán và phương thức vào bảng Invoice
        UPDATE Invoice 
        SET TotalAmount = @Total,
            PaymentDate = GETDATE(),         -- Đóng dấu ngày thanh toán là hôm nay
            PaymentMethod = @PaymentMethod
        WHERE InvoiceID = @InvoiceID;

        COMMIT TRAN;
        PRINT N'Thanh toán hóa đơn vãng lai ' + CAST(@InvoiceID AS VARCHAR) + N' thành công!';
        PRINT N'Tổng tiền đã thu: ' + CAST(@Total AS VARCHAR);
        
    END TRY
    BEGIN CATCH
        ROLLBACK TRAN;
        PRINT N'Lỗi thanh toán: ' + ERROR_MESSAGE();
    END CATCH
END;
GO