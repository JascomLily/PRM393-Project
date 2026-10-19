import React, { useState, useEffect } from 'react';
import { UserProfile } from '../types';

interface CheckoutModalProps {
  isOpen: boolean;
  amount: number;
  user: UserProfile | null;
  coinsUsed: number;
  voucherCode: string;
  onClose: () => void;
  onPaymentSuccess: (details: {
    transactionId: string;
    paymentMethod: 'VNPAY_QR' | 'COD' | 'BANK_TRANSFER';
    receiverName: string;
    receiverPhone: string;
    shippingAddress: string;
    orderNote: string;
  }) => void;
}

export const CheckoutModal: React.FC<CheckoutModalProps> = ({
  isOpen,
  amount,
  user,
  coinsUsed,
  voucherCode,
  onClose,
  onPaymentSuccess,
}) => {
  // Checkout Steps: 1: Delivery & Method -> 2: VNPAY Gateway / Payment Simulation -> 3: Success
  const [step, setStep] = useState<'info' | 'gateway' | 'otp'>('info');
  const [paymentMethod, setPaymentMethod] = useState<'VNPAY_QR' | 'VNPAY_ATM' | 'COD'>('VNPAY_QR');

  // Customer Delivery Info
  const [receiverName, setReceiverName] = useState(user?.name || 'Đặng Thảo Vy');
  const [receiverPhone, setReceiverPhone] = useState(user?.phone || '0983 838 311');
  const [shippingAddress, setShippingAddress] = useState(
    user?.savedAddress || 'Tòa nhà Landmark 81, P. 22, Q. Bình Thạnh, TP. Hồ Chí Minh'
  );
  const [orderNote, setOrderNote] = useState('Giao hàng giờ hành chính, gọi trước khi giao');

  // VNPAY ATM Sandbox Form states
  const [cardNumber, setCardNumber] = useState('9704 1985 2619 1432');
  const [cardHolder, setCardHolder] = useState('NGUYEN VAN A');
  const [issueDate, setIssueDate] = useState('07/15');
  const [selectedBank, setSelectedBank] = useState('NCB');

  // OTP Simulation
  const [otp, setOtp] = useState('123456');

  // Countdown for VNPAY QR
  const [timeLeft, setTimeLeft] = useState<number>(899); // 14:59
  const [isProcessing, setIsProcessing] = useState<boolean>(false);
  const [txId] = useState<string>(
    `VNP-${new Date().getFullYear()}${String(new Date().getMonth() + 1).padStart(2, '0')}${String(
      new Date().getDate()
    ).padStart(2, '0')}-${Math.floor(10000 + Math.random() * 90000)}`
  );

  // Sync user info when opened
  useEffect(() => {
    if (user) {
      setReceiverName(user.name);
      setReceiverPhone(user.phone);
      if (user.savedAddress) setShippingAddress(user.savedAddress);
    }
    setStep('info');
  }, [isOpen, user]);

  useEffect(() => {
    if (!isOpen || step !== 'gateway') return;
    const timer = setInterval(() => {
      setTimeLeft((prev) => (prev > 0 ? prev - 1 : 0));
    }, 1000);
    return () => clearInterval(timer);
  }, [isOpen, step]);

  if (!isOpen) return null;

  const minutes = Math.floor(timeLeft / 60);
  const seconds = timeLeft % 60;

  // Handle Fill Sandbox Test Card NCB
  const handleFillTestCard = () => {
    setCardNumber('9704 1985 2619 1432');
    setCardHolder('NGUYEN VAN A');
    setIssueDate('07/15');
    setSelectedBank('NCB');
  };

  // Step 1: Proceed from Info to Gateway
  const handleProceedToPayment = (e: React.FormEvent) => {
    e.preventDefault();
    if (!receiverName.trim() || !receiverPhone.trim() || !shippingAddress.trim()) {
      alert('Vui lòng điền đầy đủ thông tin giao hàng');
      return;
    }

    if (paymentMethod === 'COD') {
      // Direct confirm COD
      setIsProcessing(true);
      setTimeout(() => {
        setIsProcessing(false);
        onPaymentSuccess({
          transactionId: `COD-${Date.now().toString().slice(-6)}`,
          paymentMethod: 'COD',
          receiverName,
          receiverPhone,
          shippingAddress,
          orderNote,
        });
      }, 700);
    } else if (paymentMethod === 'VNPAY_ATM') {
      setStep('gateway');
    } else {
      // VNPAY_QR
      setStep('gateway');
    }
  };

  // Step 2: Simulate Payment Success in Gateway
  const handleConfirmVnpayQR = () => {
    setIsProcessing(true);
    setTimeout(() => {
      setIsProcessing(false);
      onPaymentSuccess({
        transactionId: txId,
        paymentMethod: 'VNPAY_QR',
        receiverName,
        receiverPhone,
        shippingAddress,
        orderNote,
      });
    }, 1000);
  };

  const handleConfirmVnpayATM = () => {
    setStep('otp');
  };

  const handleConfirmOtp = () => {
    if (otp !== '123456') {
      alert('Mã OTP không đúng! Vui lòng nhập 123456');
      return;
    }
    setIsProcessing(true);
    setTimeout(() => {
      setIsProcessing(false);
      onPaymentSuccess({
        transactionId: txId,
        paymentMethod: 'BANK_TRANSFER',
        receiverName,
        receiverPhone,
        shippingAddress,
        orderNote,
      });
    }, 1000);
  };

  return (
    <div className="fixed inset-0 z-50 bg-black/70 backdrop-blur-sm flex items-end sm:items-center justify-center p-0 sm:p-4 animate-fadeIn">
      <div className="bg-white rounded-t-3xl sm:rounded-3xl w-full max-w-md overflow-hidden shadow-2xl flex flex-col max-h-[94vh] animate-slideUp sm:animate-scaleUp">
        {/* VNPAY Header */}
        <div className="bg-gradient-to-r from-[#005ba9] to-[#004077] text-white p-4 flex items-center justify-between">
          <div className="flex items-center gap-2.5">
            <div className="w-8 h-8 rounded-xl bg-white flex items-center justify-center text-[#005ba9] font-black text-xs shadow-xs">
              VNP
            </div>
            <div>
              <span className="text-[10px] uppercase font-bold tracking-wider text-white/80 block">
                Cổng thanh toán điện tử
              </span>
              <h3 className="text-sm font-bold leading-tight">
                {step === 'info' && 'Thông tin thanh toán & Giao hàng'}
                {step === 'gateway' && (paymentMethod === 'VNPAY_QR' ? 'Cổng thanh toán VNPAY QR' : 'VNPAY Thẻ ATM nội địa')}
                {step === 'otp' && 'Xác thực OTP ngân hàng'}
              </h3>
            </div>
          </div>
          <button
            onClick={onClose}
            className="w-8 h-8 rounded-full bg-white/20 flex items-center justify-center text-white hover:bg-white/30"
          >
            <span className="material-symbols-outlined text-[18px]">close</span>
          </button>
        </div>

        {/* STEP 1: RECEIVER INFO & PAYMENT METHOD SELECTION */}
        {step === 'info' && (
          <form onSubmit={handleProceedToPayment} className="p-5 overflow-y-auto flex-1 space-y-4 text-xs">
            {/* Amount Summary Card */}
            <div className="bg-[#f2f3ff] p-3.5 rounded-2xl border border-black/5 flex items-center justify-between">
              <div>
                <span className="text-[10px] text-[#717973] uppercase font-bold block">Tổng tiền thanh toán:</span>
                <span className="text-xl font-black text-[#134230]">
                  {amount.toLocaleString('vi-VN')}₫
                </span>
              </div>
              <div className="text-right text-[11px] text-[#414944]">
                {voucherCode && <div className="text-[#2d5a46] font-semibold">Mã: {voucherCode}</div>}
                {coinsUsed > 0 && <div className="text-[#805528] font-semibold">Đã trừ: {coinsUsed} Xu</div>}
              </div>
            </div>

            {/* Delivery Details */}
            <div className="space-y-3">
              <span className="text-xs font-bold text-[#161b28] flex items-center gap-1.5">
                <span className="material-symbols-outlined text-[17px] text-[#2d5a46]">local_shipping</span>
                <span>Thông tin nhận hàng:</span>
              </span>

              <div className="grid grid-cols-2 gap-2">
                <div>
                  <label className="block text-[10px] font-bold text-[#414944] mb-1">Người nhận *</label>
                  <input
                    type="text"
                    required
                    value={receiverName}
                    onChange={(e) => setReceiverName(e.target.value)}
                    className="w-full h-10 px-3 rounded-xl bg-[#f2f3ff] text-xs text-[#161b28] focus:bg-white focus:ring-2 focus:ring-[#2d5a46] outline-none"
                  />
                </div>
                <div>
                  <label className="block text-[10px] font-bold text-[#414944] mb-1">Số điện thoại *</label>
                  <input
                    type="tel"
                    required
                    value={receiverPhone}
                    onChange={(e) => setReceiverPhone(e.target.value)}
                    className="w-full h-10 px-3 rounded-xl bg-[#f2f3ff] text-xs text-[#161b28] focus:bg-white focus:ring-2 focus:ring-[#2d5a46] outline-none"
                  />
                </div>
              </div>

              <div>
                <label className="block text-[10px] font-bold text-[#414944] mb-1">Địa chỉ giao hàng *</label>
                <textarea
                  rows={2}
                  required
                  value={shippingAddress}
                  onChange={(e) => setShippingAddress(e.target.value)}
                  className="w-full p-2.5 rounded-xl bg-[#f2f3ff] text-xs text-[#161b28] focus:bg-white focus:ring-2 focus:ring-[#2d5a46] outline-none resize-none"
                />
              </div>

              <div>
                <label className="block text-[10px] font-bold text-[#414944] mb-1">Ghi chú giao hàng</label>
                <input
                  type="text"
                  value={orderNote}
                  onChange={(e) => setOrderNote(e.target.value)}
                  placeholder="VD: Giao giờ hành chính, gọi trước khi đến..."
                  className="w-full h-9 px-3 rounded-xl bg-[#f2f3ff] text-xs text-[#161b28] focus:bg-white focus:ring-2 focus:ring-[#2d5a46] outline-none"
                />
              </div>
            </div>

            {/* Payment Method Selector */}
            <div className="space-y-2 pt-1 border-t border-black/5">
              <span className="text-xs font-bold text-[#161b28] flex items-center gap-1.5">
                <span className="material-symbols-outlined text-[17px] text-[#005ba9]">account_balance_wallet</span>
                <span>Phương thức thanh toán:</span>
              </span>

              {/* Option 1: VNPAY QR */}
              <label
                className={`p-3 rounded-2xl border flex items-center gap-3 cursor-pointer transition-all ${
                  paymentMethod === 'VNPAY_QR'
                    ? 'border-[#005ba9] bg-[#005ba9]/5 shadow-xs'
                    : 'border-black/10 hover:border-black/20'
                }`}
              >
                <input
                  type="radio"
                  name="paymentMethod"
                  checked={paymentMethod === 'VNPAY_QR'}
                  onChange={() => setPaymentMethod('VNPAY_QR')}
                  className="text-[#005ba9] focus:ring-[#005ba9]"
                />
                <div className="w-8 h-8 rounded-lg bg-[#005ba9] text-white flex items-center justify-center font-bold text-xs flex-shrink-0">
                  QR
                </div>
                <div className="flex-1">
                  <div className="flex items-center justify-between">
                    <span className="font-bold text-[#161b28]">VNPAY QR (Sandbox)</span>
                    <span className="text-[10px] font-bold text-[#005ba9]">Khuyên dùng</span>
                  </div>
                  <p className="text-[10px] text-[#717973]">Quét mã tức thì qua 40+ app Ngân hàng & Ví điện tử</p>
                </div>
              </label>

              {/* Option 2: VNPAY ATM Sandbox */}
              <label
                className={`p-3 rounded-2xl border flex items-center gap-3 cursor-pointer transition-all ${
                  paymentMethod === 'VNPAY_ATM'
                    ? 'border-[#005ba9] bg-[#005ba9]/5 shadow-xs'
                    : 'border-black/10 hover:border-black/20'
                }`}
              >
                <input
                  type="radio"
                  name="paymentMethod"
                  checked={paymentMethod === 'VNPAY_ATM'}
                  onChange={() => setPaymentMethod('VNPAY_ATM')}
                  className="text-[#005ba9] focus:ring-[#005ba9]"
                />
                <div className="w-8 h-8 rounded-lg bg-[#2d5a46] text-white flex items-center justify-center font-bold text-xs flex-shrink-0">
                  <span className="material-symbols-outlined text-[18px]">credit_card</span>
                </div>
                <div className="flex-1">
                  <span className="font-bold text-[#161b28]">Thẻ ATM nội địa (VNPAY Sandbox)</span>
                  <p className="text-[10px] text-[#717973]">Hỗ trợ thẻ test ngân hàng NCB chuẩn Sandbox</p>
                </div>
              </label>

              {/* Option 3: COD */}
              <label
                className={`p-3 rounded-2xl border flex items-center gap-3 cursor-pointer transition-all ${
                  paymentMethod === 'COD'
                    ? 'border-[#2d5a46] bg-[#2d5a46]/5 shadow-xs'
                    : 'border-black/10 hover:border-black/20'
                }`}
              >
                <input
                  type="radio"
                  name="paymentMethod"
                  checked={paymentMethod === 'COD'}
                  onChange={() => setPaymentMethod('COD')}
                  className="text-[#2d5a46] focus:ring-[#2d5a46]"
                />
                <div className="w-8 h-8 rounded-lg bg-amber-600 text-white flex items-center justify-center font-bold text-xs flex-shrink-0">
                  <span className="material-symbols-outlined text-[18px]">payments</span>
                </div>
                <div className="flex-1">
                  <span className="font-bold text-[#161b28]">Thanh toán khi nhận hàng (COD)</span>
                  <p className="text-[10px] text-[#717973]">Kiểm tra hàng trước khi thanh toán cho shipper</p>
                </div>
              </label>
            </div>

            {/* Submit Button */}
            <button
              type="submit"
              disabled={isProcessing}
              className="w-full h-12 rounded-2xl bg-[#005ba9] hover:bg-[#004785] text-white text-xs font-bold flex items-center justify-center gap-2 shadow-md transition-all active:scale-[0.99]"
            >
              <span className="material-symbols-outlined text-[18px]">lock</span>
              <span>
                {paymentMethod === 'COD' ? 'Xác nhận đặt hàng COD' : 'Tiếp tục thanh toán VNPAY'}
              </span>
            </button>
          </form>
        )}

        {/* STEP 2A: VNPAY QR GATEWAY */}
        {step === 'gateway' && paymentMethod === 'VNPAY_QR' && (
          <div className="p-5 flex flex-col items-center gap-3 text-center overflow-y-auto">
            <div>
              <span className="text-[10px] text-[#717973] uppercase font-bold">Đơn vị thụ hưởng:</span>
              <p className="text-sm font-bold text-[#161b28]">FURNI3D VIETNAM SMART LIVING</p>
              <div className="mt-0.5 flex items-center justify-center gap-1.5 text-[11px] text-[#414944]">
                <span>Mã GD:</span>
                <strong className="text-[#005ba9] font-mono">{txId}</strong>
              </div>
            </div>

            {/* Amount Display */}
            <div className="bg-[#f2f3ff] w-full py-2.5 rounded-2xl border border-black/5">
              <span className="text-[10px] text-[#717973] uppercase font-semibold block">Số tiền cần thanh toán</span>
              <span className="text-2xl font-black text-[#005ba9]">
                {amount.toLocaleString('vi-VN')}₫
              </span>
            </div>

            {/* QR Code Graphic with Scan Animation */}
            <div className="relative p-3 bg-white rounded-2xl border-2 border-dashed border-[#005ba9]/40 shadow-sm flex flex-col items-center">
              <svg className="w-44 h-44" viewBox="0 0 100 100" fill="none">
                <rect width="100" height="100" fill="white" />
                <rect x="5" y="5" width="25" height="25" fill="#005ba9" rx="3" />
                <rect x="9" y="9" width="17" height="17" fill="white" />
                <rect x="13" y="13" width="9" height="9" fill="#005ba9" />

                <rect x="70" y="5" width="25" height="25" fill="#005ba9" rx="3" />
                <rect x="74" y="9" width="17" height="17" fill="white" />
                <rect x="78" y="13" width="9" height="9" fill="#005ba9" />

                <rect x="5" y="70" width="25" height="25" fill="#005ba9" rx="3" />
                <rect x="9" y="74" width="17" height="17" fill="white" />
                <rect x="13" y="78" width="9" height="9" fill="#005ba9" />

                {/* QR Matrix */}
                <circle cx="45" cy="15" r="3" fill="#161b28" />
                <circle cx="55" cy="20" r="2.5" fill="#161b28" />
                <circle cx="40" cy="35" r="3.5" fill="#161b28" />
                <circle cx="50" cy="50" r="5" fill="#005ba9" />
                <circle cx="60" cy="40" r="3" fill="#161b28" />
                <circle cx="85" cy="50" r="3.5" fill="#161b28" />
                <circle cx="20" cy="50" r="3" fill="#161b28" />
                <circle cx="35" cy="65" r="2.5" fill="#161b28" />
                <circle cx="50" cy="75" r="3" fill="#161b28" />
                <circle cx="65" cy="85" r="3.5" fill="#161b28" />
                <circle cx="80" cy="75" r="2.5" fill="#161b28" />
                <circle cx="70" cy="60" r="3" fill="#161b28" />
                <circle cx="35" cy="85" r="3.5" fill="#161b28" />
              </svg>

              {/* Scanning line animation */}
              <div className="absolute top-4 left-4 right-4 h-0.5 bg-gradient-to-r from-transparent via-[#005ba9] to-transparent shadow-[0_0_8px_#005ba9] animate-pulse" />

              {/* Countdown Badge */}
              <div className="mt-1 text-[11px] font-bold text-[#805528] flex items-center gap-1">
                <span className="material-symbols-outlined text-[14px]">timer</span>
                <span>
                  Hết hạn sau: {String(minutes).padStart(2, '0')}:{String(seconds).padStart(2, '0')}
                </span>
              </div>
            </div>

            <p className="text-[11px] text-[#414944]">
              Mở ứng dụng Mobile Banking hoặc Ví VNPAY bất kỳ để quét mã thanh toán Sandbox
            </p>

            {/* Simulate Actions */}
            <div className="w-full space-y-2 pt-1">
              <button
                type="button"
                onClick={handleConfirmVnpayQR}
                disabled={isProcessing}
                className="w-full h-11 rounded-2xl bg-[#005ba9] hover:bg-[#004785] text-white text-xs font-bold flex items-center justify-center gap-2 shadow-md active:scale-[0.99] transition-all"
              >
                {isProcessing ? (
                  <>
                    <span className="material-symbols-outlined text-[16px] animate-spin">sync</span>
                    <span>VNPAY đang xác thực thanh toán...</span>
                  </>
                ) : (
                  <>
                    <span className="material-symbols-outlined text-[18px]">verified</span>
                    <span>[Sandbox] Mô phỏng Quét mã thành công</span>
                  </>
                )}
              </button>

              <button
                type="button"
                onClick={() => setStep('info')}
                className="w-full py-2 text-xs font-semibold text-[#717973] hover:text-[#161b28]"
              >
                ← Quay lại đổi phương thức
              </button>
            </div>
          </div>
        )}

        {/* STEP 2B: VNPAY ATM CARD FORM */}
        {step === 'gateway' && paymentMethod === 'VNPAY_ATM' && (
          <div className="p-5 space-y-3.5 text-xs overflow-y-auto">
            {/* Quick Fill Button */}
            <div className="p-2.5 rounded-xl bg-[#005ba9]/10 border border-[#005ba9]/20 flex items-center justify-between">
              <span className="text-[11px] font-bold text-[#005ba9]">Sandbox Test Card NCB:</span>
              <button
                type="button"
                onClick={handleFillTestCard}
                className="px-2.5 py-1 rounded-lg bg-[#005ba9] text-white text-[10px] font-bold shadow-xs hover:bg-[#004785]"
              >
                Điền nhanh thẻ test
              </button>
            </div>

            <div>
              <label className="block text-[10px] font-bold text-[#414944] mb-1">Ngân hàng phát hành</label>
              <select
                value={selectedBank}
                onChange={(e) => setSelectedBank(e.target.value)}
                className="w-full h-10 px-3 rounded-xl bg-[#f2f3ff] text-xs font-bold text-[#161b28] focus:bg-white focus:ring-2 focus:ring-[#005ba9] outline-none"
              >
                <option value="NCB">NCB - Ngân hàng Quốc Dân (Sandbox)</option>
                <option value="VCB">Vietcombank</option>
                <option value="CTG">VietinBank</option>
                <option value="TCB">Techcombank</option>
                <option value="MB">MBBank</option>
              </select>
            </div>

            <div>
              <label className="block text-[10px] font-bold text-[#414944] mb-1">Số thẻ ATM *</label>
              <input
                type="text"
                required
                value={cardNumber}
                onChange={(e) => setCardNumber(e.target.value)}
                placeholder="9704 1985 2619 1432"
                className="w-full h-10 px-3 rounded-xl bg-[#f2f3ff] text-xs font-mono font-bold text-[#161b28] focus:bg-white focus:ring-2 focus:ring-[#005ba9] outline-none"
              />
            </div>

            <div className="grid grid-cols-2 gap-2">
              <div>
                <label className="block text-[10px] font-bold text-[#414944] mb-1">Tên chủ thẻ (Không dấu) *</label>
                <input
                  type="text"
                  required
                  value={cardHolder}
                  onChange={(e) => setCardHolder(e.target.value.toUpperCase())}
                  placeholder="NGUYEN VAN A"
                  className="w-full h-10 px-3 rounded-xl bg-[#f2f3ff] text-xs font-bold uppercase text-[#161b28] focus:bg-white focus:ring-2 focus:ring-[#005ba9] outline-none"
                />
              </div>
              <div>
                <label className="block text-[10px] font-bold text-[#414944] mb-1">Ngày phát hành (MM/YY) *</label>
                <input
                  type="text"
                  required
                  value={issueDate}
                  onChange={(e) => setIssueDate(e.target.value)}
                  placeholder="07/15"
                  className="w-full h-10 px-3 rounded-xl bg-[#f2f3ff] text-xs font-mono font-bold text-center text-[#161b28] focus:bg-white focus:ring-2 focus:ring-[#005ba9] outline-none"
                />
              </div>
            </div>

            <button
              type="button"
              onClick={handleConfirmVnpayATM}
              className="w-full h-11 rounded-2xl bg-[#005ba9] hover:bg-[#004785] text-white text-xs font-bold flex items-center justify-center gap-2 shadow-md active:scale-[0.99] transition-all mt-2"
            >
              <span>Tiếp tục xác thực OTP ngân hàng</span>
              <span className="material-symbols-outlined text-[16px]">arrow_forward</span>
            </button>

            <button
              type="button"
              onClick={() => setStep('info')}
              className="w-full py-1.5 text-xs font-semibold text-[#717973] hover:text-[#161b28] text-center"
            >
              ← Quay lại đổi phương thức
            </button>
          </div>
        )}

        {/* STEP 3: OTP VERIFICATION SCREEN */}
        {step === 'otp' && (
          <div className="p-5 space-y-4 text-xs text-center overflow-y-auto">
            <div className="w-12 h-12 rounded-full bg-[#005ba9]/10 text-[#005ba9] flex items-center justify-center mx-auto">
              <span className="material-symbols-outlined text-[24px]">sms</span>
            </div>

            <div>
              <h4 className="font-bold text-sm text-[#161b28]">Nhập mã OTP Ngân hàng {selectedBank}</h4>
              <p className="text-[11px] text-[#717973] mt-0.5">
                Mã xác thực OTP đã được gửi về số điện thoại đăng ký thẻ.
              </p>
            </div>

            <div className="bg-[#f2f3ff] p-3 rounded-xl">
              <span className="text-[10px] text-[#717973] uppercase font-bold block mb-1">
                Mã OTP Sandbox test:
              </span>
              <strong className="text-base text-[#005ba9] font-mono tracking-widest">123456</strong>
            </div>

            <div>
              <input
                type="text"
                value={otp}
                onChange={(e) => setOtp(e.target.value)}
                maxLength={6}
                placeholder="Nhập 6 số OTP"
                className="w-48 h-12 text-center text-xl font-mono font-black tracking-widest rounded-xl bg-[#f2f3ff] border border-black/10 focus:bg-white focus:ring-2 focus:ring-[#005ba9] outline-none mx-auto block text-[#161b28]"
              />
            </div>

            <button
              type="button"
              onClick={handleConfirmOtp}
              disabled={isProcessing}
              className="w-full h-11 rounded-2xl bg-[#005ba9] hover:bg-[#004785] text-white text-xs font-bold flex items-center justify-center gap-2 shadow-md active:scale-[0.99] transition-all"
            >
              {isProcessing ? (
                <>
                  <span className="material-symbols-outlined text-[16px] animate-spin">sync</span>
                  <span>Ngân hàng đang khớp lệnh...</span>
                </>
              ) : (
                <>
                  <span className="material-symbols-outlined text-[18px]">check_circle</span>
                  <span>Xác nhận thanh toán ({amount.toLocaleString('vi-VN')}₫)</span>
                </>
              )}
            </button>

            <button
              type="button"
              onClick={() => setStep('gateway')}
              className="w-full py-1 text-xs font-semibold text-[#717973] hover:text-[#161b28]"
            >
              ← Quay lại sửa thông tin thẻ
            </button>
          </div>
        )}
      </div>
    </div>
  );
};
