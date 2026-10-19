import React from 'react';
import { Order } from '../types';

interface DriverTrackingModalProps {
  order: Order | null;
  onClose: () => void;
  onShowToast: (msg: string) => void;
}

export const DriverTrackingModal: React.FC<DriverTrackingModalProps> = ({
  order,
  onClose,
  onShowToast,
}) => {
  if (!order || !order.driver) return null;

  const driver = order.driver;

  return (
    <div className="fixed inset-0 z-50 bg-black/60 backdrop-blur-sm flex items-end sm:items-center justify-center p-4 animate-fadeIn">
      <div className="bg-white rounded-2xl w-full max-w-md overflow-hidden shadow-2xl flex flex-col animate-slideUp">
        {/* Map Header */}
        <div className="relative h-48 bg-[#e3e7fa] overflow-hidden">
          {/* Simulated Vector Map */}
          <svg className="w-full h-full" viewBox="0 0 400 200" fill="none">
            {/* Grid streets */}
            <rect width="400" height="200" fill="#e9edff" />
            <path d="M 0 50 Q 150 70 400 40" stroke="#dee2f4" strokeWidth="18" />
            <path d="M 50 0 L 120 200" stroke="#dee2f4" strokeWidth="14" />
            <path d="M 220 0 L 180 200" stroke="#dee2f4" strokeWidth="16" />
            <path d="M 0 140 Q 200 120 400 160" stroke="#dee2f4" strokeWidth="22" />

            {/* River / Green Park */}
            <path d="M 280 0 Q 340 100 400 110 L 400 0 Z" fill="#bceed3" opacity="0.6" />

            {/* Active GPS Route */}
            <path
              d="M 90 60 Q 180 80 220 140"
              stroke="#2d5a46"
              strokeWidth="4"
              strokeDasharray="6 4"
              className="animate-pulse"
            />

            {/* Driver Truck Marker */}
            <g transform="translate(140, 75)">
              <circle cx="12" cy="12" r="14" fill="#2d5a46" />
              <text x="5" y="17" fill="white" fontSize="14">🚚</text>
            </g>

            {/* Delivery Destination Landmark */}
            <g transform="translate(210, 130)">
              <circle cx="10" cy="10" r="16" fill="#805528" opacity="0.3" className="animate-ping" />
              <circle cx="10" cy="10" r="10" fill="#805528" />
              <text x="6" y="14" fill="white" fontSize="11">📍</text>
            </g>
          </svg>

          {/* Close button */}
          <button
            onClick={onClose}
            className="absolute top-3 right-3 w-8 h-8 rounded-full bg-white/90 shadow-md flex items-center justify-center text-[#161b28] hover:bg-white"
          >
            <span className="material-symbols-outlined text-[18px]">close</span>
          </button>

          {/* ETA Badge */}
          <div className="absolute bottom-3 left-3 bg-white/95 backdrop-blur-md px-3 py-1.5 rounded-xl shadow-md border border-black/5 flex items-center gap-2">
            <span className="w-2.5 h-2.5 rounded-full bg-[#805528] animate-ping" />
            <span className="text-xs font-bold text-[#161b28]">
              Cách điểm giao 3.4 km • Dự kiến 18 phút
            </span>
          </div>
        </div>

        {/* Driver Details Card */}
        <div className="p-4 flex flex-col gap-3">
          <div className="flex items-center justify-between">
            <div className="flex items-center gap-3">
              <div className="w-12 h-12 rounded-full bg-[#f2f3ff] overflow-hidden flex-shrink-0 border-2 border-[#2d5a46]">
                <img src={driver.avatar} alt={driver.name} className="w-full h-full object-cover" />
              </div>
              <div>
                <div className="flex items-center gap-1.5">
                  <h3 className="text-sm font-bold text-[#161b28]">{driver.name}</h3>
                  <span className="text-[10px] px-1.5 py-0.2 rounded bg-[#bceed3] text-[#002114] font-bold">
                    Kỹ thuật viên 5★
                  </span>
                </div>
                <p className="text-xs text-[#414944] mt-0.5">
                  Xe bán tải chuyên dụng: <strong className="text-[#161b28]">{driver.licensePlate}</strong>
                </p>
              </div>
            </div>

            <div className="flex items-center gap-2">
              <button
                onClick={() => onShowToast(`Đang gọi tài xế ${driver.name}: ${driver.phone}`)}
                className="w-10 h-10 rounded-full bg-[#2d5a46] text-white flex items-center justify-center shadow-sm active:scale-95"
                title="Gọi điện"
              >
                <span className="material-symbols-outlined text-[18px]">call</span>
              </button>
              <button
                onClick={() => onShowToast(`Đang mở khung tin nhắn với ${driver.name}`)}
                className="w-10 h-10 rounded-full bg-[#f2f3ff] text-[#161b28] flex items-center justify-center hover:bg-[#e9edff] active:scale-95"
                title="Nhắn tin"
              >
                <span className="material-symbols-outlined text-[18px]">chat</span>
              </button>
            </div>
          </div>

          <div className="bg-[#f2f3ff] p-3 rounded-xl border border-black/5 text-xs text-[#414944] space-y-1">
            <div className="flex items-center gap-1 font-bold text-[#161b28]">
              <span className="material-symbols-outlined text-[16px] text-[#2d5a46]">verified_user</span>
              <span>Dịch vụ giao kiện kèm đồng kiểm linh kiện:</span>
            </div>
            <p className="leading-relaxed">
              Tài xế Nguyễn Văn An sẽ mang theo máy quét QR để cùng bạn đối chiếu bảng kiểm đếm ốc vít
              trước khi ký biên bản bàn giao.
            </p>
          </div>
        </div>
      </div>
    </div>
  );
};
