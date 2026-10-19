import React, { useState } from 'react';

interface QRScannerModalProps {
  isOpen: boolean;
  onClose: () => void;
  onScanResult: (code: string) => void;
}

export const QRScannerModal: React.FC<QRScannerModalProps> = ({
  isOpen,
  onClose,
  onScanResult,
}) => {
  const [flashlight, setFlashlight] = useState<boolean>(false);

  if (!isOpen) return null;

  const testCodes = [
    { label: 'Hộp Bàn Nordic Oak Desk', code: 'MODEL ND-2024' },
    { label: 'Kiện Ghế Poäng Scandi', code: 'MODEL PC-108' },
    { label: 'Gói Phụ Kiện Ốc Cam #P-04', code: 'PART-P04-CAM' },
  ];

  return (
    <div className="fixed inset-0 z-50 bg-[#161b28] flex flex-col justify-between p-4 animate-fadeIn">
      {/* Top Header */}
      <div className="flex items-center justify-between text-white pt-safe">
        <div className="flex items-center gap-2">
          <span className="material-symbols-outlined text-[#bceed3]">qr_code_scanner</span>
          <span className="text-base font-bold">Quét mã QR sản phẩm</span>
        </div>
        <button
          onClick={onClose}
          className="w-10 h-10 rounded-full bg-white/10 hover:bg-white/20 flex items-center justify-center text-white transition-colors"
          type="button"
        >
          <span className="material-symbols-outlined text-[22px]">close</span>
        </button>
      </div>

      {/* Center Target Reticle & Simulated Camera Viewfinder */}
      <div className="relative flex flex-col items-center justify-center my-auto">
        <div className="relative w-64 h-64 sm:w-72 sm:h-72 rounded-2xl border-2 border-dashed border-[#bceed3] flex flex-col items-center justify-center bg-black/40 backdrop-blur-xs overflow-hidden shadow-2xl">
          {/* Animated Scanning Laser Line */}
          <div className="absolute left-0 right-0 h-0.5 bg-gradient-to-r from-transparent via-[#bceed3] to-transparent shadow-[0_0_12px_#bceed3] animate-pulse" />

          {/* Corner Guides */}
          <div className="absolute top-2 left-2 w-6 h-6 border-t-2 border-l-2 border-[#bceed3]" />
          <div className="absolute top-2 right-2 w-6 h-6 border-t-2 border-r-2 border-[#bceed3]" />
          <div className="absolute bottom-2 left-2 w-6 h-6 border-b-2 border-l-2 border-[#bceed3]" />
          <div className="absolute bottom-2 right-2 w-6 h-6 border-b-2 border-r-2 border-[#bceed3]" />

          <span className="material-symbols-outlined text-[#bceed3] text-[52px] opacity-70">
            qr_code_2
          </span>
          <p className="text-xs text-white/90 mt-3 text-center px-4 font-medium leading-relaxed">
            Căn chỉnh mã QR in trên vỏ thùng carton vào khung hình để mở bản vẽ 3D
          </p>
        </div>

        {/* Quick Test Barcodes for Demo */}
        <div className="mt-6 flex flex-col items-center gap-2 w-full max-w-xs">
          <span className="text-[11px] text-[#c0c9c2] font-semibold uppercase tracking-wider">
            Mã QR mẫu thử nghiệm:
          </span>
          <div className="flex flex-wrap gap-1.5 justify-center">
            {testCodes.map((item) => (
              <button
                key={item.code}
                onClick={() => {
                  onScanResult(item.code);
                  onClose();
                }}
                className="px-2.5 py-1.5 rounded-lg bg-white/10 hover:bg-white/20 text-white text-xs font-semibold flex items-center gap-1 border border-white/10 active:scale-95 transition-all"
              >
                <span className="material-symbols-outlined text-[14px] text-[#bceed3]">qr_code</span>
                <span>{item.label}</span>
              </button>
            ))}
          </div>
        </div>
      </div>

      {/* Bottom Controls */}
      <div className="pb-safe flex flex-col gap-3 items-center w-full max-w-sm mx-auto">
        <button
          onClick={() => setFlashlight(!flashlight)}
          className={`px-4 py-2 rounded-full text-xs font-semibold flex items-center gap-2 transition-all ${
            flashlight
              ? 'bg-[#bceed3] text-[#002114]'
              : 'bg-white/15 text-white hover:bg-white/25'
          }`}
          type="button"
        >
          <span className="material-symbols-outlined text-[18px]">
            {flashlight ? 'flashlight_off' : 'flashlight_on'}
          </span>
          <span>{flashlight ? 'Tắt đèn pin' : 'Bật đèn pin'}</span>
        </button>

        <button
          onClick={onClose}
          className="w-full h-12 rounded-xl bg-white text-[#161b28] text-xs font-bold flex items-center justify-center hover:bg-[#faf8ff] transition-colors shadow-lg active:scale-95"
          type="button"
        >
          Quay lại màn hình chính
        </button>
      </div>
    </div>
  );
};
