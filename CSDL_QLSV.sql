USE master;
GO

IF DB_ID('QLSinhVien') IS NOT NULL
BEGIN
    ALTER DATABASE QLSinhVien SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
    DROP DATABASE QLSinhVien;
END
GO

CREATE DATABASE QLSinhVien;
GO

USE QLSinhVien;
GO

/* =========================
   1. TẠO BẢNG
========================= */

CREATE TABLE Khoa (
    MaKhoa VARCHAR(20) PRIMARY KEY,
    TenKhoa NVARCHAR(100) NOT NULL,
    DienThoai VARCHAR(15),
    Email VARCHAR(100) UNIQUE
);
GO

CREATE TABLE Nganh (
    MaNganh VARCHAR(20) PRIMARY KEY,
    TenNganh NVARCHAR(100) NOT NULL,
    MaKhoa VARCHAR(20) NOT NULL,
    CONSTRAINT FK_Nganh_Khoa FOREIGN KEY (MaKhoa) REFERENCES Khoa(MaKhoa)
);
GO

CREATE TABLE Lop (
    MaLop VARCHAR(20) PRIMARY KEY,
    TenLop NVARCHAR(100) NOT NULL,
    KhoaHoc VARCHAR(20),
    MaNganh VARCHAR(20) NOT NULL,
    CONSTRAINT FK_Lop_Nganh FOREIGN KEY (MaNganh) REFERENCES Nganh(MaNganh)
);
GO

CREATE TABLE SinhVien (
    MaSV VARCHAR(20) PRIMARY KEY,
    HoTen NVARCHAR(100) NOT NULL,
    NgaySinh DATE,
    GioiTinh NVARCHAR(10) CHECK (GioiTinh IN (N'Nam', N'Nữ')),
    DiaChi NVARCHAR(255),
    SoDienThoai VARCHAR(15),
    Email VARCHAR(100) UNIQUE,
    NgayNhapHoc DATE,
    TrangThai NVARCHAR(20) CHECK (TrangThai IN (N'Đang học', N'Bảo lưu', N'Tốt nghiệp', N'Thôi học')),
    MaLop VARCHAR(20) NOT NULL,
    CONSTRAINT FK_SinhVien_Lop FOREIGN KEY (MaLop) REFERENCES Lop(MaLop)
);
GO

CREATE TABLE GiangVien (
    MaGV VARCHAR(20) PRIMARY KEY,
    HoTen NVARCHAR(100) NOT NULL,
    NgaySinh DATE,
    GioiTinh NVARCHAR(10) CHECK (GioiTinh IN (N'Nam', N'Nữ')),
    SoDienThoai VARCHAR(15),
    Email VARCHAR(100) UNIQUE,
    HocVi NVARCHAR(50),
    MaKhoa VARCHAR(20) NOT NULL,
    CONSTRAINT FK_GiangVien_Khoa FOREIGN KEY (MaKhoa) REFERENCES Khoa(MaKhoa)
);
GO

CREATE TABLE MonHoc (
    MaMH VARCHAR(20) PRIMARY KEY,
    TenMH NVARCHAR(100) NOT NULL,
    SoTinChi INT CHECK (SoTinChi > 0),
    SoTiet INT CHECK (SoTiet > 0),
    MaMonTienQuyet VARCHAR(20),
    CONSTRAINT FK_MonHoc_MonTienQuyet FOREIGN KEY (MaMonTienQuyet) REFERENCES MonHoc(MaMH)
);
GO

CREATE TABLE HocKy (
    MaHK VARCHAR(20) PRIMARY KEY,
    TenHocKy NVARCHAR(50) NOT NULL,
    NamHoc VARCHAR(20) NOT NULL
);
GO

CREATE TABLE HocPhan (
    MaHP VARCHAR(20) PRIMARY KEY,
    MaMH VARCHAR(20) NOT NULL,
    MaGV VARCHAR(20) NOT NULL,
    MaHK VARCHAR(20) NOT NULL,
    PhongHoc NVARCHAR(20),
    LichHoc NVARCHAR(50),
    SiSoToiDa INT CHECK (SiSoToiDa > 0),
    CONSTRAINT FK_HocPhan_MonHoc FOREIGN KEY (MaMH) REFERENCES MonHoc(MaMH),
    CONSTRAINT FK_HocPhan_GiangVien FOREIGN KEY (MaGV) REFERENCES GiangVien(MaGV),
    CONSTRAINT FK_HocPhan_HocKy FOREIGN KEY (MaHK) REFERENCES HocKy(MaHK)
);
GO

