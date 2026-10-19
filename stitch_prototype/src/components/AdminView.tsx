import React, { useState } from 'react';
import { MissingReportItem, Order, DiscountVoucher } from '../types';

interface AdminViewProps {
  orders: Order[];
  missingReports: MissingReportItem[];
  vouchers: DiscountVoucher[];
  onUpdateOrderStatus: (orderId: string, status: Order['status']) => void;
  onUpdateReportStatus: (reportId: string, status: MissingReportItem['status']) => void;
  onToggleVoucher: (code: string) => void;
  onCreateVoucher: (voucher: DiscountVoucher) => void;
  onShowToast: (msg: string) => void;
}

export const AdminView: React.FC<AdminViewProps> = ({
  orders,
  missingReports,
  vouchers,
  onUpdateOrderStatus,
  onUpdateReportStatus,
  onToggleVoucher,
  onCreateVoucher,
  onShowToast,
}) => {
  const [activeAdminTab, setActiveAdminTab] = useState<
    'orders' | 'reports' | 'vouchers' | 'analytics'
  >('orders');

  const [newCode, setNewCode] = useState('');
  const [newTitle, setNewTitle] = useState('');
  const [newValue, setNewValue] = useState(50000);

  const totalRevenue = orders.reduce(
    (acc, o) => (o.paymentStatus === 'PAID' ? acc + o.totalAmount : acc),
    0
  );
  const pendingReportsCount = missingReports.filter((r) => r.status === 'pending').length;

  const handleAddVoucher = (e: React.FormEvent) => {
    e.preventDefault();
    if (!newCode.trim()) return;
    const v: DiscountVoucher = {
      code: newCode.toUpperCase().trim(),
      title: newTitle.trim() || `Giảm ${newValue.toLocaleString('vi-VN')}₫`,
      discountType: 'fixed',
      discountValue: Number(newValue),
      minSpend: 500000,
      isActive: true,
      expiryDate: '31/12/2026',
    };
    onCreateVoucher(v);
    setNewCode('');
    setNewTitle('');
    onShowToast(`Đã tạo mã ưu đãi: ${v.code}`);
  };

  return (
    <div className="flex flex-col w-full max-w-5xl mx-auto px-4 pb-20 pt-2">
      {/* Top Banner */}
      <div className="bg-[#134230] text-white p-4 rounded-2xl shadow-md mb-4 flex flex-col sm:flex-row items-start sm:items-center justify-between gap-3">
        <div>
          <span className="text-[10px] font-bold uppercase tracking-wider text-[#bceed3]">
            Bảng điều hành Admin Furni3D
          </span>
          <h2 className="text-lg font-bold">Hệ thống quản lý chuỗi cung ứng & bảo hành</h2>
          <p className="text-xs text-[#a1d1b8]">
            Đối soát VNPAY, điều phối shipper nội thất và xử lý cấp bù linh kiện siêu tốc.
          </p>
        </div>

        <div className="flex items-center gap-2 bg-white/10 px-3 py-1.5 rounded-xl border border-white/10 text-xs">
          <span className="w-2 h-2 rounded-full bg-[#bceed3] animate-pulse" />
          <span>VNPAY Gateway: Hoạt động 100%</span>
        </div>
      </div>

      {/* Admin Tabs */}
      <div className="flex items-center gap-2 overflow-x-auto no-scrollbar pb-3">
        <button
          onClick={() => setActiveAdminTab('orders')}
          className={`px-3.5 py-2 rounded-xl text-xs font-bold transition-all shadow-sm flex items-center gap-1.5 ${
            activeAdminTab === 'orders'
              ? 'bg-[#2d5a46] text-white'
              : 'bg-white text-[#414944] hover:bg-[#e9edff]'
          }`}
        >
          <span className="material-symbols-outlined text-[17px]">inventory_2</span>
          <span>Quản lý đơn hàng ({orders.length})</span>
        </button>

        <button
          onClick={() => setActiveAdminTab('reports')}
          className={`px-3.5 py-2 rounded-xl text-xs font-bold transition-all shadow-sm flex items-center gap-1.5 ${
            activeAdminTab === 'reports'
              ? 'bg-[#2d5a46] text-white'
              : 'bg-white text-[#414944] hover:bg-[#e9edff]'
          }`}
        >
          <span className="material-symbols-outlined text-[17px]">handyman</span>
          <span>Xử lý báo thiếu ({pendingReportsCount} chờ)</span>
        </button>

        <button
          onClick={() => setActiveAdminTab('vouchers')}
          className={`px-3.5 py-2 rounded-xl text-xs font-bold transition-all shadow-sm flex items-center gap-1.5 ${
            activeAdminTab === 'vouchers'
              ? 'bg-[#2d5a46] text-white'
              : 'bg-white text-[#414944] hover:bg-[#e9edff]'
          }`}
        >
          <span className="material-symbols-outlined text-[17px]">sell</span>
          <span>Khuyến mãi & Mã giảm</span>
        </button>

        <button
          onClick={() => setActiveAdminTab('analytics')}
          className={`px-3.5 py-2 rounded-xl text-xs font-bold transition-all shadow-sm flex items-center gap-1.5 ${
            activeAdminTab === 'analytics'
              ? 'bg-[#2d5a46] text-white'
              : 'bg-white text-[#414944] hover:bg-[#e9edff]'
          }`}
        >
          <span className="material-symbols-outlined text-[17px]">bar_chart</span>
          <span>Doanh thu & Đối soát</span>
        </button>
      </div>

      {/* TAB 1: MANAGE ORDERS */}
      {activeAdminTab === 'orders' && (
        <div className="space-y-3">
          {orders.map((order) => (
            <div
              key={order.id}
              className="bg-white rounded-xl p-4 shadow-sm border border-black/5 flex flex-col gap-3"
            >
              <div className="flex items-center justify-between">
                <div>
                  <div className="flex items-center gap-2">
                    <span className="text-sm font-bold text-[#161b28]">{order.code}</span>
                    <span className="text-[10px] px-2 py-0.5 rounded-full font-bold bg-[#e3e7fa] text-[#161b28]">
                      {order.status === 'shipping'
                        ? 'Đang vận chuyển'
                        : order.status === 'completed'
                        ? 'Đã hoàn thành'
                        : order.status === 'pending_vnpay'
                        ? 'Chờ VNPAY'
                        : 'Yêu cầu hỗ trợ'}
                    </span>
                  </div>
                  <p className="text-xs text-[#414944] mt-0.5">
                    Ngày đặt: {order.date} • Cổng VNPAY ({order.transactionId})
                  </p>
                </div>
                <div className="text-right">
                  <span className="text-sm font-bold text-[#2d5a46]">
                    {order.totalAmount.toLocaleString('vi-VN')}₫
                  </span>
                  <span className="text-[10px] block text-[#414944]">
                    {order.items.length} món
                  </span>
                </div>
              </div>

              {/* Status Action Controls */}
              <div className="flex items-center justify-end gap-2 pt-2 border-t border-black/5">
                <button
                  onClick={() => {
                    onUpdateOrderStatus(order.id, 'shipping');
                    onShowToast(`Đã cập nhật đơn ${order.code} sang Đang giao hàng`);
                  }}
                  className="px-3 py-1.5 rounded-lg bg-[#f2f3ff] hover:bg-[#e9edff] text-xs font-semibold text-[#161b28]"
                >
                  Điều phối Shipper
                </button>
                <button
                  onClick={() => {
                    onUpdateOrderStatus(order.id, 'completed');
                    onShowToast(`Đã duyệt đơn ${order.code} hoàn thành & tích điểm`);
                  }}
                  className="px-3 py-1.5 rounded-lg bg-[#2d5a46] text-white text-xs font-semibold hover:bg-[#134230]"
                >
                  Nghiệm thu Đã giao
                </button>
              </div>
            </div>
          ))}
        </div>
      )}

      {/* TAB 2: HANDLE MISSING PART REPORTS */}
      {activeAdminTab === 'reports' && (
        <div className="space-y-3">
          {missingReports.map((report) => (
            <div
              key={report.id}
              className="bg-white rounded-xl p-4 shadow-sm border border-black/5 flex flex-col gap-3"
            >
              <div className="flex items-start justify-between">
                <div>
                  <div className="flex items-center gap-2">
                    <span className="text-sm font-bold text-[#161b28]">{report.orderId}</span>
                    <span
                      className={`text-[10px] px-2 py-0.5 rounded-full font-bold ${
                        report.status === 'pending'
                          ? 'bg-[#fec38d] text-[#794f23]'
                          : report.status === 'dispatched'
                          ? 'bg-[#bceed3] text-[#002114]'
                          : 'bg-[#dee2f4] text-[#414944]'
                      }`}
                    >
                      {report.status === 'pending'
                        ? 'Chờ duyệt cấp bù'
                        : report.status === 'dispatched'
                        ? 'Đã xuất kho hỏa tốc'
                        : 'Đã hoàn tất'}
                    </span>
                  </div>
                  <p className="text-xs text-[#414944] mt-0.5">
                    Khách: {report.customerName} ({report.phone}) • {report.createdAt}
                  </p>
                  <p className="text-xs text-[#717973]">{report.address}</p>
                </div>
              </div>

              {/* Parts reported */}
              <div className="bg-[#f2f3ff] rounded-lg p-2.5 space-y-1.5">
                <span className="text-[11px] font-bold text-[#161b28] block">Danh sách linh kiện thiếu:</span>
                {report.parts.map((p, idx) => (
                  <div key={idx} className="flex items-center justify-between text-xs">
                    <span>
                      {p.name} ({p.code}) - {p.reason}
                    </span>
                    <span className="font-bold text-[#ba1a1a]">×{p.quantity}</span>
                  </div>
                ))}
              </div>

              {/* Photos */}
              <div className="flex items-center gap-2">
                {report.evidencePhotos.map((photo, i) => (
                  <div key={i} className="w-12 h-12 rounded-lg overflow-hidden border border-black/10">
                    <img src={photo.url} alt={photo.label} className="w-full h-full object-cover" />
                  </div>
                ))}
                <span className="text-[11px] text-[#414944] ml-1">{report.notes}</span>
              </div>

              {/* Actions */}
              <div className="flex items-center justify-end gap-2 pt-1 border-t border-black/5">
                <button
                  onClick={() => {
                    onUpdateReportStatus(report.id, 'dispatched');
                    onShowToast(`Đã xuất kho hỏa tốc chuyển kiện bù cho ${report.customerName}`);
                  }}
                  className="px-3 py-1.5 rounded-lg bg-[#805528] text-white text-xs font-semibold hover:bg-[#653e13]"
                >
                  Duyệt xuất kho hỏa tốc 24h
                </button>
                <button
                  onClick={() => {
                    onUpdateReportStatus(report.id, 'resolved');
                    onShowToast(`Đã đóng yêu cầu hỗ trợ #${report.id}`);
                  }}
                  className="px-3 py-1.5 rounded-lg bg-[#2d5a46] text-white text-xs font-semibold hover:bg-[#134230]"
                >
                  Xác nhận khách đã nhận
                </button>
              </div>
            </div>
          ))}
        </div>
      )}

      {/* TAB 3: MANAGE DISCOUNTS & PROMOTIONS */}
      {activeAdminTab === 'vouchers' && (
        <div className="space-y-4">
          {/* Create voucher form */}
          <form
            onSubmit={handleAddVoucher}
            className="bg-white p-4 rounded-xl shadow-sm border border-black/5 flex flex-col gap-3"
          >
            <h3 className="text-sm font-bold text-[#161b28]">Tạo mã khuyến mãi / Voucher mới</h3>
            <div className="grid grid-cols-1 sm:grid-cols-3 gap-2">
              <input
                type="text"
                value={newCode}
                onChange={(e) => setNewCode(e.target.value)}
                placeholder="Mã voucher (VD: SPRING2026)"
                className="h-10 px-3 rounded-lg bg-[#f2f3ff] text-xs text-[#161b28] focus:outline-none focus:ring-1 focus:ring-[#2d5a46]"
                required
              />
              <input
                type="text"
                value={newTitle}
                onChange={(e) => setNewTitle(e.target.value)}
                placeholder="Tiêu đề hiển thị"
                className="h-10 px-3 rounded-lg bg-[#f2f3ff] text-xs text-[#161b28] focus:outline-none focus:ring-1 focus:ring-[#2d5a46]"
              />
              <input
                type="number"
                value={newValue}
                onChange={(e) => setNewValue(Number(e.target.value))}
                placeholder="Giá trị giảm (VNĐ)"
                className="h-10 px-3 rounded-lg bg-[#f2f3ff] text-xs text-[#161b28] focus:outline-none focus:ring-1 focus:ring-[#2d5a46]"
                required
              />
            </div>
            <button
              type="submit"
              className="h-10 px-4 rounded-lg bg-[#2d5a46] text-white text-xs font-bold self-end"
            >
              + Phát hành Voucher
            </button>
          </form>

          {/* Existing Vouchers */}
          <div className="grid grid-cols-1 sm:grid-cols-2 gap-3">
            {vouchers.map((voucher) => (
              <div
                key={voucher.code}
                className="bg-white p-4 rounded-xl shadow-sm border border-black/5 flex items-center justify-between"
              >
                <div>
                  <div className="flex items-center gap-2">
                    <span className="text-sm font-bold text-[#2d5a46]">{voucher.code}</span>
                    <span
                      className={`text-[9px] px-2 py-0.5 rounded-full font-bold ${
                        voucher.isActive ? 'bg-[#bceed3] text-[#002114]' : 'bg-[#dee2f4] text-[#414944]'
                      }`}
                    >
                      {voucher.isActive ? 'ĐANG ÁP DỤNG' : 'TẠM TẮT'}
                    </span>
                  </div>
                  <p className="text-xs text-[#414944] mt-0.5">{voucher.title}</p>
                  <p className="text-[10px] text-[#717973]">
                    Hết hạn: {voucher.expiryDate} • Đơn từ {voucher.minSpend.toLocaleString('vi-VN')}₫
                  </p>
                </div>
                <button
                  onClick={() => {
                    onToggleVoucher(voucher.code);
                    onShowToast(`Đã ${voucher.isActive ? 'tạm tắt' : 'bật lại'} mã ${voucher.code}`);
                  }}
                  className="px-3 py-1.5 rounded-lg text-xs font-semibold bg-[#f2f3ff] hover:bg-[#dee2f4] text-[#161b28]"
                >
                  {voucher.isActive ? 'Tắt' : 'Bật'}
                </button>
              </div>
            ))}
          </div>
        </div>
      )}

      {/* TAB 4: REVENUE & ANALYTICS */}
      {activeAdminTab === 'analytics' && (
        <div className="space-y-4">
          <div className="grid grid-cols-2 sm:grid-cols-4 gap-3">
            <div className="bg-white p-4 rounded-xl shadow-sm border border-black/5">
              <span className="text-xs text-[#414944] block">Tổng doanh thu VNPAY</span>
              <span className="text-lg font-bold text-[#2d5a46] mt-1 block">
                {totalRevenue.toLocaleString('vi-VN')}₫
              </span>
              <span className="text-[10px] text-[#805528] font-bold">100% đối soát thành công</span>
            </div>

            <div className="bg-white p-4 rounded-xl shadow-sm border border-black/5">
              <span className="text-xs text-[#414944] block">Số đơn hàng</span>
              <span className="text-lg font-bold text-[#161b28] mt-1 block">{orders.length}</span>
              <span className="text-[10px] text-[#2d5a46] font-bold">+2 đơn hôm nay</span>
            </div>

            <div className="bg-white p-4 rounded-xl shadow-sm border border-black/5">
              <span className="text-xs text-[#414944] block">Tỷ lệ bù phụ kiện</span>
              <span className="text-lg font-bold text-[#161b28] mt-1 block">98.4%</span>
              <span className="text-[10px] text-[#2d5a46] font-bold">Giao dưới 24h</span>
            </div>

            <div className="bg-white p-4 rounded-xl shadow-sm border border-black/5">
              <span className="text-xs text-[#414944] block">Đánh giá 5 sao</span>
              <span className="text-lg font-bold text-[#805528] mt-1 block">4.9 / 5.0</span>
              <span className="text-[10px] text-[#414944] font-medium">365 lượt review</span>
            </div>
          </div>
        </div>
      )}
    </div>
  );
};
