USE [CaseStudy]
GO
/****** Object:  StoredProcedure [dbo].[ChiTietDiemDanhTheoNhanVienId]    Script Date: 10/29/2019 12:09:55 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROC [dbo].[ChiTietDiemDanhTheoNhanVienId]
(
	@Id INT,
	@Thang INT,
	@Nam INT
)
AS
BEGIN
SELECT [Id]
      ,[NhanVienId]
      ,[QuanLyId]
      ,CASE WHEN TrangThai = 1 THEN N'Có Mặt'
	  WHEN TrangThai = 2 THEN N'Trễ'
	  WHEN TrangThai = 3 THEN N'Vắng Không Phép'
	  WHEN TrangThai = 4 THEN N'Vắng Có Phép'
	  WHEN TrangThai = 5 THEN N'Vắng Theo Quy Định'
		END AS TrangThai
      ,FORMAT(Ngay,'ddd dd/MM/yyyy')AS Ngay
      ,[NgayTao]
      ,[NgaySua]
  FROM [dbo].[DiemDanh]
  WHERE NhanVienId = @Id AND MONTH(Ngay) = @Thang AND YEAR(Ngay) = @Nam
END

GO
/****** Object:  StoredProcedure [dbo].[LayNhanVienTheoId]    Script Date: 10/29/2019 12:09:55 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[LayNhanVienTheoId]
	@Id INT
AS 
BEGIN
SELECT nv.[Id]
	  ,CONCAT(nv.Ho,' ',nv.Ten) AS HoTen
      ,
		CASE WHEN GioiTinh = 0 THEN N'Nữ'
			ELSE N'Nam'
		END AS GioiTinh
      ,nv.[NgaySinh]
      ,nv.[SoChungMinh]
      ,nv.[SoDienThoai]
      ,nv.[Email]
      ,nv.[DiaChi]
      ,nv.[MaSoThue]
      ,nv.[HinhAnh]
      ,nv.[NgayTao]
      ,nv.[NgaySua]
      ,nv.[DangLamViec]
      ,nv.[DaXoa]
	  ,bp.Ten AS BoPhan
	  ,cv.Ten AS ChucVu
  FROM [dbo].[NhanVien] nv
		JOIN dbo.ChucVuNhanVien cvnv ON cvnv.NhanVienId = nv.Id
		JOIN dbo.ChucVu cv ON cv.Id = cvnv.ChucVuId
		JOIN dbo.BoPhan bp ON bp.Id = cvnv.BoPhanId
  WHERE nv.Id = @Id AND nv.DaXoa = 0 AND DangLamViec = 1
END

GO
/****** Object:  StoredProcedure [dbo].[sp_ChiTietDonXinPhep]    Script Date: 10/29/2019 12:09:55 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Báo		
-- Create date: 20191015
-- Description:	Chi Tiết Từng Đơn Xin Phép
-- =============================================
CREATE PROCEDURE [dbo].[sp_ChiTietDonXinPhep]
	-- Add the parameters for the stored procedure here
	@Id INT
AS
BEGIN

SELECT [Id]
      ,[NhanVienId]
      ,[QuanLyId]
       ,CASE	WHEN TinhTrang = 1 THEN N'Chờ'
			WHEN TinhTrang = 2 THEN N'Chấp Nhận'
			WHEN TinhTrang = 3 THEN N'Từ Chối'
			END
			AS TinhTrang
      ,[NgayBatDau]
      ,[NgayKetThuc]
      ,[SoPhepConLai]
      ,[SoNgayDaNghi]
      ,[NgayGui]
      ,[NgayPhanHoi]
      ,[GhiChu]
      ,[TraLoi]
  FROM [dbo].[DonXinPhep]
  WHERE Id = @Id

END

GO
/****** Object:  StoredProcedure [dbo].[sp_HienThiThongTinNhanVien]    Script Date: 10/29/2019 12:09:55 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[sp_HienThiThongTinNhanVien](
	@Id INT
 )
AS
BEGIN
	SELECT nv.Id,
		nv.Ho,
		nv.Ten,
		nv.GioiTinh,
		nv.NgaySinh,
		nv.SoChungMinh,
		nv.SoDienThoai,
		nv.Email,
		nv.DiaChi,
		nv.MaSoThue,
		nv.HinhAnh,
		nv.NgayTao,
		nv.NgaySua,
		nv.DangLamViec,
		tk.Id,
		cvnv.ChucVuId,
		cvnv.BoPhanId
	FROM NhanVien nv JOIN TaiKhoan tk ON nv.Id = tk.Id
	JOIN ChucVuNhanVien cvnv ON cvnv.NhanVienId=nv.Id
	WHERE nv.Id=@Id
END

GO
/****** Object:  StoredProcedure [dbo].[sp_ThongTinBoPhanTheoId]    Script Date: 10/29/2019 12:09:55 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[sp_ThongTinBoPhanTheoId](
	@Id INT)
	
AS
BEGIN
	
	SET NOCOUNT ON;
	SELECT bp.Id,bp.Ten,bp.DangHoatDong,(SELECT COUNT(*)  FROM  NhanVien nv JOIN ChucVuNhanVien cvnv ON nv .Id=cvnv.NhanVienId WHERE cvnv.BoPhanId=bp.Id AND
	 nv.DangLamViec=1)as SoLuong FROM BoPhan bp	
	 WHERE bp.Id=@Id
END

GO
/****** Object:  StoredProcedure [dbo].[TaoDonXinPhep]    Script Date: 10/29/2019 12:09:55 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Báo
-- Create date: 2019/10/09
-- Description:	Viết Đơn Xin Phép
-- =============================================
CREATE PROCEDURE [dbo].[TaoDonXinPhep]
(
	@NhanVienId INT,
	@NgayBatDau DATE,
	@NgayKetThuc DATE,
	@SoPhepConLai TINYINT,
	@SoNgayDaNghi TINYINT,
	@GhiChu NVARCHAR(MAX),
	@TraLoi NVARCHAR(MAX)
)
AS
BEGIN
DECLARE @BoPhanId INT = (SELECT BoPhanId FROM dbo.ChucVuNhanVien WHERE NhanVienId = @NhanVienId)
DECLARE @QuanLyId INT = (SELECT NhanVienId FROM dbo.ChucVuNhanVien WHERE BoPhanId = @BoPhanId AND ChucVuId = 1)

INSERT INTO [dbo].[DonXinPhep]
           ([NhanVienId]
           ,[QuanLyId]
           ,[TinhTrang]
           ,[NgayBatDau]
           ,[NgayKetThuc]
           ,[SoPhepConLai]
           ,[SoNgayDaNghi]
           ,[NgayGui]
           ,[NgayPhanHoi]
           ,[GhiChu]
           ,[TraLoi])
     VALUES
           (@NhanVienId
           ,@QuanLyId
           ,1
           ,@NgayBatDau
           ,@NgayKetThuc
           ,@SoPhepConLai
           ,@SoNgayDaNghi
           ,GETDATE()
           ,NULL
           ,@GhiChu
           ,NULL)
END

GO
/****** Object:  StoredProcedure [dbo].[TaoDonXinPhepView]    Script Date: 10/29/2019 12:09:55 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Báo
-- Create date: 2019/10/09
-- Description:	Xem Đơn Xin Phép
-- =============================================
CREATE PROCEDURE  [dbo].[TaoDonXinPhepView]
(
	@Id INT
)
AS
BEGIN
DECLARE @NgayHienTai DATE = GETDATE()
DECLARE @BoPhanId INT = (SELECT BoPhanId FROM dbo.ChucVuNhanVien WHERE NhanVienId = @Id)
SELECT tk.[NhanVienId]
      ,CONCAT(nv.Ho,' ',nv.Ten) AS HoTen
	  ,bp.Ten AS BoPhan
      ,tk.[Tre]
      ,tk.[KhongPhep]
      ,tk.[SoPhepConLai]
	  ,GETDATE() AS NgayBatDau
	  ,GETDATE() AS NgayKetThuc
	  ,GETDATE() AS NgayGui
	  ,(SELECT Email FROM dbo.NhanVien WHERE Id = (SELECT NhanVienId FROM dbo.ChucVuNhanVien WHERE BoPhanId = @BoPhanId AND ChucVuId = 1)) AS Email
FROM [dbo].[ThongKe] tk 
	FULL JOIN dbo.NhanVien nv ON nv.Id = tk.NhanVienId
	FULL JOIN dbo.ChucVuNhanVien cvnv ON cvnv.NhanVienId = nv.Id
	FULL JOIN dbo.BoPhan bp ON bp.Id = cvnv.BoPhanId
	WHERE tk.NhanVienId = @Id AND tk.Thang = MONTH(@NgayHienTai) AND tk.Nam = YEAR(@NgayHienTai) 
END

GO
/****** Object:  StoredProcedure [dbo].[ThongKeNhanVienTheoId]    Script Date: 10/29/2019 12:09:55 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [dbo].[ThongKeNhanVienTheoId]
(
	@Id INT
)
AS
BEGIN
SELECT 
	  TK.[Id]
	  ,CONCAT(NV.Ho,' ',NV.Ten) AS HoTen
      ,TK.[NhanVienId]
      ,TK.[Thang]
      ,TK.[Nam]
      ,TK.[CoMat]
      ,TK.[Tre]
      ,TK.[KhongPhep]
      ,TK.[CoPhep]
      ,TK.[TheoQuyDinh]
      ,TK.[SoPhepConLai]
  FROM [dbo].[ThongKe] TK JOIN dbo.NhanVien NV ON NV.Id = TK.NhanVienId
  WHERE TK.NhanVienId = @Id AND NV.DaXoa = 0 AND NV.DangLamViec = 1
END

GO
/****** Object:  StoredProcedure [dbo].[XemDonXinPhepNhanVienTheoId]    Script Date: 10/29/2019 12:09:55 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Báo
-- Create date: 2019/10/09
-- Description:	Xem Đơn Xin Phép
-- =============================================
CREATE PROCEDURE [dbo].[XemDonXinPhepNhanVienTheoId]
(
	@Id INT
)
AS
BEGIN
SELECT dxp.[Id]
      ,dxp.[NhanVienId]
	  ,CONCAT(nv.Ho,' ',nv.Ten) AS HoTen
      ,dxp.[QuanLyId]
      ,CASE	WHEN dxp.TinhTrang = 1 THEN N'Chờ'
			WHEN dxp.TinhTrang = 2 THEN N'Chấp Nhận'
			WHEN dxp.TinhTrang = 3 THEN N'Từ Chối'
			END
			AS TinhTrang
      ,dxp.[NgayBatDau]
      ,dxp.[NgayKetThuc]
      ,dxp.[SoPhepConLai]
      ,dxp.[SoNgayDaNghi]
      ,dxp.[NgayGui]
      ,dxp.[NgayPhanHoi]
      ,dxp.[GhiChu]
      ,dxp.[TraLoi]
  FROM [dbo].[DonXinPhep] dxp JOIN dbo.NhanVien nv ON nv.Id = dxp.NhanVienId
	WHERE nv.DaXoa = 0 AND nv.DangLamViec = 1 AND dxp.NhanVienId = @Id
  
END

GO
