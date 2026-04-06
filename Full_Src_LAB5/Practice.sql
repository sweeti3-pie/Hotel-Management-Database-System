select c.CustomerID,c.FullName,isnull(count(b.BookingID),0)
from Customer c
 left join Booking b on c.CustomerID=b.CustomerID
 
 group by c.CustomerID,c.FullName


 select rt.TypeName,isnull(count(r.RoomID),0) as NumberOfRoom
 from RoomType rt
 left join Room r on r.RoomTypeID = rt.RoomTypeID
 group by rt.TypeName


 select c.CustomerID,c.FullName 
 from Customer c 
 join Booking b on c.CustomerID = b.CustomerID
 join Booking_Room br on b.BookingID = br.BookingID
 join Room r on r.RoomID = br.RoomID
 join RoomType rt on r.RoomTypeID = rt.RoomTypeID
 where rt.TypeName =N'Phòng Tổng Thống'


 select f.FacilityName
 from Room r
 join RoomType rt on r.RoomTypeID=rt.RoomTypeID
 join RoomType_Facility rtf on rtf.RoomTypeID=rt.RoomTypeID
 join Facility f on rtf.FacilityID = f.FacilityID
 where r.RoomID='1'


 select e.*
 from Employee e
 left join Booking b on e.EmployeeID=b.EmployeeID
 where b.BookingStatus is null

 select * 
 from Invoice 

 select * 
 from service
 select * 
 from Booking_Service

 select * 
 from Service_Invoice


 
