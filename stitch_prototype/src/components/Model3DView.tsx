import React, { useState } from 'react';
import { ASSEMBLY_STEPS, PRODUCTS } from '../data/mockData';
import { Product } from '../types';
import { ThreeModelViewer } from './ThreeModelViewer';

interface Model3DViewProps {
  currentProduct?: Product;
  onOpenQRScanner: () => void;
  onOpenAR: () => void;
  onGoToReportParts: (partCode?: string) => void;
  onShowToast: (msg: string) => void;
}

export const Model3DView: React.FC<Model3DViewProps> = ({
  currentProduct = PRODUCTS[0],
  onOpenQRScanner,
  onOpenAR,
  onGoToReportParts,
  onShowToast,
}) => {
  const [currentStepIdx, setCurrentStepIdx] = useState<number>(2); // Step 3 (0-indexed: 2)
  const [isPlaying3D, setIsPlaying3D] = useState<boolean>(false);
  const [checkedParts, setCheckedParts] = useState<Record<string, boolean>>({
    '#A-12': true,
    '#SC-04': true,
    '#TL-01': true,
  });
  const [isMissingModalOpen, setIsMissingModalOpen] = useState<boolean>(false);
  const [missingSelectedParts, setMissingSelectedParts] = useState<Record<string, boolean>>({
    '#A-12': true,
  });
  const [isManualModalOpen, setIsManualModalOpen] = useState<boolean>(false);

  const currentStep = ASSEMBLY_STEPS[currentStepIdx] || ASSEMBLY_STEPS[0];
  const progressPercent = Math.round(((currentStepIdx + 1) / ASSEMBLY_STEPS.length) * 100);

  const handleNextStep = () => {
    if (currentStepIdx < ASSEMBLY_STEPS.length - 1) {
      setCurrentStepIdx((prev) => prev + 1);
      onShowToast(`Đã chuyển sang Bước ${currentStepIdx + 2}/${ASSEMBLY_STEPS.length}`);
    } else {
      onShowToast('🎉 Chúc mừng! Bạn đã hoàn thiện 100% các bước lắp ráp Bàn Nordic Oak Desk');
    }
  };

  const handlePrevStep = () => {
    if (currentStepIdx > 0) {
      setCurrentStepIdx((prev) => prev - 1);
    }
  };

  const togglePartCheck = (code: string) => {
    setCheckedParts((prev) => ({
      ...prev,
      [code]: !prev[code],
    }));
  };

  const handleConfirmReport = () => {
    const selectedCodes = Object.keys(missingSelectedParts).filter((k) => missingSelectedParts[k]);
    setIsMissingModalOpen(false);
    onShowToast('Đang chuyển sang biểu mẫu cấp bù linh kiện miễn phí...');
    onGoToReportParts(selectedCodes[0]);
  };

  return (
    <div className="flex flex-col w-full max-w-5xl mx-auto pb-10">
      {/* Mode Switcher Pill Segmented Control */}
      <div className="px-4 pt-3 pb-2">
        <div className="flex p-1 bg-[#e9edff] rounded-full shadow-inner max-w-md mx-auto">
          <button
            className="flex-1 py-2 px-3 rounded-full flex items-center justify-center gap-1.5 bg-white text-[#134230] text-xs font-bold shadow-sm transition-all"
            type="button"
          >
            <span className="material-symbols-outlined text-[18px]">view_in_ar</span>
            <span>Hướng dẫn 3D</span>
          </button>
          <button
            onClick={onOpenQRScanner}
            className="flex-1 py-2 px-3 rounded-full flex items-center justify-center gap-1.5 text-[#414944] text-xs font-semibold transition-all hover:text-[#161b28]"
            type="button"
          >
            <span className="material-symbols-outlined text-[18px]">qr_code_scanner</span>
            <span>Quét lại QR</span>
          </button>
        </div>
      </div>

      {/* Product Meta Header Info Card */}
      <div className="px-4 mb-3">
        <div className="bg-[#f2f3ff] rounded-xl p-3 flex items-center justify-between shadow-sm border border-black/[0.03]">
          <div className="flex items-center gap-3 min-w-0">
            <div className="w-10 h-10 rounded-lg bg-[#e3e7fa] flex items-center justify-center text-[#2d5a46] flex-shrink-0">
              <span className="material-symbols-outlined text-[24px]">desk</span>
            </div>
            <div className="min-w-0">
              <div className="flex items-center gap-1.5">
                <span className="text-[10px] font-bold uppercase px-1.5 py-0.5 rounded bg-[#2d5a46] text-white">
                  {currentProduct.modelCode}
                </span>
                <span className="text-[11px] text-[#805528] flex items-center gap-1 font-medium">
                  <span className="w-1.5 h-1.5 rounded-full bg-[#805528]" />
                  {currentProduct.subtitle}
                </span>
              </div>
              <h2 className="text-sm font-bold text-[#161b28] truncate mt-0.5">
                {currentProduct.name}
              </h2>
            </div>
          </div>

          <button
            onClick={() => setIsManualModalOpen(true)}
            aria-label="Xem bản vẽ chi tiết"
            className="w-9 h-9 rounded-full bg-white flex items-center justify-center text-[#414944] hover:text-[#2d5a46] transition-colors shadow-sm flex-shrink-0"
            type="button"
            title="Mở sổ tay hướng dẫn bản vẽ"
          >
            <span className="material-symbols-outlined text-[20px]">menu_book</span>
          </button>
        </div>
      </div>

      {/* Interactive 3D Canvas / Viewport */}
      <div className="px-4 mb-3">
        <ThreeModelViewer
          currentStep={currentStep.stepNumber}
          explodedAmount={currentStep.explodedProgress}
          isPlaying={isPlaying3D}
          onTogglePlay={() => setIsPlaying3D(!isPlaying3D)}
          onOpenAR={onOpenAR}
          onPinClick={(name) => onShowToast(`Chi tiết kỹ thuật: ${name}`)}
        />
      </div>

      {/* Step Progress Indicator Card */}
      <div className="px-4 mb-3">
        <div className="bg-white rounded-xl p-4 shadow-sm border border-black/[0.04]">
          <div className="flex items-center justify-between mb-2">
            <div className="flex items-center gap-2">
              <span className="w-6 h-6 rounded-full bg-[#2d5a46] text-white text-xs font-bold flex items-center justify-center">
                {currentStep.stepNumber}
              </span>
              <span className="text-xs uppercase tracking-wider text-[#805528] font-bold">
                Bước {currentStep.stepNumber} / {ASSEMBLY_STEPS.length}
              </span>
            </div>
            <span className="text-xs text-[#414944] font-medium">Tiến độ: {progressPercent}%</span>
          </div>

          {/* Stepper track bar */}
          <div className="w-full bg-[#dee2f4] rounded-full h-2 mb-3 overflow-hidden">
            <div
              className="bg-[#2d5a46] h-full rounded-full transition-all duration-300"
              style={{ width: `${progressPercent}%` }}
            />
          </div>

          {/* Step Title & Description */}
          <h3 className="text-sm font-bold text-[#161b28] mb-1">{currentStep.title}</h3>
          <p className="text-xs text-[#414944] leading-relaxed">{currentStep.description}</p>
        </div>
      </div>

      {/* Parts Checklist for this step */}
      <div className="px-4 mb-3">
        <div className="bg-white rounded-xl p-4 shadow-sm border border-black/[0.04]">
          <div className="flex items-center justify-between mb-3">
            <div className="flex items-center gap-2">
              <span className="material-symbols-outlined text-[#805528] text-[20px]">category</span>
              <h4 className="text-xs font-bold text-[#161b28] uppercase tracking-wider">
                Linh kiện cần cho bước này
              </h4>
            </div>
            <span className="text-[10px] px-2 py-0.5 rounded bg-[#e9edff] text-[#414944] font-bold">
              {currentStep.requiredParts.length} món
            </span>
          </div>

          {/* Parts List */}
          <div className="space-y-2 mb-3">
            {currentStep.requiredParts.map((part) => {
              const isChecked = !!checkedParts[part.code];
              return (
                <div
                  key={part.code}
                  onClick={() => togglePartCheck(part.code)}
                  className="flex items-center justify-between p-2.5 rounded-lg bg-[#f2f3ff] hover:bg-[#e9edff] transition-colors cursor-pointer border border-black/[0.02]"
                >
                  <div className="flex items-center gap-3 min-w-0">
                    <div className="w-12 h-12 rounded-lg bg-white p-1 flex items-center justify-center flex-shrink-0 shadow-sm border border-black/5 overflow-hidden">
                      <img
                        alt={part.name}
                        className="w-full h-full object-cover rounded"
                        src={part.image}
                      />
                    </div>
                    <div className="min-w-0">
                      <p className="text-xs font-semibold text-[#161b28] truncate">{part.name}</p>
                      <p className="text-[11px] text-[#414944]">
                        Mã linh kiện:{' '}
                        <span className="font-bold text-[#2d5a46]">{part.code}</span>
                      </p>
                      {part.note && (
                        <p className="text-[10px] text-[#805528] font-medium">{part.note}</p>
                      )}
                    </div>
                  </div>

                  <div className="flex items-center gap-2 flex-shrink-0">
                    <span className="text-sm text-[#2d5a46] font-bold">×0{part.count}</span>
                    <button
                      type="button"
                      className={`w-6 h-6 rounded-full flex items-center justify-center transition-all ${
                        isChecked
                          ? 'bg-[#2d5a46] text-white'
                          : 'border border-[#717973] text-transparent'
                      }`}
                    >
                      <span className="material-symbols-outlined text-[16px]">check</span>
                    </button>
                  </div>
                </div>
              );
            })}
          </div>

          {/* Mechanic Instruction Card */}
          <div className="p-3 rounded-lg bg-[#e9edff] flex items-start gap-2.5 border border-black/[0.02]">
            <span className="material-symbols-outlined text-[#805528] text-[20px] flex-shrink-0 mt-0.5">
              tips_and_updates
            </span>
            <div>
              <h5 className="text-xs font-bold text-[#161b28]">Mẹo thợ mộc Furni3D:</h5>
              <p className="text-[11px] text-[#414944] mt-0.5 leading-relaxed">{currentStep.tip}</p>
            </div>
          </div>
        </div>
      </div>

      {/* Primary Action Navigation Buttons */}
      <div className="px-4 flex flex-col gap-2 mb-2">
        <div className="grid grid-cols-2 gap-2.5">
          <button
            onClick={handlePrevStep}
            disabled={currentStepIdx === 0}
            className={`h-12 px-4 rounded-xl text-xs font-bold flex items-center justify-center gap-1 shadow-sm transition-all ${
              currentStepIdx === 0
                ? 'bg-[#dee2f4] text-[#717973] opacity-60 cursor-not-allowed'
                : 'bg-[#e3e7fa] text-[#161b28] hover:bg-[#dee2f4] active:scale-[0.98]'
            }`}
            type="button"
          >
            <span className="material-symbols-outlined text-[18px]">arrow_back</span>
            <span>Bước trước</span>
          </button>

          <button
            onClick={handleNextStep}
            className="h-12 px-4 rounded-xl bg-[#2d5a46] text-white text-xs font-bold flex items-center justify-center gap-1 shadow-md transition-all hover:bg-[#134230] active:scale-[0.98]"
            type="button"
          >
            <span>{currentStepIdx === ASSEMBLY_STEPS.length - 1 ? 'Hoàn thành' : 'Bước tiếp theo'}</span>
            <span className="material-symbols-outlined text-[18px]">arrow_forward</span>
          </button>
        </div>

        {/* Missing Part Assistance Button */}
        <button
          onClick={() => setIsMissingModalOpen(true)}
          className="w-full py-3 px-4 rounded-xl bg-[#fec38d] text-[#794f23] text-xs font-bold flex items-center justify-center gap-2 shadow-sm transition-all hover:brightness-95 active:scale-[0.99] border border-[#805528]/20"
          type="button"
        >
          <span className="material-symbols-outlined text-[18px]">warning</span>
          <span>Báo thiếu linh kiện này ⚠️</span>
        </button>
      </div>

      {/* Missing Part Modal */}
      {isMissingModalOpen && (
        <div className="fixed inset-0 z-50 bg-black/60 backdrop-blur-sm flex items-end sm:items-center justify-center p-4">
          <div className="bg-white rounded-2xl w-full max-w-sm p-5 shadow-2xl flex flex-col gap-4 animate-scaleUp">
            <div className="flex items-center justify-between">
              <div className="w-10 h-10 rounded-full bg-[#fec38d] flex items-center justify-center text-[#794f23]">
                <span className="material-symbols-outlined text-[24px]">support_agent</span>
              </div>
              <button
                onClick={() => setIsMissingModalOpen(false)}
                className="w-8 h-8 rounded-full bg-[#e9edff] flex items-center justify-center text-[#414944]"
                type="button"
              >
                <span className="material-symbols-outlined text-[18px]">close</span>
              </button>
            </div>

            <div>
              <h4 className="text-base font-bold text-[#161b28]">Bạn bị thiếu linh kiện nào?</h4>
              <p className="text-xs text-[#414944] mt-1">
                Furni3D cam kết giao bổ sung linh kiện tận nhà miễn phí siêu tốc trong 24h - 48h làm việc.
              </p>
            </div>

            <div className="space-y-2">
              {currentStep.requiredParts.map((part) => (
                <label
                  key={part.code}
                  className="flex items-center gap-3 p-3 rounded-lg bg-[#f2f3ff] cursor-pointer hover:bg-[#e9edff] transition-colors"
                >
                  <input
                    type="checkbox"
                    checked={!!missingSelectedParts[part.code]}
                    onChange={(e) =>
                      setMissingSelectedParts((prev) => ({
                        ...prev,
                        [part.code]: e.target.checked,
                      }))
                    }
                    className="w-4 h-4 rounded text-[#2d5a46] focus:ring-0 accent-[#2d5a46]"
                  />
                  <span className="text-xs font-semibold text-[#161b28]">
                    {part.name} ({part.code})
                  </span>
                </label>
              ))}
            </div>

            <button
              onClick={handleConfirmReport}
              className="w-full h-12 rounded-xl bg-[#2d5a46] text-white text-xs font-bold flex items-center justify-center gap-2 shadow-md hover:bg-[#134230] transition-colors"
              type="button"
            >
              <span className="material-symbols-outlined text-[18px]">send</span>
              <span>Gửi yêu cầu hỗ trợ ngay</span>
            </button>
          </div>
        </div>
      )}

      {/* Assembly Manual Blueprint Modal */}
      {isManualModalOpen && (
        <div className="fixed inset-0 z-50 bg-black/60 backdrop-blur-sm flex items-center justify-center p-4">
          <div className="bg-white rounded-2xl w-full max-w-lg p-5 shadow-2xl flex flex-col gap-4 max-h-[85vh] overflow-y-auto">
            <div className="flex items-center justify-between border-b pb-3">
              <div className="flex items-center gap-2">
                <span className="material-symbols-outlined text-[#2d5a46]">menu_book</span>
                <h3 className="text-base font-bold text-[#161b28]">Sổ tay bản vẽ kỹ thuật Furni3D</h3>
              </div>
              <button
                onClick={() => setIsManualModalOpen(false)}
                className="w-8 h-8 rounded-full bg-[#f2f3ff] flex items-center justify-center text-[#414944]"
              >
                <span className="material-symbols-outlined text-[18px]">close</span>
              </button>
            </div>

            <div className="space-y-4">
              <div className="p-3 rounded-xl bg-[#f2f3ff]">
                <h4 className="text-xs font-bold text-[#161b28] mb-1">Mã sản phẩm: MODEL ND-2024</h4>
                <p className="text-xs text-[#414944]">
                  Kích thước chuẩn: Dài 1200mm × Rộng 600mm × Cao 750mm. Trọng lượng đóng gói: 24.5 kg (2 kiện).
                </p>
              </div>

              <div>
                <h5 className="text-xs font-bold text-[#161b28] mb-2 uppercase tracking-wide">
                  Tất cả các bước lắp ráp:
                </h5>
                <div className="space-y-2">
                  {ASSEMBLY_STEPS.map((step, idx) => (
                    <button
                      key={step.stepNumber}
                      onClick={() => {
                        setCurrentStepIdx(idx);
                        setIsManualModalOpen(false);
                      }}
                      className={`w-full p-2.5 rounded-lg text-left text-xs flex items-center justify-between transition-colors ${
                        idx === currentStepIdx
                          ? 'bg-[#2d5a46] text-white font-bold'
                          : 'bg-[#f2f3ff] text-[#161b28] hover:bg-[#e9edff]'
                      }`}
                    >
                      <span>
                        Bước {step.stepNumber}: {step.title}
                      </span>
                      <span className="material-symbols-outlined text-[16px]">chevron_right</span>
                    </button>
                  ))}
                </div>
              </div>
            </div>
          </div>
        </div>
      )}
    </div>
  );
};
