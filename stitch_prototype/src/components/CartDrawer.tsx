import React, { useState } from 'react';
import { DiscountVoucher, UserProfile } from '../types';

export interface CartItem {
  id: string;
  name: string;
  price: number;
  quantity: number;
  image: string;
  variant?: string;
}

interface CartDrawerProps {
  isOpen: boolean;
  items: CartItem[];
  vouchers: DiscountVoucher[];
  user: UserProfile | null;
  onClose: () => void;
  onUpdateQty: (id: string, delta: number) => void;
  onRemoveItem: (id: string) => void;
  onClearCart?: () => void;
  onProceedCheckout: (details: {
    discountAmount: number;
    appliedCode: string;
    coinsUsed: number;
    coinsDiscount: number;
  }) => void;
  onRequireLogin: () => void;
  onShowToast: (msg: string) => void;
}

export const CartDrawer: React.FC<CartDrawerProps> = ({
  isOpen,
  items,
  vouchers,
  user,
  onClose,
  onUpdateQty,
  onRemoveItem,
  onClearCart,
  onProceedCheckout,
  onRequireLogin,
  onShowToast,
}) => {
  const [voucherCode, setVoucherCode] = useState<string>('');
  const [appliedVoucher, setAppliedVoucher] = useState<DiscountVoucher | null>(null);
  const [useFurniCoins, setUseFurniCoins] = useState<boolean>(false);

  if (!isOpen) return null;

  const subtotal = items.reduce((sum, item) => sum + item.price * item.quantity, 0);

  // Voucher discount calculation
  let voucherDiscount = 0;
  if (appliedVoucher) {
    if (appliedVoucher.discountType === 'percentage') {
      voucherDiscount = Math.round((subtotal * appliedVoucher.discountValue) / 100);
    } else {
      voucherDiscount = appliedVoucher.discountValue;
    }
  }

  // FurniCoins discount calculation (1 xu = 1.000đ)
  const userCoins = user ? user.furniCoins : 0;
  const maxCoinsAllowed = Math.min(userCoins, Math.floor((subtotal - voucherDiscount) / 1000));
  const coinsUsed = useFurniCoins && maxCoinsAllowed > 0 ? maxCoinsAllowed : 0;
  const coinsDiscount = coinsUsed * 1000;

  const totalDiscount = voucherDiscount + coinsDiscount;
  const shipping = subtotal > 2000000 || items.length === 0 ? 0 : 45000;
  const finalTotal = Math.max(0, subtotal - totalDiscount + shipping);

  const handleApplyVoucher = (code: string) => {
    const cleanCode = code.toUpperCase().trim();
    if (!cleanCode) {
      onShowToast('Vui lòng nhập mã giảm giá');
      return;
    }

    const match = vouchers.find((v) => v.code.toUpperCase() === cleanCode && v.isActive);
    if (!match) {
      onShowToast('Mã voucher không hợp lệ hoặc đã hết hạn');
      return;
    }
    if (subtotal < match.minSpend) {
      onShowToast(`Đơn hàng tối thiểu ${match.minSpend.toLocaleString('vi-VN')}₫ để áp dụng`);
      return;
    }
    setAppliedVoucher(match);
    setVoucherCode(match.code);
    onShowToast(`Đã áp dụng mã giảm giá: ${match.code}`);
  };

  const handleRemoveVoucher = () => {
    setAppliedVoucher(null);
    setVoucherCode('');
    onShowToast('Đã hủy mã voucher');
  };

  const handleCheckoutClick = () => {
    if (!user) {
      onShowToast('Vui lòng đăng nhập để hoàn tất thanh toán & tích lũy xu');
      onRequireLogin();
      return;
    }

    onProceedCheckout({
      discountAmount: voucherDiscount,
      appliedCode: appliedVoucher?.code || '',
      coinsUsed,
      coinsDiscount,
    });
  };

  return (
    <div className="fixed inset-0 z-50 bg-black/60 backdrop-blur-sm flex justify-end animate-fadeIn">
      <div className="bg-[#faf8ff] w-full max-w-md h-full flex flex-col justify-between shadow-2xl animate-slideLeft">
        {/* Header */}
        <div className="p-4 bg-white border-b border-black/5 flex items-center justify-between pt-safe">
          <div className="flex items-center gap-2">
            <div className="w-8 h-8 rounded-xl bg-[#2d5a46]/10 text-[#2d5a46] flex items-center justify-center">
              <span className="material-symbols-outlined text-[19px]">shopping_bag</span>
            </div>
            <div>
              <h2 className="text-sm font-bold text-[#161b28]">Giỏ hàng của bạn ({items.length})</h2>
              <span className="text-[10px] text-[#717973]">Nội thất 3D & Linh kiện thông minh</span>
            </div>
          </div>
          <div className="flex items-center gap-1">
            {items.length > 0 && onClearCart && (
              <button
                onClick={onClearCart}
                className="text-[11px] font-semibold text-red-500 hover:underline px-2 py-1"
              >
                Xóa hết
              </button>
            )}
            <button
              onClick={onClose}
              className="w-8 h-8 rounded-full bg-[#f2f3ff] flex items-center justify-center text-[#414944] hover:bg-[#e9edff]"
            >
              <span className="material-symbols-outlined text-[18px]">close</span>
            </button>
          </div>
        </div>

        {/* Items List */}
        <div className="flex-1 overflow-y-auto p-4 space-y-3">
          {items.length === 0 ? (
            <div className="flex flex-col items-center justify-center h-72 text-center text-[#414944]">
              <div className="w-16 h-16 rounded-full bg-[#f2f3ff] flex items-center justify-center mb-3">
                <span className="material-symbols-outlined text-[32px] text-[#c0c9c2]">
                  remove_shopping_cart
                </span>
              </div>
              <p className="text-sm font-bold text-[#161b28]">Giỏ hàng của bạn đang trống</p>
              <p className="text-xs text-[#717973] mt-1 max-w-xs">
                Hãy khám phá các mẫu nội thất 3D và linh kiện chính hãng để bắt đầu mua sắm!
              </p>
              <button
                onClick={onClose}
                className="mt-4 px-4 py-2 rounded-xl bg-[#2d5a46] text-white text-xs font-bold shadow-sm"
              >
                Khám phá ngay
              </button>
            </div>
          ) : (
            items.map((item) => (
              <div
                key={item.id}
                className="bg-white p-3 rounded-2xl shadow-sm border border-black/5 flex items-center gap-3"
              >
                <div className="w-16 h-16 rounded-xl bg-[#f2f3ff] overflow-hidden flex-shrink-0 p-1 border border-black/5">
                  <img
                    src={item.image}
                    alt={item.name}
                    className="w-full h-full object-cover rounded-lg"
                  />
                </div>
                <div className="flex-1 min-w-0">
                  <h3 className="text-xs font-bold text-[#161b28] truncate">{item.name}</h3>
                  {item.variant && (
                    <p className="text-[10px] text-[#717973] truncate">{item.variant}</p>
                  )}
                  <span className="text-xs font-bold text-[#2d5a46] block mt-1">
                    {item.price.toLocaleString('vi-VN')}₫
                  </span>
                </div>

                {/* Qty & Remove */}
                <div className="flex flex-col items-end gap-2">
                  <button
                    onClick={() => onRemoveItem(item.id)}
                    className="text-[#ba1a1a] hover:opacity-75 p-0.5"
                    title="Xóa món này"
                  >
                    <span className="material-symbols-outlined text-[16px]">delete</span>
                  </button>
                  <div className="flex items-center bg-[#f2f3ff] rounded-lg p-0.5 border border-black/5">
                    <button
                      onClick={() => onUpdateQty(item.id, -1)}
                      className="w-6 h-6 flex items-center justify-center text-[#414944] hover:text-[#161b28]"
                    >
                      <span className="material-symbols-outlined text-[13px]">remove</span>
                    </button>
                    <span className="w-6 text-center text-xs font-bold text-[#161b28]">
                      {item.quantity}
                    </span>
                    <button
                      onClick={() => onUpdateQty(item.id, 1)}
                      className="w-6 h-6 flex items-center justify-center text-[#414944] hover:text-[#161b28]"
                    >
                      <span className="material-symbols-outlined text-[13px]">add</span>
                    </button>
                  </div>
                </div>
              </div>
            ))
          )}

          {/* Vouchers Section */}
          {items.length > 0 && (
            <div className="bg-white p-3.5 rounded-2xl shadow-sm border border-black/5 space-y-2.5">
              <div className="flex items-center justify-between">
                <span className="text-xs font-bold text-[#161b28] flex items-center gap-1.5">
                  <span className="material-symbols-outlined text-[16px] text-[#2d5a46]">sell</span>
                  <span>Mã ưu đãi Furni3D:</span>
                </span>
                {appliedVoucher && (
                  <button
                    onClick={handleRemoveVoucher}
                    className="text-[10px] font-semibold text-red-500 hover:underline"
                  >
                    Bỏ chọn
                  </button>
                )}
              </div>

              <div className="flex items-center gap-2">
                <input
                  type="text"
                  value={voucherCode}
                  onChange={(e) => setVoucherCode(e.target.value)}
                  placeholder="Nhập mã (VD: JAPANDI2025)"
                  className="flex-1 h-9 px-3 rounded-xl bg-[#f2f3ff] text-xs uppercase font-bold text-[#161b28] focus:outline-none focus:ring-1 focus:ring-[#2d5a46]"
                />
                <button
                  onClick={() => handleApplyVoucher(voucherCode)}
                  className="h-9 px-3.5 rounded-xl bg-[#2d5a46] text-white text-xs font-bold active:scale-95 transition-transform"
                >
                  Áp dụng
                </button>
              </div>

              {/* Quick voucher suggestion tags */}
              <div className="flex flex-wrap gap-1.5 pt-1">
                {vouchers
                  .filter((v) => v.isActive)
                  .map((v) => {
                    const isSelected = appliedVoucher?.code === v.code;
                    return (
                      <button
                        key={v.code}
                        onClick={() => handleApplyVoucher(v.code)}
                        className={`px-2.5 py-1 rounded-lg text-[10px] font-bold flex items-center gap-1 transition-all ${
                          isSelected
                            ? 'bg-[#2d5a46] text-white shadow-xs'
                            : 'bg-[#e9edff] text-[#2d5a46] hover:bg-[#dee2f4]'
                        }`}
                      >
                        <span>🏷️</span>
                        <span>{v.code}</span>
                        <span className="text-[9px] opacity-80">
                          ({v.discountType === 'percentage' ? `-${v.discountValue}%` : `-${(v.discountValue / 1000)}k`})
                        </span>
                      </button>
                    );
                  })}
              </div>
            </div>
          )}

          {/* FurniCoins Promotion Redemption (From Doc) */}
          {items.length > 0 && user && (
            <div className="bg-gradient-to-r from-[#fec38d]/20 to-[#fde7cf]/30 p-3.5 rounded-2xl border border-[#805528]/20 flex items-start justify-between gap-3 shadow-xs">
              <div className="flex items-start gap-2.5">
                <span className="material-symbols-outlined text-[#805528] text-[22px] mt-0.5">
                  monetization_on
                </span>
                <div>
                  <div className="flex items-center gap-1.5">
                    <span className="text-xs font-bold text-[#805528]">Ví Xu thưởng FurniCoins</span>
                    <span className="px-1.5 py-0.2 rounded-full bg-[#805528]/10 text-[9px] font-bold text-[#805528]">
                      {userCoins} Xu
                    </span>
                  </div>
                  <p className="text-[10px] text-[#794f23] mt-0.5 leading-snug">
                    Đổi {maxCoinsAllowed} xu để giảm ngay {(maxCoinsAllowed * 1000).toLocaleString('vi-VN')}₫ vào đơn này (1 xu = 1.000₫).
                  </p>
                </div>
              </div>

              <label className="relative inline-flex items-center cursor-pointer mt-1">
                <input
                  type="checkbox"
                  disabled={userCoins === 0 || maxCoinsAllowed === 0}
                  checked={useFurniCoins}
                  onChange={(e) => setUseFurniCoins(e.target.checked)}
                  className="sr-only peer"
                />
                <div className="w-9 h-5 bg-gray-300 peer-focus:outline-none rounded-full peer peer-checked:after:translate-x-full peer-checked:after:border-white after:content-[''] after:absolute after:top-[2px] after:left-[2px] after:bg-white after:border-gray-300 after:border after:rounded-full after:h-4 after:w-4 after:transition-all peer-checked:bg-[#805528]"></div>
              </label>
            </div>
          )}

          {/* Guest prompt to login for rewards */}
          {items.length > 0 && !user && (
            <div className="p-3 rounded-2xl bg-[#bceed3]/30 border border-[#2d5a46]/20 flex items-center justify-between text-xs">
              <div className="flex items-center gap-2 text-[#002114]">
                <span className="material-symbols-outlined text-[#2d5a46] text-[18px]">card_giftcard</span>
                <span>Đăng nhập nhận ngay <strong>100 Xu</strong></span>
              </div>
              <button
                onClick={onRequireLogin}
                className="text-xs font-bold text-[#2d5a46] hover:underline"
              >
                Đăng nhập
              </button>
            </div>
          )}
        </div>

        {/* Footer & Checkout Breakdown */}
        {items.length > 0 && (
          <div className="p-4 bg-white border-t border-black/5 pb-safe space-y-3">
            {/* Breakdown */}
            <div className="space-y-1.5 text-xs">
              <div className="flex justify-between text-[#414944]">
                <span>Tạm tính ({items.length} món):</span>
                <span>{subtotal.toLocaleString('vi-VN')}₫</span>
              </div>
              {voucherDiscount > 0 && (
                <div className="flex justify-between text-[#2d5a46] font-bold">
                  <span>Mã giảm giá ({appliedVoucher?.code}):</span>
                  <span>-{voucherDiscount.toLocaleString('vi-VN')}₫</span>
                </div>
              )}
              {coinsDiscount > 0 && (
                <div className="flex justify-between text-[#805528] font-bold">
                  <span>Trừ xu thưởng ({coinsUsed} Xu):</span>
                  <span>-{coinsDiscount.toLocaleString('vi-VN')}₫</span>
                </div>
              )}
              <div className="flex justify-between text-[#414944]">
                <span>Phí vận chuyển:</span>
                <span>{shipping === 0 ? <strong className="text-emerald-600">Miễn phí</strong> : `${shipping.toLocaleString('vi-VN')}₫`}</span>
              </div>
              <div className="flex justify-between text-base font-bold text-[#161b28] pt-2 border-t">
                <span>Tổng thanh toán:</span>
                <span className="text-[#2d5a46]">{finalTotal.toLocaleString('vi-VN')}₫</span>
              </div>
            </div>

            {/* Checkout CTA */}
            <button
              onClick={handleCheckoutClick}
              className="w-full h-12 rounded-2xl bg-[#2d5a46] text-white text-xs font-bold flex items-center justify-center gap-2 shadow-lg hover:bg-[#134230] active:scale-[0.99] transition-all"
            >
              <span className="material-symbols-outlined text-[20px]">payment</span>
              <span>Tiến hành thanh toán ({finalTotal.toLocaleString('vi-VN')}₫)</span>
            </button>
          </div>
        )}
      </div>
    </div>
  );
};
