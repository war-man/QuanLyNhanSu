﻿using System;

namespace CaseStudy.Live.Models.QuanLy.Request
{
    public class LayDiemDanhNhanVienId : BaseRequest
    {
        public int NhanVienId { get; set; }
        public DateTime Ngay { get; set; }
    }
}
