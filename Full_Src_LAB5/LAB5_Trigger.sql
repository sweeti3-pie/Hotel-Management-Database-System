--trigger giống như một thủ tục ngầm âm thầm bắt lỗi để đảm bảo tính toàn vẹn dữ liệu 
--procedure dùng cho việc thao tác update, set , delete dữ liệu trong data base
--function chỉ đơn giản là tính toán trả về giá trị (k có quyền thay đổi dữ liệu)


/*
nói đơn giản ví dụ về khách sạn 
khi có yêu cầu kiểm tra xem phòng này có người đặt hay chưa thì ta dùng hàm để kiểm tra nó chỉ được nói có hoặc 
không (nhưng k được tác động vào dữ liệu) và khi người ta dùng thủ tục để đặt phòng 
nó sẽ gọi hàm bên trong thủ tục nếu trống thì thủ tục sẽ được thực thi.
Đặc biệt là Triggers (trình kích hoạt) nó sẽ là chốt chặn cuối cùng 
khi người dùng cố tình insert sai dữ liệu vào thủ tục thì chính trigger sẽ kiểm ttra
nếu phát hiện sai lỗi ảnh hưởng tới toàn vẹn dữ liệu nó sẽ hủy bỏ toàn bộ luồng thực thi  và hiện rollback 
*/


use HotelManagement_Group8_1;
go 


--tu dong don phong sau khi khach huy(cancelled) hoac tra phong (completed) 
create trigger trg_TuDongDonPhong 
on Booking 
after update 
as 
begin 
-- chi chay khi cot staus bi thay doi con k thi ket thuc luong
if UPDATE (BookingStatus) 
     begin 
        update room 
        set Status = 'Available'
        where RoomID in (
        select br.RoomID 
        from Booking_Room br 
        --inserted chính là một bảng ảo lưu trữ lữ liẹu vừa được update 
        join inserted i on br.BookingID = i.BookingID
        where i.BookingStatus in ('Cancelled','Completed')

        
        );
        print N'Đã tự động chuyển trạng thái phòng thành Available (Trống)';
end 
end;
go


-- bao loi neu dat phong qua so nguoi duy dinh cua 1 phong 
create trigger trg_KiemTraSucChuaPhong 
on Booking_Room
after insert, update 
as 
begin 
if exists(
--select 1 nghĩa là trong dòng dữ liệu này cái nào thõa mãn thì thực thi

    select 1
    from inserted i 
    join Booking b on i.BookingID = b.BookingID
    join Room r  on i.RoomID = r.RoomID
    join RoomType rt on r.RoomTypeID = rt.RoomTypeID
    where b.NumberOfGuests>rt.MaxGuests
)
 
  begin
    Raiserror (N'số lượng khách vượt quá mức tối đa của loại phòng',16,1);
    rollback transaction; -- huy lenh insert/update vua nhap 
    end

end;
go


-- tuyet doi k duoc xoa don (chong gian lan ke toan)

create trigger trg_ChongXoaHoaDon
on invoice 
instead of delete 
as begin 
raiserror (N'Cảnh báo: không được xóa hóa đơn khỏi hệ thống !',16,1);
-- dùng instead of delete có nghĩa là thay vì xóa thì báo lỗi dừng lại 
end;
go 



-- chong dat trung phong (canh bao neu co nguoi dat)

create trigger trg_ChongDatTrungPhong 
on Booking_Room
after insert 
as 
begin 
   if exists(
   select 1 
   from inserted i 
   join room r on i.RoomID = r.RoomID
   where r.Status = 'Occupied' 
   
   )
   begin 
     raiserror (N'Phòng này hiện có người đặt, vui lòng chọn phòng khác ',16,1);
     rollback transaction 
     end 
     end;
     go
-- cái thú vị là dòng raiserror thì 16, 1 chính là mức độ nghiêm trọng lỗi 
-- 0-10 nhẹ , 11-16 lỗi nhập , dùng ngay lập tức , trên 20 server sập 
-- còn con số 1 laf trạng thái đánh dấu lỗi nằm đâu khi quản lý hệ thống lớn mà lỗi in ra giống nhau 