import React, { useState } from 'react';

interface ARViewModalProps {
  isOpen: boolean;
  onClose: () => void;
  onShowToast: (msg: string) => void;
}

export const ARViewModal: React.FC<ARViewModalProps> = ({
  isOpen,
  onClose,
  onShowToast,
}) => {
  const [scale, setScale] = useState<number>(1);
  const [rotation, setRotation] = useState<number>(0);
  const [lighting, setLighting] = useState<'natural' | 'warm' | 'bright'>('natural');

  if (!isOpen) return null;

  const handleCapture = () => {
    onShowToast('📸 Đã chụp ảnh không gian AR & lưu vào thư viện!');
  };

  return (
    <div className="fixed inset-0 z-50 bg-[#161b28] flex flex-col justify-between overflow-hidden animate-fadeIn">
      {/* Background Room Camera Feed Simulation */}
      <div className="absolute inset-0 bg-[#2b303e]">
        <img
          src="https://lh3.googleusercontent.com/aida-public/AB6AXuDtsPt5A0CyOs27bxWzw4CcEEWfwrooOotV_1vfC6d3t4Ahr_Xt-Ckwo_stDgl5R-a2yZw7Bj6m1EEc2RuGtgCu9GSOHIxLyVBWVSlqyihVYz55omPXQORnUIBFu7IgOBBGgzjgV36nHO7ow62pLv6kIHD7ZSQtZVy2qoS9t6t45Apa-l0LAQBY17BjSLJgV6GlHVFPFtkRofD-UAq3YD5SMh9nt0J-sMNCJfjL2o_br7mu1bb0mMrypg"
          alt="AR Room Camera Feed"
          className="w-full h-full object-cover opacity-80"
        />

        {/* Floor Plane Detection Mesh Grid */}
        <div className="absolute inset-x-8 bottom-12 h-64 border-2 border-dashed border-[#bceed3]/60 rounded-3xl transform rotate-x-60 bg-[#bceed3]/5 pointer-events-none flex items-center justify-center">
          <span className="text-[11px] text-[#bceed3] font-bold uppercase tracking-wider bg-black/40 px-3 py-1 rounded-full">
            Mặt sàn phẳng đã nhận diện (Độ tin cậy: 99%)
          </span>
        </div>

        {/* 3D Furniture Placement with Shadow */}
        <div
          style={{
            transform: `translate(-50%, -50%) scale(${scale}) rotate(${rotation}deg)`,
          }}
          className="absolute top-1/2 left-1/2 transition-transform duration-100 flex flex-col items-center pointer-events-none select-none"
        >
          {/* Furniture Cutout / Render */}
          <div className="relative w-64 h-64 sm:w-80 sm:h-80 drop-shadow-[0_25px_25px_rgba(0,0,0,0.6)]">
            <img
              src="https://lh3.googleusercontent.com/aida-public/AB6AXuDKoI89GZm9rirBM9_r8CSOhp9G5WgHNi8HFJbCV_cUCSyEEtMBZHFKYX_ZX8p0nv7kQuFham1lok3rYkn4OHXOt2sbRJjUEA08BbhBIIYYzqKuBiPCDMOU0QMfcgkk99CVmaB88AUI5UGOsL5GhbFQmVs5-J2hOp6apzspvxyrQmffF0APasyLMlsmHc6RqY63jfH2HdXPGeQCPnfXM_RYwFHn27ykV1mx5gsf3Aht9BrVAEunxX3mQw"
              alt="AR Model"
              className="w-full h-full object-contain"
            />
            {/* Dimension Indicators */}
            <div className="absolute -bottom-3 left-1/2 -translate-x-1/2 bg-black/70 backdrop-blur-md text-white text-[10px] px-2.5 py-0.5 rounded-full font-bold whitespace-nowrap border border-white/20">
              120cm × 60cm × 75cm (Tỉ lệ 1:1)
            </div>
          </div>
        </div>
      </div>

      {/* Top Header */}
      <div className="relative z-10 flex items-center justify-between p-4 pt-safe text-white">
        <div className="flex items-center gap-2 bg-black/40 backdrop-blur-md px-3 py-1.5 rounded-full border border-white/10">
          <span className="w-2 h-2 rounded-full bg-[#bceed3] animate-pulse" />
          <span className="text-xs font-bold">Chế độ AR thực tế ảo</span>
        </div>

        <button
          onClick={onClose}
          className="w-10 h-10 rounded-full bg-black/40 hover:bg-black/60 backdrop-blur-md flex items-center justify-center text-white border border-white/10"
        >
          <span className="material-symbols-outlined text-[20px]">close</span>
        </button>
      </div>

      {/* Bottom Floating Control Deck */}
      <div className="relative z-10 pb-safe p-4 flex flex-col gap-3">
        {/* Scale & Rotate Controls */}
        <div className="bg-black/60 backdrop-blur-md p-3 rounded-2xl border border-white/10 flex items-center justify-between gap-3 text-white max-w-md mx-auto w-full">
          {/* Scale Buttons */}
          <div className="flex items-center gap-1">
            <button
              onClick={() => setScale(0.8)}
              className={`px-2.5 py-1 rounded-lg text-xs font-bold ${
                scale === 0.8 ? 'bg-[#2d5a46] text-white' : 'bg-white/10'
              }`}
            >
              80%
            </button>
            <button
              onClick={() => setScale(1)}
              className={`px-2.5 py-1 rounded-lg text-xs font-bold ${
                scale === 1 ? 'bg-[#2d5a46] text-white' : 'bg-white/10'
              }`}
            >
              100%
            </button>
            <button
              onClick={() => setScale(1.2)}
              className={`px-2.5 py-1 rounded-lg text-xs font-bold ${
                scale === 1.2 ? 'bg-[#2d5a46] text-white' : 'bg-white/10'
              }`}
            >
              120%
            </button>
          </div>

          {/* Rotate Slider */}
          <div className="flex items-center gap-2 flex-1 max-w-[140px]">
            <span className="material-symbols-outlined text-[16px] text-[#c0c9c2]">sync</span>
            <input
              type="range"
              min="-180"
              max="180"
              value={rotation}
              onChange={(e) => setRotation(Number(e.target.value))}
              className="w-full accent-[#2d5a46] cursor-pointer"
            />
          </div>
        </div>

        {/* Capture Snapshot & Exit */}
        <div className="flex items-center justify-center gap-4">
          <button
            onClick={() => setRotation((prev) => prev - 45)}
            className="w-12 h-12 rounded-full bg-black/50 text-white flex items-center justify-center border border-white/20 active:scale-90"
            title="Xoay trái 45°"
          >
            <span className="material-symbols-outlined text-[20px]">rotate_left</span>
          </button>

          {/* Shutter Button */}
          <button
            onClick={handleCapture}
            className="w-16 h-16 rounded-full bg-white border-4 border-[#2d5a46] flex items-center justify-center shadow-2xl active:scale-95 transition-transform"
            title="Chụp ảnh góc ướm thử"
          >
            <span className="w-12 h-12 rounded-full bg-[#2d5a46] flex items-center justify-center text-white">
              <span className="material-symbols-outlined text-[24px]">photo_camera</span>
            </span>
          </button>

          <button
            onClick={() => setRotation((prev) => prev + 45)}
            className="w-12 h-12 rounded-full bg-black/50 text-white flex items-center justify-center border border-white/20 active:scale-90"
            title="Xoay phải 45°"
          >
            <span className="material-symbols-outlined text-[20px]">rotate_right</span>
          </button>
        </div>
      </div>
    </div>
  );
};
