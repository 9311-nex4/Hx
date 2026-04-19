local ChuDe = {}

local CHU_TRANG = Color3.fromRGB(240, 240, 240)
local CHU_MO = Color3.fromRGB(180, 180, 180)
local NUT_DONG = Color3.fromRGB(80, 80, 80)
local NUT_DONG_LUOT = Color3.fromRGB(200, 0, 0)

ChuDe.DanhSach = {
	{
		Ten = "Dark",
		Nen = Color3.fromRGB(15, 15, 15), NenList = Color3.fromRGB(25, 25, 25), NenKhoi = Color3.fromRGB(32, 32, 32),
		NenMuc = Color3.fromRGB(50, 50, 50), NenHop = Color3.fromRGB(15, 15, 15), NenDanhSachMo = Color3.fromRGB(65, 70, 75),
		VienHop = Color3.fromRGB(80, 80, 80), VienNeon = Color3.fromRGB(255, 255, 255), NenPhu = Color3.fromRGB(45, 45, 45),
		ChonPhu = Color3.fromRGB(60, 60, 60), TichBat = Color3.fromRGB(255, 255, 255),
		NutDong = NUT_DONG, NutDongLuot = NUT_DONG_LUOT, Chu = CHU_TRANG, ChuMo = CHU_MO
	},
	{
		Ten = "Matrix",
		Nen = Color3.fromRGB(8, 18, 10), NenList = Color3.fromRGB(12, 24, 15), NenKhoi = Color3.fromRGB(15, 30, 18),
		NenMuc = Color3.fromRGB(20, 40, 25), NenHop = Color3.fromRGB(8, 18, 10), NenDanhSachMo = Color3.fromRGB(25, 50, 30),
		VienHop = Color3.fromRGB(30, 60, 40), VienNeon = Color3.fromRGB(0, 255, 70), NenPhu = Color3.fromRGB(18, 35, 22),
		ChonPhu = Color3.fromRGB(25, 50, 30), TichBat = Color3.fromRGB(0, 255, 70),
		NutDong = NUT_DONG, NutDongLuot = NUT_DONG_LUOT, Chu = CHU_TRANG, ChuMo = CHU_MO
	},
	{
		Ten = "Ocean",
		Nen = Color3.fromRGB(8, 15, 22), NenList = Color3.fromRGB(12, 20, 30), NenKhoi = Color3.fromRGB(15, 25, 35),
		NenMuc = Color3.fromRGB(20, 35, 50), NenHop = Color3.fromRGB(8, 15, 22), NenDanhSachMo = Color3.fromRGB(25, 45, 65),
		VienHop = Color3.fromRGB(30, 55, 80), VienNeon = Color3.fromRGB(0, 200, 255), NenPhu = Color3.fromRGB(18, 30, 45),
		ChonPhu = Color3.fromRGB(25, 40, 60), TichBat = Color3.fromRGB(0, 200, 255),
		NutDong = NUT_DONG, NutDongLuot = NUT_DONG_LUOT, Chu = CHU_TRANG, ChuMo = CHU_MO
	},
	{
		Ten = "Violet",
		Nen = Color3.fromRGB(15, 8, 22), NenList = Color3.fromRGB(22, 12, 32), NenKhoi = Color3.fromRGB(28, 15, 40),
		NenMuc = Color3.fromRGB(38, 20, 55), NenHop = Color3.fromRGB(15, 8, 22), NenDanhSachMo = Color3.fromRGB(45, 25, 65),
		VienHop = Color3.fromRGB(55, 35, 80), VienNeon = Color3.fromRGB(200, 100, 255), NenPhu = Color3.fromRGB(32, 18, 48),
		ChonPhu = Color3.fromRGB(42, 22, 60), TichBat = Color3.fromRGB(200, 100, 255),
		NutDong = NUT_DONG, NutDongLuot = NUT_DONG_LUOT, Chu = CHU_TRANG, ChuMo = CHU_MO
	},
	{
		Ten = "Crimson",
		Nen = Color3.fromRGB(20, 8, 8), NenList = Color3.fromRGB(30, 12, 12), NenKhoi = Color3.fromRGB(38, 15, 15),
		NenMuc = Color3.fromRGB(50, 20, 20), NenHop = Color3.fromRGB(20, 8, 8), NenDanhSachMo = Color3.fromRGB(60, 25, 25),
		VienHop = Color3.fromRGB(70, 35, 35), VienNeon = Color3.fromRGB(255, 60, 60), NenPhu = Color3.fromRGB(42, 18, 18),
		ChonPhu = Color3.fromRGB(55, 22, 22), TichBat = Color3.fromRGB(255, 60, 60),
		NutDong = NUT_DONG, NutDongLuot = NUT_DONG_LUOT, Chu = CHU_TRANG, ChuMo = CHU_MO
	},
	{
		Ten = "Gold",
		Nen = Color3.fromRGB(20, 16, 6), NenList = Color3.fromRGB(30, 24, 10), NenKhoi = Color3.fromRGB(38, 30, 12),
		NenMuc = Color3.fromRGB(50, 40, 18), NenHop = Color3.fromRGB(20, 16, 6), NenDanhSachMo = Color3.fromRGB(60, 48, 22),
		VienHop = Color3.fromRGB(70, 55, 28), VienNeon = Color3.fromRGB(255, 200, 50), NenPhu = Color3.fromRGB(42, 34, 15),
		ChonPhu = Color3.fromRGB(55, 44, 20), TichBat = Color3.fromRGB(255, 200, 50),
		NutDong = NUT_DONG, NutDongLuot = NUT_DONG_LUOT, Chu = CHU_TRANG, ChuMo = CHU_MO
	},
	{
		Ten = "Sakura",
		Nen = Color3.fromRGB(22, 10, 15), NenList = Color3.fromRGB(32, 15, 22), NenKhoi = Color3.fromRGB(40, 18, 28),
		NenMuc = Color3.fromRGB(55, 25, 38), NenHop = Color3.fromRGB(22, 10, 15), NenDanhSachMo = Color3.fromRGB(65, 30, 45),
		VienHop = Color3.fromRGB(80, 40, 55), VienNeon = Color3.fromRGB(255, 140, 185), NenPhu = Color3.fromRGB(48, 22, 32),
		ChonPhu = Color3.fromRGB(60, 28, 40), TichBat = Color3.fromRGB(255, 140, 185),
		NutDong = NUT_DONG, NutDongLuot = NUT_DONG_LUOT, Chu = CHU_TRANG, ChuMo = CHU_MO
	},
	{
		Ten = "Emerald",
		Nen = Color3.fromRGB(6, 18, 10), NenList = Color3.fromRGB(10, 25, 14), NenKhoi = Color3.fromRGB(14, 32, 18),
		NenMuc = Color3.fromRGB(20, 45, 25), NenHop = Color3.fromRGB(6, 18, 10), NenDanhSachMo = Color3.fromRGB(25, 55, 30),
		VienHop = Color3.fromRGB(35, 70, 40), VienNeon = Color3.fromRGB(50, 255, 120), NenPhu = Color3.fromRGB(16, 38, 20),
		ChonPhu = Color3.fromRGB(22, 50, 28), TichBat = Color3.fromRGB(50, 255, 120),
		NutDong = NUT_DONG, NutDongLuot = NUT_DONG_LUOT, Chu = CHU_TRANG, ChuMo = CHU_MO
	},
	{
		Ten = "Cyberpunk",
		Nen = Color3.fromRGB(18, 16, 4), NenList = Color3.fromRGB(26, 24, 6), NenKhoi = Color3.fromRGB(34, 30, 8),
		NenMuc = Color3.fromRGB(45, 40, 12), NenHop = Color3.fromRGB(18, 16, 4), NenDanhSachMo = Color3.fromRGB(55, 48, 15),
		VienHop = Color3.fromRGB(65, 58, 20), VienNeon = Color3.fromRGB(255, 230, 0), NenPhu = Color3.fromRGB(38, 34, 10),
		ChonPhu = Color3.fromRGB(50, 45, 14), TichBat = Color3.fromRGB(255, 230, 0),
		NutDong = NUT_DONG, NutDongLuot = NUT_DONG_LUOT, Chu = CHU_TRANG, ChuMo = CHU_MO
	},
	{
		Ten = "Ice",
		Nen = Color3.fromRGB(10, 16, 22), NenList = Color3.fromRGB(15, 22, 30), NenKhoi = Color3.fromRGB(18, 28, 38),
		NenMuc = Color3.fromRGB(25, 38, 50), NenHop = Color3.fromRGB(10, 16, 22), NenDanhSachMo = Color3.fromRGB(30, 45, 60),
		VienHop = Color3.fromRGB(40, 60, 80), VienNeon = Color3.fromRGB(145, 228, 255), NenPhu = Color3.fromRGB(22, 34, 45),
		ChonPhu = Color3.fromRGB(28, 42, 55), TichBat = Color3.fromRGB(145, 228, 255),
		NutDong = NUT_DONG, NutDongLuot = NUT_DONG_LUOT, Chu = CHU_TRANG, ChuMo = CHU_MO
	},
	{
		Ten = "Sunset",
		Nen = Color3.fromRGB(22, 12, 8), NenList = Color3.fromRGB(32, 18, 12), NenKhoi = Color3.fromRGB(40, 22, 15),
		NenMuc = Color3.fromRGB(55, 30, 20), NenHop = Color3.fromRGB(22, 12, 8), NenDanhSachMo = Color3.fromRGB(65, 38, 25),
		VienHop = Color3.fromRGB(80, 48, 32), VienNeon = Color3.fromRGB(255, 115, 55), NenPhu = Color3.fromRGB(48, 26, 18),
		ChonPhu = Color3.fromRGB(60, 34, 22), TichBat = Color3.fromRGB(255, 115, 55),
		NutDong = NUT_DONG, NutDongLuot = NUT_DONG_LUOT, Chu = CHU_TRANG, ChuMo = CHU_MO
	},
	{
		Ten = "Neon",
		Nen = Color3.fromRGB(6, 18, 15), NenList = Color3.fromRGB(10, 25, 22), NenKhoi = Color3.fromRGB(12, 32, 28),
		NenMuc = Color3.fromRGB(18, 45, 38), NenHop = Color3.fromRGB(6, 18, 15), NenDanhSachMo = Color3.fromRGB(24, 55, 48),
		VienHop = Color3.fromRGB(30, 70, 60), VienNeon = Color3.fromRGB(0, 255, 195), NenPhu = Color3.fromRGB(15, 38, 32),
		ChonPhu = Color3.fromRGB(20, 50, 42), TichBat = Color3.fromRGB(0, 255, 195),
		NutDong = NUT_DONG, NutDongLuot = NUT_DONG_LUOT, Chu = CHU_TRANG, ChuMo = CHU_MO
	}
}

ChuDe.MacDinh = ChuDe.DanhSach[1]

return ChuDe