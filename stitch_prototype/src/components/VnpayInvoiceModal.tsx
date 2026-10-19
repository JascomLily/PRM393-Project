import React from 'react';
import { Order } from '../types';

interface VnpayInvoiceModalProps {
  order: Order | null;
  onClose: () => void;
  onShowToast: (msg: string) => void;
}

export const VnpayInvoiceModal: React.FC<VnpayInvoiceModalProps> = ({
  order,
  onClose,
  onShowToast,
}) => {
  if (!order) return null;

  const handleDownload = () => {
    onShowToast(`Đã xuất file hóa đơn điện tử VNPAY #${order.code}.pdf`);
  };

  return (
    <div className="fixed inset-0 z-50 bg-black/60 backdrop-blur-sm flex items-center justify-center p-4 animate-fadeIn">
      <div className="bg-white rounded-2xl w-full max-w-sm overflow-hidden shadow-2xl flex flex-col animate-scaleUp">
        {/* Header */}
        <div className="bg-[#005ba9] text-white p-4 flex items-center justify-between">
          <div className="flex items-center gap-2">
            <span className="material-symbols-outlined text-[20px]">receipt_long</span>
            <h3 className="text-sm font-bold">Hóa đơn điện tử VNPAY QR</h3>
          </div>
          <button
            onClick={onClose}
            className="w-7 h-7 rounded-full bg-white/20 flex items-center justify-center text-white"
          >
            <span className="material-symbols-outlined text-[16px]">close</span>
          </button>
        </div>

        {/* Invoice Body */}
        <div className="p-5 flex flex-col gap-3 text-xs">
          <div className="text-center pb-3 border-b border-dashed border-black/15">
            <h4 className="font-bold text-sm text-[#161b28]">CÔNG TY TNHH NỘI THẤT FURNI3D</h4>
            <p className="text-[#414944] text-[11px] mt-0.5">MST: 0317894211 • Hotline: 1900 8383</p>
            <p className="text-[#717973] text-[10px]">Tòa nhà Landmark 81, TP. Hồ Chí Minh</p>
          </div>

          <div className="space-y-1.5 py-1">
            <div className="flex justify-between">
              <span className="text-[#414944]">Mã đơn hàng:</span>
              <strong className="text-[#161b28]">{order.code}</strong>
            </div>
            <div className="flex justify-between">
              <span className="text-[#414944]">Mã giao dịch VNPAY:</span>
              <span className="font-mono font-bold text-[#005ba9]">{order.transactionId}</span>
            </div>
            <div className="flex justify-between">
              <span className="text-[#414944]">Thời gian thanh toán:</span>
              <span>{order.date} 09:30:15</span>
            </div>
            <div className="flex justify-between">
              <span className="text-[#414944]">Phương thức:</span>
              <span className="font-semibold text-[#161b28]">VNPAY QR (Nội địa)</span>
            </div>
          </div>

          {/* Items Table */}
          <div className="border-t border-b border-dashed border-black/15 py-2 space-y-1.5">
            {order.items.map((item, idx) => (
              <div key={idx} className="flex justify-between items-center">
                <div className="flex-1 pr-2">
                  <p className="font-bold text-[#161b28] truncate">{item.name}</p>
                  <p className="text-[10px] text-[#414944]">SL: 0{item.quantity}</p>
                </div>
                <span className="font-bold text-[#161b28]">
                  {(item.price * item.quantity).toLocaleString('vi-VN')}₫
                </span>
              </div>
            ))}
          </div>

          {/* Total & Seal */}
          <div className="flex items-center justify-between pt-1">
            <span className="text-sm font-bold text-[#161b28]">Tổng tiền thanh toán:</span>
            <span className="text-base font-bold text-[#2d5a46]">
              {order.totalAmount.toLocaleString('vi-VN')}₫
            </span>
          </div>

          <div className="my-2 p-2 rounded-lg bg-[#bceed3]/30 border border-[#2d5a46]/30 text-center text-[#002114] font-bold text-xs flex items-center justify-center gap-1.5">
            <span className="material-symbols-outlined text-[16px] text-[#2d5a46]">verified</span>
            <span>GIAO DỊCH ĐÃ ĐỐI SOÁT & XÁC NHẬN BỞI VNPAY</span>
          </div>

          {/* Action Buttons */}
          <div className="grid grid-cols-2 gap-2 pt-2">
            <button
              onClick={handleDownload}
              className="h-10 rounded-xl bg-[#f2f3ff] hover:bg-[#e9edff] text-[#161b28] font-bold flex items-center justify-center gap-1.5"
            >
              <span className="material-symbols-outlined text-[16px]">download</span>
              <span>Lưu PDF</span>
            </button>
            <button
              onClick={() => {
                onShowToast('Đang kết nối máy in hóa đơn...');
              }}
              className="h-10 rounded-xl bg-[#2d5a46] text-white font-bold flex items-center justify-center gap-1.5 hover:bg-[#134230]"
            >
              <span className="material-symbols-outlined text-[16px]">print</span>
              <span>In hóa đơn</span>
            </button>
          </div>
        </div>
      </div>
    </div>
  );
};