CREATE TABLE BangDangKy (
    MaDK VARCHAR(20) PRIMARY KEY,
    MaSV VARCHAR(20) NOT NULL,
    MaHP VARCHAR(20) NOT NULL,
    NgayDangKy DATE DEFAULT GETDATE(),
    TrangThai NVARCHAR(50),
    CONSTRAINT FK_BangDangKy_SinhVien FOREIGN KEY (MaSV) REFERENCES SinhVien(MaSV),
    CONSTRAINT FK_BangDangKy_HocPhan FOREIGN KEY (MaHP) REFERENCES HocPhan(MaHP),
    CONSTRAINT UQ_BangDangKy UNIQUE (MaSV, MaHP)
);
GO

CREATE TABLE Diem (
    MaDiem VARCHAR(20) PRIMARY KEY,
    MaDK VARCHAR(20) NOT NULL UNIQUE,
    DiemQuaTrinh FLOAT CHECK (DiemQuaTrinh >= 0 AND DiemQuaTrinh <= 10),
    DiemThi FLOAT CHECK (DiemThi >= 0 AND DiemThi <= 10),
    DiemTongKet AS ROUND((ISNULL(DiemQuaTrinh, 0) * 0.4 + ISNULL(DiemThi, 0) * 0.6), 2),
    XepLoai AS (
        CASE
            WHEN ROUND((ISNULL(DiemQuaTrinh, 0) * 0.4 + ISNULL(DiemThi, 0) * 0.6), 2) >= 8.5 THEN N'Giỏi'
            WHEN ROUND((ISNULL(DiemQuaTrinh, 0) * 0.4 + ISNULL(DiemThi, 0) * 0.6), 2) >= 7.0 THEN N'Khá'
            WHEN ROUND((ISNULL(DiemQuaTrinh, 0) * 0.4 + ISNULL(DiemThi, 0) * 0.6), 2) >= 5.0 THEN N'Trung bình'
            ELSE N'Yếu'
        END
    ),
    CONSTRAINT FK_Diem_BangDangKy FOREIGN KEY (MaDK) REFERENCES BangDangKy(MaDK)
);
GO

/* =========================
   2. PROCEDURE
========================= */

CREATE PROCEDURE sp_ThemSinhVien
    @MaSV VARCHAR(20),
    @HoTen NVARCHAR(100),
    @NgaySinh DATE,
    @GioiTinh NVARCHAR(10),
    @DiaChi NVARCHAR(255),
    @SoDienThoai VARCHAR(15),
    @Email VARCHAR(100),
    @NgayNhapHoc DATE,
    @TrangThai NVARCHAR(20),
    @MaLop VARCHAR(20)
AS
BEGIN
    INSERT INTO SinhVien (
        MaSV, HoTen, NgaySinh, GioiTinh, DiaChi, SoDienThoai, Email, NgayNhapHoc, TrangThai, MaLop
    )
    VALUES (
        @MaSV, @HoTen, @NgaySinh, @GioiTinh, @DiaChi, @SoDienThoai, @Email, @NgayNhapHoc, @TrangThai, @MaLop
    );
END;
GO

CREATE PROCEDURE sp_CapNhatSinhVien
    @MaSV VARCHAR(20),
    @DiaChi NVARCHAR(255),
    @SoDienThoai VARCHAR(15)
AS
BEGIN
    UPDATE SinhVien
    SET DiaChi = @DiaChi,
        SoDienThoai = @SoDienThoai
    WHERE MaSV = @MaSV;
END;
GO

CREATE PROCEDURE sp_XoaSinhVien
    @MaSV VARCHAR(20)
AS
BEGIN
    DELETE d
    FROM Diem d
    INNER JOIN BangDangKy dk ON d.MaDK = dk.MaDK
    WHERE dk.MaSV = @MaSV;

    DELETE FROM BangDangKy
    WHERE MaSV = @MaSV;

    DELETE FROM SinhVien
    WHERE MaSV = @MaSV;
END;
GO

