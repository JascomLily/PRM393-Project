import React, { useState } from 'react';
import { Order, UserProfile } from '../types';

interface OrdersViewProps {
  orders: Order[];
  user: UserProfile;
  onOpenQRScanner: () => void;
  onOpenDriverTracking: (order: Order) => void;
  onOpenInvoice: (order: Order) => void;
  onSubmitReview: (orderId: string, stars: number, tags: string[], comment: string) => void;
  onShowToast: (msg: string) => void;
}

export const OrdersView: React.FC<OrdersViewProps> = ({
  orders,
  onOpenQRScanner,
  onOpenDriverTracking,
  onOpenInvoice,
  onSubmitReview,
  onShowToast,
}) => {
  const [filter, setFilter] = useState<string>('all');
  const [rating, setRating] = useState<number>(5);
  const [selectedTags, setSelectedTags] = useState<string[]>([
    'Gỗ đẹp chắc chắn',
    'Hướng dẫn 3D rất dễ lắp',
  ]);
  const [commentText, setCommentText] = useState<string>(
    'Rất hài lòng! Gỗ thơm tự nhiên, ăn khớp 100% bản vẽ 3D.'
  );
  const [isSubmittingReview, setIsSubmittingReview] = useState<boolean>(false);
  const [reviewSubmitted, setReviewSubmitted] = useState<boolean>(false);
  const [copiedCode, setCopiedCode] = useState<string | null>(null);

  const ratingLabels = [
    '',
    'Chưa hài lòng - Cần hỗ trợ phụ kiện',
    'Tạm ổn - Cần cải thiện đóng gói',
    'Khá tốt - Đúng như mô tả',
    'Hài lòng - Chất liệu gỗ đẹp',
    'Rất hài lòng! Gỗ thơm tự nhiên, ăn khớp 100% bản vẽ 3D',
  ];

  const availableTags = [
    'Gỗ đẹp chắc chắn',
    'Hướng dẫn 3D rất dễ lắp',
    'Đầy đủ phụ kiện',
    'Shipper nhiệt tình',
  ];

  const toggleTag = (tag: string) => {
    setSelectedTags((prev) =>
      prev.includes(tag) ? prev.filter((t) => t !== tag) : [...prev, tag]
    );
  };

  const handleCopyCode = (code: string) => {
    if (navigator.clipboard) {
      navigator.clipboard.writeText(code);
    }
    setCopiedCode(code);
    setTimeout(() => setCopiedCode(null), 2000);
    onShowToast(`Đã sao chép mã đơn: ${code}`);
  };

  const handleSendReview = (orderId: string) => {
    setIsSubmittingReview(true);
    setTimeout(() => {
      onSubmitReview(orderId, rating, selectedTags, commentText);
      setIsSubmittingReview(false);
      setReviewSubmitted(true);
      onShowToast('🎉 Đã nhận +50 Xu thưởng Furni vào tài khoản!');
    }, 700);
  };

  const filteredOrders = orders.filter((order) => {
    if (filter === 'all') return true;
    if (filter === 'vnpay') return order.status === 'pending_vnpay';
    if (filter === 'shipping') return order.status === 'shipping';
    if (filter === 'completed') return order.status === 'completed';
    if (filter === 'support') return order.status === 'support_needed';
    return true;
  });

  const shippingCount = orders.filter((o) => o.status === 'shipping').length;
  const completedCount = orders.filter((o) => o.status === 'completed').length;

  return (
    <div className="flex flex-col w-full max-w-5xl mx-auto px-4 pb-20">
      {/* Top Atmosphere */}
      <div className="pt-3 pb-2 flex flex-col gap-1">
        <div className="flex items-center justify-between">
          <span className="text-[11px] uppercase tracking-wider text-[#805528] font-bold">
            Furni3D Experience
          </span>
          <span className="inline-flex items-center gap-1.5 px-2.5 py-0.5 rounded-full bg-[#bceed3] text-[#002114] text-[10px] font-bold uppercase">
            <span className="w-1.5 h-1.5 rounded-full bg-[#134230] animate-pulse" />
            Đồng bộ trực tiếp
          </span>
        </div>
        <h2 className="text-xl font-bold text-[#161b28]">Quản lý đơn hàng & Thanh toán</h2>
        <p className="text-xs text-[#414944]">
          Theo dõi hành trình nội thất, kiểm tra đối soát VNPAY và chia sẻ cảm nhận không gian.
        </p>
      </div>

      {/* Horizontal Scroll Filter Bar */}
      <div className="flex items-center gap-2 overflow-x-auto py-2 -mx-4 px-4 no-scrollbar">
        <button
          onClick={() => setFilter('all')}
          className={`whitespace-nowrap px-4 py-2 rounded-full text-xs font-bold transition-all shadow-sm ${
            filter === 'all'
              ? 'bg-[#2d5a46] text-white'
              : 'bg-[#e9edff] text-[#414944] hover:text-[#161b28]'
          }`}
        >
          Tất cả
        </button>
        <button
          onClick={() => setFilter('vnpay')}
          className={`whitespace-nowrap px-4 py-2 rounded-full text-xs font-bold transition-all shadow-sm ${
            filter === 'vnpay'
              ? 'bg-[#2d5a46] text-white'
              : 'bg-[#e9edff] text-[#414944] hover:text-[#161b28]'
          }`}
        >
          Chờ thanh toán (VNPAY)
        </button>
        <button
          onClick={() => setFilter('shipping')}
          className={`whitespace-nowrap px-4 py-2 rounded-full text-xs font-bold transition-all shadow-sm flex items-center gap-1.5 ${
            filter === 'shipping'
              ? 'bg-[#2d5a46] text-white'
              : 'bg-[#e9edff] text-[#414944] hover:text-[#161b28]'
          }`}
        >
          <span>Đang giao hàng</span>
          <span className="w-5 h-5 rounded-full bg-[#805528] text-white text-[10px] font-bold flex items-center justify-center">
            {shippingCount}
          </span>
        </button>
        <button
          onClick={() => setFilter('completed')}
          className={`whitespace-nowrap px-4 py-2 rounded-full text-xs font-bold transition-all shadow-sm flex items-center gap-1.5 ${
            filter === 'completed'
              ? 'bg-[#2d5a46] text-white'
              : 'bg-[#e9edff] text-[#414944] hover:text-[#161b28]'
          }`}
        >
          <span>Đã hoàn thành</span>
          <span className="w-5 h-5 rounded-full bg-[#dee2f4] text-[#161b28] text-[10px] font-bold flex items-center justify-center">
            {completedCount}
          </span>
        </button>
        <button
          onClick={() => setFilter('support')}
          className={`whitespace-nowrap px-4 py-2 rounded-full text-xs font-bold transition-all shadow-sm ${
            filter === 'support'
              ? 'bg-[#2d5a46] text-white'
              : 'bg-[#e9edff] text-[#414944] hover:text-[#161b28]'
          }`}
        >
          Yêu cầu hỗ trợ
        </button>
      </div>

      {/* Orders List */}
      <div className="flex flex-col gap-4 mt-2">
        {filteredOrders.map((order) => {
          const isShipping = order.status === 'shipping';
          const isCompleted = order.status === 'completed';

          return (
            <div
              key={order.id}
              className="bg-white rounded-2xl shadow-md p-4 flex flex-col gap-4 border border-black/[0.04]"
            >
              {/* Header */}
              <div className="flex items-start justify-between gap-2 pb-1 border-b border-black/[0.04]">
                <div className="flex flex-col">
                  <div className="flex items-center gap-2">
                    <span className="text-base font-bold text-[#161b28]">{order.code}</span>
                    {isShipping && (
                      <span className="inline-flex items-center gap-1 px-2 py-0.5 rounded-full bg-[#ffdcbf] text-[#2d1600] text-[10px] font-bold">
                        <span
                          className="material-symbols-outlined text-[13px]"
                          style={{ fontVariationSettings: "'FILL' 1" }}
                        >
                          local_shipping
                        </span>
                        ĐANG VẬN CHUYỂN
                      </span>
                    )}
                    {isCompleted && (
                      <span className="inline-flex items-center gap-1 px-2 py-0.5 rounded-full bg-[#bceed3] text-[#002114] text-[10px] font-bold">
                        <span
                          className="material-symbols-outlined text-[13px]"
                          style={{ fontVariationSettings: "'FILL' 1" }}
                        >
                          task_alt
                        </span>
                        ĐÃ GIAO THÀNH CÔNG
                      </span>
                    )}
                  </div>
                  {order.estimatedDelivery ? (
                    <div className="flex items-center gap-1 mt-1 text-[#414944] text-xs">
                      <span className="material-symbols-outlined text-[15px] text-[#805528]">schedule</span>
                      <span>
                        Dự kiến: <strong className="text-[#161b28]">{order.estimatedDelivery}</strong>
                      </span>
                    </div>
                  ) : (
                    <span className="text-xs text-[#414944] mt-1">
                      Giao hoàn tất ngày {order.date} • Lắp ráp hoàn thiện
                    </span>
                  )}
                </div>

                <div className="flex items-center gap-1">
                  <button
                    onClick={() => handleCopyCode(order.code)}
                    aria-label="Sao chép mã đơn"
                    className="w-8 h-8 rounded-full bg-[#f2f3ff] flex items-center justify-center text-[#414944] hover:bg-[#e9edff] transition-colors"
                    title="Sao chép mã"
                  >
                    <span className="material-symbols-outlined text-[17px]">
                      {copiedCode === order.code ? 'check' : 'content_copy'}
                    </span>
                  </button>
                  {isCompleted && (
                    <div className="w-8 h-8 rounded-full bg-[#bceed3] flex items-center justify-center text-[#134230]">
                      <span
                        className="material-symbols-outlined text-[18px]"
                        style={{ fontVariationSettings: "'FILL' 1" }}
                      >
                        verified
                      </span>
                    </div>
                  )}
                </div>
              </div>

              {/* Items List */}
              {order.items.map((item, idx) => (
                <div
                  key={idx}
                  className="bg-[#f2f3ff] rounded-xl p-2.5 flex items-center gap-3 border border-black/[0.02]"
                >
                  <div className="relative w-16 h-16 rounded-lg overflow-hidden flex-shrink-0 bg-white shadow-sm">
                    <img
                      className="w-full h-full object-cover"
                      src={item.image}
                      alt={item.name}
                    />
                    <span className="absolute bottom-0.5 right-0.5 px-1 py-0.2 rounded bg-white/90 text-[9px] font-bold text-[#2d5a46]">
                      3D AR
                    </span>
                  </div>
                  <div className="flex-1 min-w-0">
                    <h3 className="text-xs font-bold text-[#161b28] truncate">{item.name}</h3>
                    <p className="text-[11px] text-[#414944] line-clamp-1">{item.variant}</p>
                    <div className="flex items-center justify-between mt-1">
                      <span className="text-[10px] text-[#805528] font-medium">{item.packageInfo}</span>
                      <span className="text-xs font-bold text-[#161b28]">× 0{item.quantity}</span>
                    </div>
                  </div>
                </div>
              ))}

              {/* Payment Status Badge (VNPAY Verified) */}
              <div className="bg-[#2d5a46]/10 rounded-xl p-3 flex items-center justify-between border border-[#2d5a46]/20">
                <div className="flex items-center gap-2.5 min-w-0">
                  <div className="w-9 h-9 rounded-lg bg-white flex items-center justify-center flex-shrink-0 shadow-sm border border-black/5">
                    <span
                      className="material-symbols-outlined text-[#2d5a46] text-[20px]"
                      style={{ fontVariationSettings: "'FILL' 1" }}
                    >
                      qr_code_scanner
                    </span>
                  </div>
                  <div className="flex flex-col min-w-0">
                    <span className="text-xs font-bold text-[#2d5a46] truncate">
                      Cổng VNPAY QR (Nội địa & Mobile Banking)
                    </span>
                    <span className="text-[11px] text-[#414944] truncate">
                      Mã GD: {order.transactionId || 'VNP-20240310-88219'}
                    </span>
                  </div>
                </div>
                <div className="text-right flex-shrink-0 pl-2">
                  <span className="text-sm font-bold text-[#134230] block leading-tight">
                    {order.totalAmount.toLocaleString('vi-VN')}₫
                  </span>
                  <span className="text-[10px] text-[#2d5a46] uppercase font-bold">
                    {order.paymentStatus === 'PAID' ? 'Đã thanh toán' : 'Chờ thanh toán'}
                  </span>
                </div>
              </div>

              {/* TIMELINE TRACKING (If in shipping) */}
              {isShipping && order.timeline && (
                <div className="flex flex-col gap-2 pt-1">
                  <div className="flex items-center justify-between">
                    <span className="text-xs font-bold text-[#161b28]">Hành trình giao kiện & Lắp ráp</span>
                    <span className="text-[11px] text-[#805528] flex items-center gap-1 font-bold">
                      <span className="w-2 h-2 rounded-full bg-[#805528] animate-ping" />
                      Shipper đang di chuyển
                    </span>
                  </div>

                  <div className="relative pl-6 flex flex-col gap-4 mt-2">
                    {/* Progress Bar Lines */}
                    <div className="absolute left-[11px] top-3 bottom-3 w-0.5 bg-[#dee2f4]" />
                    <div className="absolute left-[11px] top-3 h-[68%] w-0.5 bg-[#2d5a46] transition-all duration-700" />

                    {order.timeline.map((st) => (
                      <div key={st.id} className={`relative flex items-start gap-3 ${st.status === 'upcoming' ? 'opacity-60' : ''}`}>
                        <div
                          className={`absolute -left-6 w-6 h-6 rounded-full flex items-center justify-center shadow-sm text-xs ${
                            st.status === 'completed'
                              ? 'bg-[#2d5a46] text-white'
                              : st.status === 'current'
                              ? 'bg-white text-[#805528] ring-2 ring-[#805528]'
                              : 'bg-[#e3e7fa] text-[#414944]'
                          }`}
                        >
                          {st.status === 'completed' ? (
                            <span className="material-symbols-outlined text-[14px]">check</span>
                          ) : st.status === 'current' ? (
                            <span className="w-2 h-2 rounded-full bg-[#805528]" />
                          ) : (
                            st.id
                          )}
                        </div>

                        <div className={`flex-1 min-w-0 ${st.status === 'current' ? 'bg-[#ffdcbf]/30 p-2.5 rounded-lg border border-[#805528]/15' : ''}`}>
                          <div className="flex items-center justify-between">
                            <span className={`text-xs ${st.status === 'current' ? 'font-bold text-[#161b28]' : 'font-medium text-[#161b28]'}`}>
                              {st.title}
                            </span>
                            <span className={`text-[10px] ${st.status === 'current' ? 'font-bold text-[#805528]' : 'text-[#414944]'}`}>
                              {st.time}
                            </span>
                          </div>
                          <p className="text-[11px] text-[#414944] mt-0.5 leading-snug">{st.description}</p>
                        </div>
                      </div>
                    ))}
                  </div>

                  {/* Actions for active shipping */}
                  <div className="grid grid-cols-2 gap-2 pt-2">
                    <button
                      onClick={() => onOpenInvoice(order)}
                      className="h-11 px-3 rounded-lg bg-[#f2f3ff] hover:bg-[#e9edff] text-[#161b28] text-xs font-bold flex items-center justify-center gap-1.5 transition-all"
                      type="button"
                    >
                      <span className="material-symbols-outlined text-[18px] text-[#805528]">receipt_long</span>
                      <span>Hóa đơn VNPAY</span>
                    </button>
                    <button
                      onClick={() => onOpenDriverTracking(order)}
                      className="h-11 px-3 rounded-lg bg-[#134230] hover:bg-[#2d5a46] text-white text-xs font-bold flex items-center justify-center gap-1.5 shadow-sm transition-all active:scale-95"
                      type="button"
                    >
                      <span className="material-symbols-outlined text-[18px]">near_me</span>
                      <span>Theo dõi tài xế</span>
                    </button>
                  </div>
                </div>
              )}

              {/* REVIEW SECTION (If order is completed) */}
              {isCompleted && (
                <div className="bg-[#f2f3ff]/70 rounded-xl p-3 flex flex-col gap-3 border border-black/[0.03]">
                  <div className="flex items-center justify-between">
                    <div className="flex items-center gap-2">
                      <span className="material-symbols-outlined text-[#805528] text-[20px]">hotel_class</span>
                      <span className="text-xs font-bold text-[#161b28]">Đánh giá chất lượng thực tế</span>
                    </div>
                    <span className="text-[10px] px-2 py-0.5 rounded-full bg-[#fec38d] text-[#794f23] font-bold">
                      +50 Xu Furni
                    </span>
                  </div>

                  {/* 5-Star Interactive Rater */}
                  <div className="flex flex-col items-center py-1 gap-1">
                    <div className="flex items-center gap-2">
                      {[1, 2, 3, 4, 5].map((star) => (
                        <button
                          key={star}
                          onClick={() => setRating(star)}
                          className="p-1 hover:scale-110 active:scale-95 transition-transform"
                          type="button"
                        >
                          <span
                            className={`material-symbols-outlined text-[28px] ${
                              star <= rating ? 'text-[#805528]' : 'text-[#dee2f4]'
                            }`}
                            style={{ fontVariationSettings: `'FILL' ${star <= rating ? 1 : 0}` }}
                          >
                            star
                          </span>
                        </button>
                      ))}
                    </div>
                    <span className="text-xs text-[#805528] font-medium text-center">
                      {ratingLabels[rating]}
                    </span>
                  </div>

                  {/* Feedback Tags */}
                  <div className="flex flex-wrap gap-1.5">
                    {availableTags.map((tag) => {
                      const isTagSelected = selectedTags.includes(tag);
                      return (
                        <button
                          key={tag}
                          onClick={() => toggleTag(tag)}
                          className={`px-3 py-1.5 rounded-full text-xs font-medium transition-all ${
                            isTagSelected
                              ? 'bg-[#2d5a46] text-white shadow-sm'
                              : 'bg-white text-[#414944] hover:bg-[#e9edff]'
                          }`}
                        >
                          {isTagSelected ? `✓ ${tag}` : tag}
                        </button>
                      );
                    })}
                  </div>

                  {/* Review Textarea */}
                  <div className="relative">
                    <textarea
                      value={commentText}
                      onChange={(e) => setCommentText(e.target.value)}
                      className="w-full bg-white rounded-lg p-2.5 text-xs text-[#161b28] placeholder:text-[#414944]/60 focus:outline-none focus:ring-1 focus:ring-[#2d5a46] shadow-sm resize-none border border-black/5"
                      placeholder="Chia sẻ thêm cảm nhận về độ hoàn thiện, màu sắc vân gỗ..."
                      rows={2}
                    />
                  </div>

                  {/* Submit Review Action */}
                  <button
                    onClick={() => handleSendReview(order.id)}
                    disabled={isSubmittingReview || reviewSubmitted}
                    className={`w-full h-11 rounded-lg text-xs font-bold flex items-center justify-center gap-2 transition-all shadow-sm ${
                      reviewSubmitted
                        ? 'bg-[#2d5a46] text-white'
                        : 'bg-[#805528] hover:bg-[#653e13] text-white active:scale-[0.99]'
                    }`}
                  >
                    {isSubmittingReview ? (
                      <>
                        <span className="material-symbols-outlined text-[16px] animate-spin">sync</span>
                        <span>Đang ghi nhận vào ví Furni...</span>
                      </>
                    ) : reviewSubmitted ? (
                      <>
                        <span className="material-symbols-outlined text-[18px]">check_circle</span>
                        <span>Đã nhận 50 xu thưởng! Cảm ơn bạn</span>
                      </>
                    ) : (
                      <>
                        <span className="material-symbols-outlined text-[18px]">redeem</span>
                        <span>Gửi đánh giá nhận 50 xu thưởng Furni</span>
                      </>
                    )}
                  </button>
                </div>
              )}
            </div>
          );
        })}
      </div>

      {/* Floating Bottom Action Capsule */}
      <div className="sticky bottom-20 z-30 mt-6 w-full flex justify-center">
        <button
          onClick={onOpenQRScanner}
          className="w-full max-w-sm h-12 px-5 rounded-full bg-[#2d5a46] text-white text-xs font-bold flex items-center justify-center gap-2 shadow-xl hover:bg-[#134230] active:scale-95 transition-all"
        >
          <span className="material-symbols-outlined text-[20px]">qr_code_scanner</span>
          <span>Quét mã QR sản phẩm để xem hướng dẫn lắp</span>
          <span className="material-symbols-outlined text-[16px]">arrow_forward</span>
        </button>
      </div>
    </div>
  );
};
