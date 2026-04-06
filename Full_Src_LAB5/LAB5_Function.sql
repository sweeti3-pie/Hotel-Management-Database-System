use HotelManagement_Group8_1;


go 
--ham tinh tuoi khach dua tren id khach
create function fn_CalculateCustomerAge (@CustID INT)
returns int 
as 
begin 
   declare @age int ;
   select @age = year(getdate()) - year(c.DateOfBirth)
   from Customer c
   where c.CustomerID = @CustID ;
   return @age;
end;
go

--ham tinh tong tien khach chi tieu trong khach san 
create function fn_TotalSpentByCustomer(@CusID int)
returns DECIMAL (18,2)
AS 
begin 
declare @Totalspent decimal (18,2);
select @Totalspent = sum(i.TotalAmount)
from Invoice i 
join Booking b on i.BookingID = b.BookingID
where b.CustomerID = @CusID;
return isnull(@Totalspent,0);
end
go 

--ham dem so phong con trong theo loai ma phong (romtype)
create function fn_CountAvailableRooms (@RoomTypsID int)
returns int 
as 
begin 
 declare @available int ; 
 select @available = count(*)
 from room 
 where RoomTypeID = @RoomTypsID and Status = 'Available';
 return @available ;
 end;

 go
 --4 viet ham xuat danh sach cac dich vu ma booking da su dung 
 create function fn_GetServiceByBooking (@BookingID int)
 returns table 
 as 
 return (
 select s.ServiceName,bs.Quantity,bs.PriceAtTime, (bs.Quantity*bs.PriceAtTime) as SubTotal
 from Booking_Service bs 
 join Service s on bs.ServiceID =s.ServiceID
 where bs.BookingID = @BookingID
 )
 go

 --ham trả về bảng trả về những phòng trống của 1 loại giường được nạp vào 
 create function fn_GetAvailableRoomsByBedType (@BedType nvarchar(50))
 returns table 
 as 
 return
 (select r.RoomNumber,r.Floor,rt.TypeName,rt.BasePrice 
 from Room r join RoomType rt on r.RoomTypeID =rt.RoomTypeID
 where rt.BedType = @BedType and r.Status ='Available'
 
 )
 go 


 --tra ve tat ca tien ich cua 1 phong cu  the
 create function findAllFacilityByRoomID ( @RoomID int  )

 returns table 
 as return (
 
 select f.FacilityName
from Room_Facility rf
join Facility f  on rf.FacilityID =f.FacilityID
where rf.RoomID = @RoomID
 

union 


select f.FacilityName
from RoomType_Facility rt 
join Room r on r.RoomTypeID = rt.RoomTypeID
join Facility f on rt.FacilityID = f.FacilityID
where r.RoomID = @RoomID

 )
 