CREATE PROCEDURE sp_DangKyHocPhan
    @MaDK VARCHAR(20),
    @MaSV VARCHAR(20),
    @MaHP VARCHAR(20),
    @TrangThai NVARCHAR(50)
AS
BEGIN
    INSERT INTO BangDangKy (MaDK, MaSV, MaHP, TrangThai)
    VALUES (@MaDK, @MaSV, @MaHP, @TrangThai);
END;
GO

CREATE PROCEDURE sp_NhapDiem
    @MaDiem VARCHAR(20),
    @MaDK VARCHAR(20),
    @DiemQuaTrinh FLOAT,
    @DiemThi FLOAT
AS
BEGIN
    INSERT INTO Diem (MaDiem, MaDK, DiemQuaTrinh, DiemThi)
    VALUES (@MaDiem, @MaDK, @DiemQuaTrinh, @DiemThi);
END;
GO

/* =========================
   3. VIEW
========================= */

CREATE VIEW vw_DanhSachSinhVienTheoLop AS
SELECT 
    l.MaLop,
    l.TenLop,
    sv.MaSV,
    sv.HoTen,
    sv.NgaySinh,
    sv.GioiTinh,
    sv.Email
FROM Lop l
JOIN SinhVien sv ON l.MaLop = sv.MaLop;
GO

CREATE VIEW vw_DanhSachMonHocCuaSinhVien AS
SELECT 
    sv.MaSV,
    sv.HoTen,
    mh.MaMH,
    mh.TenMH,
    hp.MaHP,
    hk.MaHK,
    hk.TenHocKy,
    hk.NamHoc
FROM SinhVien sv
JOIN BangDangKy dk ON sv.MaSV = dk.MaSV
JOIN HocPhan hp ON dk.MaHP = hp.MaHP
JOIN MonHoc mh ON hp.MaMH = mh.MaMH
JOIN HocKy hk ON hp.MaHK = hk.MaHK;
GO

CREATE VIEW vw_DiemTrungBinhSinhVien AS
SELECT 
    sv.MaSV,
    sv.HoTen,
    ROUND(AVG(d.DiemTongKet), 2) AS DiemTrungBinh
FROM SinhVien sv
JOIN BangDangKy dk ON sv.MaSV = dk.MaSV
JOIN Diem d ON dk.MaDK = d.MaDK
GROUP BY sv.MaSV, sv.HoTen;
GO

CREATE VIEW vw_ThongKeSinhVienTheoKhoa AS
SELECT 
    k.MaKhoa,
    k.TenKhoa,
    COUNT(sv.MaSV) AS SoLuongSinhVien
FROM Khoa k
LEFT JOIN Nganh n ON k.MaKhoa = n.MaKhoa
LEFT JOIN Lop l ON n.MaNganh = l.MaNganh
LEFT JOIN SinhVien sv ON l.MaLop = sv.MaLop
GROUP BY k.MaKhoa, k.TenKhoa;
GO

CREATE VIEW vw_CanhBaoHocVu AS
SELECT 
    sv.MaSV,
    sv.HoTen,
    ROUND(AVG(d.DiemTongKet), 2) AS DiemTrungBinh
FROM SinhVien sv
JOIN BangDangKy dk ON sv.MaSV = dk.MaSV
JOIN Diem d ON dk.MaDK = d.MaDK
GROUP BY sv.MaSV, sv.HoTen
HAVING AVG(d.DiemTongKet) < 5;
GO

/* =========================
   4. TRIGGER
========================= */

CREATE TRIGGER trg_KiemTraSiSo
ON BangDangKy
AFTER INSERT
AS
BEGIN
    IF EXISTS (
        SELECT 1
        FROM inserted i
        JOIN HocPhan hp ON i.MaHP = hp.MaHP
        WHERE (
            SELECT COUNT(*)
            FROM BangDangKy dk
            WHERE dk.MaHP = i.MaHP
        ) > hp.SiSoToiDa
    )
    BEGIN
        RAISERROR (N'Sĩ số học phần đã đạt tối đa, không thể đăng ký thêm.', 16, 1);
        ROLLBACK TRANSACTION;
    END
END;
GO

/* =========================
   5. DỮ LIỆU MẪU
========================= */

INSERT INTO Khoa VALUES
('CNTT', N'Công nghệ thông tin', '0281111111', 'cntt@uni.edu.vn'),
('QTKD', N'Quản trị kinh doanh', '0282222222', 'qtkd@uni.edu.vn');
GO

