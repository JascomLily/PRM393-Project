import React, { useState } from 'react';
import { INITIAL_SPARE_PARTS } from '../data/mockData';
import { MissingReportItem, Order, SparePartItem } from '../types';

interface PartsViewProps {
  orders: Order[];
  missingReports: MissingReportItem[];
  onSubmitMissingReport: (report: MissingReportItem) => void;
  onAddToCart: (item: { id: string; name: string; price: number; image: string; variant?: string }) => void;
  onShowToast: (msg: string) => void;
}

export const PartsView: React.FC<PartsViewProps> = ({
  orders,
  onSubmitMissingReport,
  onAddToCart,
  onShowToast,
}) => {
  const [activeTab, setActiveTab] = useState<'report' | 'store'>('report');

  // Quantities for missing parts
  const [qtyP04, setQtyP04] = useState<number>(2);
  const [qtyH02, setQtyH02] = useState<number>(1);
  const [qtyC11, setQtyC11] = useState<number>(4);
  const [notes, setNotes] = useState<string>('');
  const [isSubmitting, setIsSubmitting] = useState<boolean>(false);
  const [isSuccessToast, setIsSuccessToast] = useState<boolean>(false);
  const [selectedOrderCode, setSelectedOrderCode] = useState<string>('#F3D-88219');
  const [isPickerModalOpen, setIsPickerModalOpen] = useState<boolean>(false);

  // Photos
  const [photos, setPhotos] = useState<Array<{ label: string; code: string; url: string }>>([
    {
      label: 'Mã vạch kiện hàng',
      code: 'BARCODE-88219',
      url: 'https://lh3.googleusercontent.com/aida-public/AB6AXuDaMsbielXE4UKJyDTVfSZfUsidmZPOlyE_4iUplFFVfvjS7HR0u4EwnIXjc_HeyRGBkZ_V8SG_oA16TUwOGAtWm8C8B-ZEtUMk0tR5TMRT1hqApFrnDckPruiCNgyDV_Z9ngtXT8lvmW9MeLr2fGCayZksP_ViDaXkOiOmogBiumqdjeaO_Sv0eFxQNkQP4iWEUehcaInrCI9pA8kWAP728qqUaA8nCRfjQBdyy-DZZ6gfIZw4DovYtA',
    },
    {
      label: 'Vết móp bản lề',
      code: 'IMG_DEFECT_02.JPG',
      url: 'https://lh3.googleusercontent.com/aida-public/AB6AXuA4yOfkMerutETdW9gqaI-RwrX7veoV63sKbbp2TeA9NpcV-fqiUPoYCJanoky7D9ddNh69IB2s1ODOtApAO-vdhXXROVmS7Idcowvs8lFiuhsCvZEWI1VeQYI4TYVqusorqc_AXrZQta0H-kgbQNOtIwQX2AXV2GmnLehv1-A4pYTkwByrzPb0BiM7AaRChvZa-vtP2vQH0PGdZrt1L73AZxSD567yRnMBpQbBBZ0XXFbT46nkJFs5FA',
    },
  ]);

  const handleSubmit = () => {
    setIsSubmitting(true);
    setTimeout(() => {
      const newReport: MissingReportItem = {
        id: `rep-${Date.now()}`,
        orderId: selectedOrderCode,
        productName: 'Bàn Nordic Oak Desk',
        productModel: 'MODEL ND-2024',
        customerName: 'Đặng Thảo Vy',
        phone: '0983 838 311',
        address: 'Tòa nhà Landmark 81, P. 22, Q. Bình Thạnh, TP. Hồ Chí Minh',
        createdAt: new Date().toLocaleString('vi-VN'),
        status: 'pending',
        parts: [
          {
            code: '#P-04',
            name: 'Ốc khóa chốt cam M6x35',
            quantity: qtyP04,
            reason: 'Bị thiếu theo gói',
            image: 'https://lh3.googleusercontent.com/aida-public/AB6AXuAuSaFeYwi2_aiQ8FJyFiYxLlCdx9tkC8hBVFpxC9-NY65PendMQBhS8Odo7tVZ9QV1xihDGxAQcQLRG5HKu1VeUzLp126Uiwk_eg1V38UAO8gvInP9pd_do0GYY2Mrz3oLkekkJyx43VWXiHj3JzBWs9thiJIIrhr8dBVxR3UbYIeB7qjDofpddHxBS5p0iJ7iiUrH04AaY5LKBEC1s_KFvH285beCyOXWszpSh108gUMFUp6WNZlDTg',
          },
          {
            code: '#H-02',
            name: 'Bản lề giảm chấn cánh tủ',
            quantity: qtyH02,
            reason: 'Móp méo / Bị nứt piston',
            image: 'https://lh3.googleusercontent.com/aida-public/AB6AXuAWe7suuECGbv-OCohht3y0Yo2k4Bnvizj9rlCCTYE06Q4zOEDBYhapLHeAnFWWC-ybiY1AHFZwdEDIFjcJYd47AAgt6_Hx1HmE0bESTOh1-M9vZyO1_2-0LLXPBAvtoKWUKaCW93Zr6GVompfrl0GrU--eS5kXieWfVOTqxs4S8gPR-SIy-GJ09mfW5xcYX4XycNbUNSCUHJ7KrlyhMmdJDcGUfqMQLlxXBTsk6Hrlqefo4qo5Uwj5bw',
          },
          {
            code: '#C-11',
            name: 'Nắp che lỗ ốc màu sồi',
            quantity: qtyC11,
            reason: 'Thiếu vỉ phụ kiện',
            image: 'https://lh3.googleusercontent.com/aida-public/AB6AXuBjyXyIyMbJB1n407UhmuA0i2xR4xUsYNdtB3vlN_mR4spyrhCG2y4tDMKoMFu-knJLHbu8Kb1lT_zvePWf7nWzrmqRq3Ja8f_Pidb3iEBVwjkpEFh4UlV60cBZqRGAnALldChhBMqTuu0lH_Toysk6Ey-avQ97j33O_JEXMu9gFmWwFlOOSNhBR1rVO5v-zyHxo-Y7tgaz5QymjJCAXNFa4rKLRZA0Ey3VlBUV-LOSYkoYYfnye4FtAg',
          },
        ],
        evidencePhotos: photos,
        notes: notes || 'Khách hàng yêu cầu kiểm đếm và giao bù phụ kiện sớm.',
      };

      onSubmitMissingReport(newReport);
      setIsSubmitting(false);
      setIsSuccessToast(true);
      setTimeout(() => setIsSuccessToast(false), 4000);
      onShowToast('Yêu cầu cấp bù linh kiện đã được ghi nhận. Furni3D sẽ gửi hỏa tốc trong 24-48h!');
    }, 700);
  };

  return (
    <div className="flex flex-col w-full max-w-5xl mx-auto pb-10">
      {/* Top Segmented Tab Switcher */}
      <div className="px-4 pt-3 pb-2">
        <div className="bg-[#e9edff] p-1 rounded-xl flex items-stretch max-w-md mx-auto">
          <button
            onClick={() => setActiveTab('report')}
            className={`flex-1 py-2 px-2.5 rounded-lg text-xs font-bold shadow-sm flex items-center justify-center gap-1.5 transition-all duration-200 ${
              activeTab === 'report'
                ? 'bg-white text-[#134230] shadow-sm'
                : 'text-[#414944] hover:text-[#161b28]'
            }`}
          >
            <span className="material-symbols-outlined text-[18px]">verified_user</span>
            <span className="truncate">Báo thiếu / hỏng (Miễn phí)</span>
          </button>
          <button
            onClick={() => setActiveTab('store')}
            className={`flex-1 py-2 px-2.5 rounded-lg text-xs font-bold flex items-center justify-center gap-1.5 transition-all duration-200 ${
              activeTab === 'store'
                ? 'bg-white text-[#134230] shadow-sm'
                : 'text-[#414944] hover:text-[#161b28]'
            }`}
          >
            <span className="material-symbols-outlined text-[18px]">shopping_bag</span>
            <span className="truncate">Mua linh kiện thay thế</span>
          </button>
        </div>
      </div>

      {/* VIEW 1: BÁO THIẾU / HỎNG MIỄN PHÍ */}
      {activeTab === 'report' && (
        <div className="flex flex-col gap-3 px-4">
          {/* Recent Order Selection Card */}
          <div className="bg-white p-4 rounded-xl shadow-sm flex flex-col gap-3 border border-black/[0.04]">
            <div className="flex items-center justify-between">
              <div className="flex items-center gap-2">
                <span className="material-symbols-outlined text-[#805528] text-[20px]">
                  local_shipping
                </span>
                <span className="text-xs font-bold text-[#414944] uppercase tracking-wider">
                  Đơn hàng vừa nhận
                </span>
              </div>
              <span className="px-2 py-0.5 rounded-full bg-[#bceed3] text-[#002114] text-[10px] font-bold uppercase">
                Đã giao
              </span>
            </div>

            <div className="flex items-center gap-3 p-2.5 bg-[#f2f3ff] rounded-lg">
              <div className="w-14 h-14 rounded-lg bg-white flex-shrink-0 overflow-hidden relative shadow-sm">
                <img
                  className="w-full h-full object-cover"
                  src="https://lh3.googleusercontent.com/aida-public/AB6AXuCtvxILoDbENj9QfvWHeMFBYvMiHv-F5_Wfc-22xXHTkRI6HSnKMSZdufZi7YsW3t5LrU8ETlZ97hPFaD2uEl37xPVCup9S9Zl8jVbZpLGTS22J0k4tBqfxF3zNN0oLDDi74rQU2fDfE1eebGJKZvkDV_5Dsq1_uHjLf_GA789TENj-ep22eGjirYPzxtvmRO0sBiZ5qWMP-P7LIMDfD4lMlmoiuLBZLO4DJiSaqIleE5gexW1oMSzmEA"
                  alt="Bàn Nordic Oak Desk"
                />
              </div>
              <div className="flex flex-col min-w-0 flex-1">
                <span className="text-sm font-bold text-[#161b28] truncate">
                  Bàn Nordic Oak Desk
                </span>
                <p className="text-xs text-[#414944] truncate">Mã đơn: {selectedOrderCode}</p>
                <p className="text-xs text-[#805528] flex items-center gap-1 mt-0.5 font-medium">
                  <span className="material-symbols-outlined text-[14px]">calendar_today</span>
                  <span>Giao ngày 12/03/2025</span>
                </p>
              </div>
              <button
                onClick={() => {
                  const codes = orders.map((o) => o.code);
                  const nextCode = codes[(codes.indexOf(selectedOrderCode) + 1) % codes.length];
                  setSelectedOrderCode(nextCode);
                  onShowToast(`Đã chuyển sang đơn hàng: ${nextCode}`);
                }}
                title="Đổi đơn hàng"
                className="w-8 h-8 rounded-full bg-white flex items-center justify-center text-[#414944] shadow-sm flex-shrink-0 hover:bg-[#e9edff] transition-colors"
              >
                <span className="material-symbols-outlined text-[18px]">swap_horiz</span>
              </button>
            </div>
          </div>

          {/* Missing Parts List */}
          <div className="bg-white p-4 rounded-xl shadow-sm flex flex-col gap-3.5 border border-black/[0.04]">
            <div className="flex items-center justify-between">
              <div className="flex flex-col">
                <h2 className="text-sm font-bold text-[#161b28]">Linh kiện cần bổ sung</h2>
                <span className="text-xs text-[#414944]">Chọn phụ kiện thiếu hoặc lỗi theo bản vẽ 3D</span>
              </div>
              <span className="w-7 h-7 rounded-full bg-[#fec38d] text-[#794f23] flex items-center justify-center text-xs font-bold">
                3
              </span>
            </div>

            <div className="flex flex-col gap-2.5">
              {/* Part 1 */}
              <div className="p-3 bg-[#f2f3ff] rounded-xl flex items-center gap-3">
                <div className="w-12 h-12 rounded-lg bg-white flex items-center justify-center flex-shrink-0 p-1 shadow-sm overflow-hidden">
                  <img
                    className="w-full h-full object-contain"
                    src="https://lh3.googleusercontent.com/aida-public/AB6AXuAuSaFeYwi2_aiQ8FJyFiYxLlCdx9tkC8hBVFpxC9-NY65PendMQBhS8Odo7tVZ9QV1xihDGxAQcQLRG5HKu1VeUzLp126Uiwk_eg1V38UAO8gvInP9pd_do0GYY2Mrz3oLkekkJyx43VWXiHj3JzBWs9thiJIIrhr8dBVxR3UbYIeB7qjDofpddHxBS5p0iJ7iiUrH04AaY5LKBEC1s_KFvH285beCyOXWszpSh108gUMFUp6WNZlDTg"
                    alt="Ốc khóa chốt cam M6x35"
                  />
                </div>
                <div className="flex flex-col flex-1 min-w-0">
                  <div className="flex items-center justify-between gap-1">
                    <span className="text-xs font-bold text-[#161b28] truncate">
                      Ốc khóa chốt cam M6x35
                    </span>
                    <span className="text-[10px] px-1.5 py-0.5 rounded bg-[#e3e7fa] text-[#414944] font-bold flex-shrink-0">
                      #P-04
                    </span>
                  </div>
                  <span className="text-xs text-[#ba1a1a] font-medium">Bị thiếu theo gói</span>
                  <div className="flex items-center justify-between mt-1">
                    <span className="text-xs text-[#414944]">Số lượng thiếu:</span>
                    <div className="flex items-center bg-white rounded-lg p-0.5 shadow-sm border border-black/5">
                      <button
                        onClick={() => setQtyP04(Math.max(1, qtyP04 - 1))}
                        className="w-6 h-6 flex items-center justify-center text-[#414944] hover:text-[#161b28] rounded active:scale-95"
                      >
                        <span className="material-symbols-outlined text-[16px]">remove</span>
                      </button>
                      <span className="w-7 text-center text-xs font-bold text-[#2d5a46]">
                        {qtyP04}
                      </span>
                      <button
                        onClick={() => setQtyP04(qtyP04 + 1)}
                        className="w-6 h-6 flex items-center justify-center text-[#414944] hover:text-[#161b28] rounded active:scale-95"
                      >
                        <span className="material-symbols-outlined text-[16px]">add</span>
                      </button>
                    </div>
                  </div>
                </div>
              </div>

              {/* Part 2 */}
              <div className="p-3 bg-[#f2f3ff] rounded-xl flex items-center gap-3">
                <div className="w-12 h-12 rounded-lg bg-white flex items-center justify-center flex-shrink-0 p-1 shadow-sm overflow-hidden">
                  <img
                    className="w-full h-full object-contain"
                    src="https://lh3.googleusercontent.com/aida-public/AB6AXuAWe7suuECGbv-OCohht3y0Yo2k4Bnvizj9rlCCTYE06Q4zOEDBYhapLHeAnFWWC-ybiY1AHFZwdEDIFjcJYd47AAgt6_Hx1HmE0bESTOh1-M9vZyO1_2-0LLXPBAvtoKWUKaCW93Zr6GVompfrl0GrU--eS5kXieWfVOTqxs4S8gPR-SIy-GJ09mfW5xcYX4XycNbUNSCUHJ7KrlyhMmdJDcGUfqMQLlxXBTsk6Hrlqefo4qo5Uwj5bw"
                    alt="Bản lề giảm chấn"
                  />
                </div>
                <div className="flex flex-col flex-1 min-w-0">
                  <div className="flex items-center justify-between gap-1">
                    <span className="text-xs font-bold text-[#161b28] truncate">
                      Bản lề giảm chấn cánh tủ
                    </span>
                    <span className="text-[10px] px-1.5 py-0.5 rounded bg-[#e3e7fa] text-[#414944] font-bold flex-shrink-0">
                      #H-02
                    </span>
                  </div>
                  <div className="flex items-center gap-1.5 mt-0.5">
                    <span className="w-2 h-2 rounded-full bg-[#ba1a1a] flex-shrink-0" />
                    <span className="text-xs text-[#ba1a1a] font-medium truncate">
                      Móp méo / Bị nứt piston
                    </span>
                  </div>
                  <div className="flex items-center justify-between mt-1">
                    <span className="text-xs text-[#414944]">Số lượng lỗi:</span>
                    <div className="flex items-center bg-white rounded-lg p-0.5 shadow-sm border border-black/5">
                      <button
                        onClick={() => setQtyH02(Math.max(1, qtyH02 - 1))}
                        className="w-6 h-6 flex items-center justify-center text-[#414944] hover:text-[#161b28] rounded active:scale-95"
                      >
                        <span className="material-symbols-outlined text-[16px]">remove</span>
                      </button>
                      <span className="w-7 text-center text-xs font-bold text-[#2d5a46]">
                        {qtyH02}
                      </span>
                      <button
                        onClick={() => setQtyH02(qtyH02 + 1)}
                        className="w-6 h-6 flex items-center justify-center text-[#414944] hover:text-[#161b28] rounded active:scale-95"
                      >
                        <span className="material-symbols-outlined text-[16px]">add</span>
                      </button>
                    </div>
                  </div>
                </div>
              </div>

              {/* Part 3 */}
              <div className="p-3 bg-[#f2f3ff] rounded-xl flex items-center gap-3">
                <div className="w-12 h-12 rounded-lg bg-white flex items-center justify-center flex-shrink-0 p-1 shadow-sm overflow-hidden">
                  <img
                    className="w-full h-full object-contain"
                    src="https://lh3.googleusercontent.com/aida-public/AB6AXuBjyXyIyMbJB1n407UhmuA0i2xR4xUsYNdtB3vlN_mR4spyrhCG2y4tDMKoMFu-knJLHbu8Kb1lT_zvePWf7nWzrmqRq3Ja8f_Pidb3iEBVwjkpEFh4UlV60cBZqRGAnALldChhBMqTuu0lH_Toysk6Ey-avQ97j33O_JEXMu9gFmWwFlOOSNhBR1rVO5v-zyHxo-Y7tgaz5QymjJCAXNFa4rKLRZA0Ey3VlBUV-LOSYkoYYfnye4FtAg"
                    alt="Nắp che lỗ ốc"
                  />
                </div>
                <div className="flex flex-col flex-1 min-w-0">
                  <div className="flex items-center justify-between gap-1">
                    <span className="text-xs font-bold text-[#161b28] truncate">
                      Nắp che lỗ ốc màu sồi
                    </span>
                    <span className="text-[10px] px-1.5 py-0.5 rounded bg-[#e3e7fa] text-[#414944] font-bold flex-shrink-0">
                      #C-11
                    </span>
                  </div>
                  <span className="text-xs text-[#ba1a1a] font-medium">Thiếu vỉ phụ kiện</span>
                  <div className="flex items-center justify-between mt-1">
                    <span className="text-xs text-[#414944]">Số lượng thiếu:</span>
                    <div className="flex items-center bg-white rounded-lg p-0.5 shadow-sm border border-black/5">
                      <button
                        onClick={() => setQtyC11(Math.max(1, qtyC11 - 1))}
                        className="w-6 h-6 flex items-center justify-center text-[#414944] hover:text-[#161b28] rounded active:scale-95"
                      >
                        <span className="material-symbols-outlined text-[16px]">remove</span>
                      </button>
                      <span className="w-7 text-center text-xs font-bold text-[#2d5a46]">
                        {qtyC11}
                      </span>
                      <button
                        onClick={() => setQtyC11(qtyC11 + 1)}
                        className="w-6 h-6 flex items-center justify-center text-[#414944] hover:text-[#161b28] rounded active:scale-95"
                      >
                        <span className="material-symbols-outlined text-[16px]">add</span>
                      </button>
                    </div>
                  </div>
                </div>
              </div>
            </div>

            <button
              onClick={() => setIsPickerModalOpen(true)}
              className="w-full py-2.5 bg-[#f2f3ff] hover:bg-[#e9edff] text-[#2d5a46] text-xs font-bold rounded-lg flex items-center justify-center gap-1.5 transition-colors"
            >
              <span className="material-symbols-outlined text-[18px]">add_circle</span>
              <span>Thêm linh kiện khác từ bản vẽ</span>
            </button>
          </div>

          {/* Evidence Photos */}
          <div className="bg-white p-4 rounded-xl shadow-sm flex flex-col gap-3 border border-black/[0.04]">
            <div className="flex items-center justify-between">
              <h2 className="text-sm font-bold text-[#161b28]">Ảnh minh chứng thực tế</h2>
              <span className="text-xs text-[#805528] font-bold">{photos.length}/2 Đã tải</span>
            </div>
            <p className="text-xs text-[#414944]">
              Cung cấp ảnh mã bọc hàng và vị trí phụ kiện lỗi để xử lý nhanh
            </p>

            <div className="grid grid-cols-2 gap-3">
              {photos.map((photo, idx) => (
                <div
                  key={idx}
                  className="relative rounded-xl overflow-hidden bg-[#f2f3ff] aspect-square flex flex-col items-center justify-center p-2 group shadow-sm border border-black/5"
                >
                  <img
                    className="w-full h-full object-cover rounded-lg"
                    src={photo.url}
                    alt={photo.label}
                  />
                  <div className="absolute inset-0 bg-black/40 flex flex-col items-center justify-center p-2 text-center text-white backdrop-blur-[1px]">
                    <span className="material-symbols-outlined text-[20px] text-white">
                      check_circle
                    </span>
                    <span className="text-xs mt-1 font-bold">{photo.label}</span>
                    <span className="text-[10px] opacity-80">{photo.code}</span>
                  </div>
                  <button
                    onClick={() => onShowToast(`Đã lưu ảnh minh chứng: ${photo.label}`)}
                    className="absolute top-2 right-2 w-6 h-6 rounded-full bg-white text-[#161b28] shadow-sm flex items-center justify-center hover:scale-105"
                    title="Chỉnh sửa ảnh"
                  >
                    <span className="material-symbols-outlined text-[14px]">edit</span>
                  </button>
                </div>
              ))}
            </div>
          </div>

          {/* Additional Notes */}
          <div className="bg-white p-4 rounded-xl shadow-sm flex flex-col gap-2 border border-black/[0.04]">
            <label className="text-xs font-bold text-[#161b28] flex items-center justify-between">
              <span>Ghi chú bổ sung</span>
              <span className="text-[11px] text-[#414944] font-normal">Không bắt buộc</span>
            </label>
            <div className="bg-[#f2f3ff] rounded-xl p-3">
              <textarea
                value={notes}
                onChange={(e) => setNotes(e.target.value)}
                className="w-full bg-transparent border-0 focus:outline-none text-[#161b28] text-xs placeholder:text-[#414944] resize-none"
                placeholder="Mô tả chi tiết tình trạng kiện hàng hoặc yêu cầu riêng tới kỹ thuật viên lắp ráp Furni3D..."
                rows={3}
              />
            </div>
          </div>

          {/* Warranty Commitment Card */}
          <div className="bg-[#2d5a46] text-[#bceed3] p-4 rounded-xl shadow-sm flex items-start gap-3">
            <div className="w-9 h-9 rounded-full bg-white/15 flex items-center justify-center flex-shrink-0 text-white mt-0.5">
              <span className="material-symbols-outlined text-[22px]">shield_with_heart</span>
            </div>
            <div className="flex flex-col gap-1">
              <h3 className="text-xs text-white font-bold">Cam kết bảo hành siêu tốc Furni3D</h3>
              <p className="text-xs leading-relaxed text-white/90">
                Furni3D hỗ trợ gửi bổ sung linh kiện{' '}
                <strong className="text-[#bceed3] font-bold">miễn phí tận nhà</strong> trong vòng{' '}
                <strong className="text-[#bceed3] font-bold">24 - 48h</strong> làm việc qua chuyển
                phát nhanh hỏa tốc.
              </p>
            </div>
          </div>

          {/* Submit Action */}
          <button
            onClick={handleSubmit}
            disabled={isSubmitting}
            className="w-full h-12 bg-[#134230] hover:bg-[#2d5a46] text-white text-sm font-bold rounded-xl shadow-md flex items-center justify-center gap-2 active:scale-[0.99] transition-all"
          >
            {isSubmitting ? (
              <>
                <span className="material-symbols-outlined text-[18px] animate-spin">sync</span>
                <span>Đang gửi thông tin đối soát...</span>
              </>
            ) : (
              <>
                <span className="material-symbols-outlined text-[19px]">send</span>
                <span>Gửi yêu cầu hỗ trợ kỹ thuật</span>
              </>
            )}
          </button>
        </div>
      )}

      {/* VIEW 2: MUA LINH KIỆN THAY THẾ */}
      {activeTab === 'store' && (
        <div className="flex flex-col gap-3 px-4">
          <div className="bg-white p-4 rounded-xl shadow-sm flex flex-col gap-3 border border-black/[0.04]">
            <div className="flex items-center justify-between">
              <div>
                <h2 className="text-sm font-bold text-[#161b28]">Kho phụ kiện chính hãng</h2>
                <p className="text-xs text-[#414944]">Linh kiện tương thích 100% chuẩn kỹ thuật Furni3D</p>
              </div>
              <span className="px-2.5 py-1 rounded-full bg-[#ffdcbf] text-[#2d1600] text-[10px] font-bold">
                Từ 12.000đ
              </span>
            </div>

            <div className="grid grid-cols-2 sm:grid-cols-3 gap-2.5">
              {INITIAL_SPARE_PARTS.map((part) => (
                <div
                  key={part.id}
                  className="bg-[#f2f3ff] p-3 rounded-xl flex flex-col justify-between gap-2 border border-black/[0.03]"
                >
                  <div className="w-full aspect-square bg-white rounded-lg overflow-hidden relative p-2 shadow-sm">
                    <img
                      className="w-full h-full object-contain"
                      src={part.image}
                      alt={part.name}
                    />
                    <span className="absolute top-1.5 left-1.5 bg-[#e3e7fa] text-[#161b28] px-1.5 py-0.5 rounded text-[10px] font-bold">
                      {part.code}
                    </span>
                  </div>

                  <div>
                    <span className="text-xs font-bold text-[#161b28] line-clamp-1">{part.name}</span>
                    <p className="text-[10px] text-[#414944] line-clamp-1">{part.spec}</p>
                    <span className="text-xs font-bold text-[#805528] block mt-1">
                      {part.price.toLocaleString('vi-VN')}đ
                    </span>
                  </div>

                  <button
                    onClick={() => {
                      onAddToCart({
                        id: part.id,
                        name: part.name,
                        price: part.price,
                        image: part.image,
                        variant: part.spec,
                      });
                      onShowToast(`Đã thêm ${part.name} vào giỏ hàng`);
                    }}
                    className="w-full py-1.5 bg-[#dee2f4] hover:bg-[#2d5a46] hover:text-white text-[#2d5a46] text-xs font-bold rounded-lg flex items-center justify-center gap-1 transition-colors"
                  >
                    <span className="material-symbols-outlined text-[16px]">add_shopping_cart</span>
                    <span>Thêm</span>
                  </button>
                </div>
              ))}
            </div>
          </div>
        </div>
      )}

      {/* Quick Switch Banner to Spare Parts Store */}
      {activeTab === 'report' && (
        <div className="mt-4 px-4">
          <div
            onClick={() => setActiveTab('store')}
            className="bg-[#ffdcbf] text-[#2d1600] p-3.5 rounded-xl shadow-sm flex items-center justify-between gap-3 cursor-pointer active:opacity-95 transition-opacity border border-[#805528]/15"
          >
            <div className="flex items-center gap-2.5 min-w-0">
              <span className="material-symbols-outlined text-[#805528] text-[24px] flex-shrink-0">
                hardware
              </span>
              <div className="flex flex-col min-w-0">
                <p className="text-xs font-bold truncate">Nâng cấp phụ kiện sau nhiều năm?</p>
                <p className="text-[11px] text-[#414944] truncate">
                  Khám phá Kho linh kiện chính hãng giá từ 12.000đ
                </p>
              </div>
            </div>
            <span className="material-symbols-outlined text-[#805528] text-[20px] flex-shrink-0">
              arrow_forward
            </span>
          </div>
        </div>
      )}

      {/* Success Notification Bar */}
      {isSuccessToast && (
        <div className="fixed bottom-20 left-4 right-4 z-50 bg-[#2b303e] text-white p-3.5 rounded-xl shadow-xl flex items-center gap-2.5 animate-fadeIn">
          <span className="material-symbols-outlined text-[#a1d1b8] text-[22px]">check_circle</span>
          <span className="text-xs flex-1">
            Yêu cầu cấp bù linh kiện đã được ghi nhận. Furni3D sẽ giao hỏa tốc tận nhà trong 24-48h!
          </span>
        </div>
      )}

      {/* Blueprint Parts Picker Modal */}
      {isPickerModalOpen && (
        <div className="fixed inset-0 z-50 bg-black/60 backdrop-blur-sm flex items-center justify-center p-4">
          <div className="bg-white rounded-2xl w-full max-w-md p-5 shadow-2xl flex flex-col gap-4 max-h-[85vh] overflow-y-auto">
            <div className="flex items-center justify-between border-b pb-3">
              <h3 className="text-sm font-bold text-[#161b28]">Chọn linh kiện từ danh mục Model ND-2024</h3>
              <button
                onClick={() => setIsPickerModalOpen(false)}
                className="w-8 h-8 rounded-full bg-[#f2f3ff] flex items-center justify-center text-[#414944]"
              >
                <span className="material-symbols-outlined text-[18px]">close</span>
              </button>
            </div>

            <div className="space-y-2">
              {INITIAL_SPARE_PARTS.map((item) => (
                <div
                  key={item.id}
                  className="flex items-center justify-between p-2.5 rounded-xl bg-[#f2f3ff] border border-black/5"
                >
                  <div className="flex items-center gap-3">
                    <img src={item.image} alt={item.name} className="w-10 h-10 object-contain rounded" />
                    <div>
                      <p className="text-xs font-bold text-[#161b28]">{item.name}</p>
                      <p className="text-[10px] text-[#414944]">{item.code} · {item.spec}</p>
                    </div>
                  </div>
                  <button
                    onClick={() => {
                      setIsPickerModalOpen(false);
                      onShowToast(`Đã thêm ${item.name} vào danh sách báo thiếu`);
                    }}
                    className="px-2.5 py-1 rounded-lg bg-[#2d5a46] text-white text-xs font-semibold"
                  >
                    Bổ sung
                  </button>
                </div>
              ))}
            </div>
          </div>
        </div>
      )}
    </div>
  );
};
