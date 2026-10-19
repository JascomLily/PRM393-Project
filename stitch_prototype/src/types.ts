export interface Product {
  id: string;
  name: string;
  subtitle: string;
  material: string;
  price: number;
  originalPrice?: number;
  rating: number;
  reviewCount: number;
  image: string;
  badge?: string;
  badgeType?: '3d' | 'time' | 'layers' | 'easy';
  category: 'desk' | 'chair' | 'shelf' | 'lamp' | 'parts';
  assemblyTimeMinutes: number;
  description: string;
  is3dReady: boolean;
  modelCode: string;
}

export interface AssemblyPart {
  id: string;
  code: string;
  name: string;
  quantity: number;
  image: string;
  isIncluded: boolean;
  statusText?: string;
}

export interface AssemblyStep {
  stepNumber: number;
  totalSteps: number;
  title: string;
  description: string;
  tip: string;
  requiredParts: {
    code: string;
    name: string;
    count: number;
    image: string;
    note?: string;
  }[];
  explodedProgress: number; // 0 to 1 for 3D animation
}

export interface MissingReportItem {
  id: string;
  orderId: string;
  productName: string;
  productModel: string;
  customerName: string;
  phone: string;
  address: string;
  createdAt: string;
  status: 'pending' | 'dispatched' | 'resolved' | 'rejected';
  parts: {
    code: string;
    name: string;
    quantity: number;
    reason: string;
    image: string;
  }[];
  evidencePhotos: {
    label: string;
    code: string;
    url: string;
  }[];
  notes: string;
}

export interface OrderItem {
  productId: string;
  name: string;
  price: number;
  quantity: number;
  image: string;
  packageInfo: string;
  variant?: string;
}

export interface OrderTimelineStep {
  id: number;
  title: string;
  time: string;
  description: string;
  status: 'completed' | 'current' | 'upcoming';
  actor?: string;
}

export interface Order {
  id: string;
  code: string;
  date: string;
  estimatedDelivery?: string;
  items: OrderItem[];
  totalAmount: number;
  paymentMethod: 'VNPAY_QR' | 'COD' | 'BANK_TRANSFER';
  paymentStatus: 'PAID' | 'PENDING' | 'REFUNDED';
  transactionId?: string;
  status: 'shipping' | 'completed' | 'pending_vnpay' | 'support_needed';
  driver?: {
    name: string;
    licensePlate: string;
    phone: string;
    distanceKm: number;
    avatar: string;
  };
  timeline: OrderTimelineStep[];
  review?: {
    stars: number;
    tags: string[];
    comment: string;
    rewardEarned: number;
    createdAt: string;
    isModerated?: boolean;
    status: 'approved' | 'pending';
  };
}

export interface SparePartItem {
  id: string;
  code: string;
  name: string;
  price: number;
  spec: string;
  image: string;
  inStock: boolean;
  category: string;
}

export interface DiscountVoucher {
  code: string;
  title: string;
  discountType: 'percentage' | 'fixed';
  discountValue: number;
  minSpend: number;
  isActive: boolean;
  expiryDate: string;
}

export interface UserProfile {
  name: string;
  email: string;
  phone: string;
  avatar: string;
  furniCoins: number;
  savedAddress: string;
  role: 'customer' | 'admin';
}