INSERT INTO Nganh VALUES
('CNPM', N'Công nghệ phần mềm', 'CNTT'),
('HTTT', N'Hệ thống thông tin', 'CNTT'),
('MARK', N'Marketing', 'QTKD');
GO

INSERT INTO Lop VALUES
('DHKTPM01', N'Đại học KTPM 01', '2022-2026', 'CNPM'),
('DHKTHT01', N'Đại học KTHT 01', '2022-2026', 'HTTT'),
('DHKTMK01', N'Đại học KTMK 01', '2022-2026', 'MARK');
GO

INSERT INTO SinhVien VALUES
('SV001', N'Nguyễn Văn An', '2004-01-10', N'Nam', N'Hà Nội', '0901111111', 'sv001@gmail.com', '2022-09-01', N'Đang học', 'DHKTPM01'),
('SV002', N'Trần Thị Bình', '2004-03-15', N'Nữ', N'Hải Phòng', '0902222222', 'sv002@gmail.com', '2022-09-01', N'Đang học', 'DHKTPM01'),
('SV003', N'Lê Minh Châu', '2004-07-20', N'Nam', N'Đà Nẵng', '0903333333', 'sv003@gmail.com', '2022-09-01', N'Đang học', 'DHKTHT01');
GO

INSERT INTO GiangVien VALUES
('GV001', N'Phạm Quốc Hùng', '1980-02-20', N'Nam', '0911111111', 'gv001@uni.edu.vn', N'Tiến sĩ', 'CNTT'),
('GV002', N'Nguyễn Thị Lan', '1985-08-12', N'Nữ', '0922222222', 'gv002@uni.edu.vn', N'Thạc sĩ', 'CNTT'),
('GV003', N'Trần Văn Nam', '1982-11-05', N'Nam', '0933333333', 'gv003@uni.edu.vn', N'Thạc sĩ', 'QTKD');
GO

INSERT INTO MonHoc VALUES
('CSDL', N'Cơ sở dữ liệu', 3, 45, NULL),
('LTW', N'Lập trình web', 3, 45, 'CSDL'),
('PTTK', N'Phân tích thiết kế hệ thống', 3, 45, NULL),
('MKT01', N'Nguyên lý marketing', 2, 30, NULL);
GO

INSERT INTO HocKy VALUES
('HK1_2024', N'Học kỳ 1', '2024-2025'),
('HK2_2024', N'Học kỳ 2', '2024-2025');
GO

INSERT INTO HocPhan VALUES
('HP001', 'CSDL', 'GV001', 'HK1_2024', N'P101', N'T2-1,2,3', 2),
('HP002', 'LTW', 'GV002', 'HK2_2024', N'P102', N'T3-1,2,3', 30),
('HP003', 'PTTK', 'GV001', 'HK1_2024', N'P103', N'T4-1,2,3', 25),
('HP004', 'MKT01', 'GV003', 'HK1_2024', N'P201', N'T5-1,2', 20);
GO

INSERT INTO BangDangKy VALUES
('DK001', 'SV001', 'HP001', GETDATE(), N'Đã đăng ký'),
('DK002', 'SV002', 'HP001', GETDATE(), N'Đã đăng ký'),
('DK003', 'SV003', 'HP003', GETDATE(), N'Đã đăng ký');
GO

INSERT INTO Diem (MaDiem, MaDK, DiemQuaTrinh, DiemThi) VALUES
('D001', 'DK001', 8.0, 9.0),
('D002', 'DK002', 6.5, 7.0),
('D003', 'DK003', 4.0, 5.0);
GO

/* =========================
   6. CÂU LỆNH TEST
========================= */

-- Xem danh sách sinh viên theo lớp
SELECT * FROM vw_DanhSachSinhVienTheoLop;
GO

-- Xem danh sách môn học của sinh viên
SELECT * FROM vw_DanhSachMonHocCuaSinhVien;
GO

-- Xem điểm trung bình sinh viên
SELECT * FROM vw_DiemTrungBinhSinhVien;
GO

-- Thống kê sinh viên theo khoa
SELECT * FROM vw_ThongKeSinhVienTheoKhoa;
GO

-- Cảnh báo học vụ
SELECT * FROM vw_CanhBaoHocVu;
GO