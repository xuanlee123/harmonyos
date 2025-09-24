// 用户信息
export class User {
  id: string = '';
  username: string = '';
  nickname: string = '';
  avatar: string = '';
  gender: string = '';
  level: number = 1;
  couponCount: number = 0;
  coinCount: number = 0;
  phone: string = '';
  location: string = '';
}

// ===== 数据库对齐的 DTO（字段命名与后端一致，snake_case 等） =====

// t_user
export class UserDto {
  id: number = 0;
  username: string = '';
  password: string = '';
  nickname: string = '';
  avatar: string = '';
  email: string = '';
  phone: string = '';
  gender: number = 0; // 0-未知,1-男,2-女
  birthday: string = ''; // DATE → ISO 字符串
  role: string = 'USER';
  status: number = 1;
  created_at: string = '';
  updated_at: string = '';
}

// 消息
export class Message {
  id: string = '';
  type: string = '';
  title: string = '';
  content: string = '';
  time: string = '';
  badgeCount: number = 0;
  isOfficial: boolean = false;
  senderId: string = '';
  senderAvatar: string = '';
}

// 会话（将多条消息聚合为一个最近会话项）
export class Conversation {
  id: string = '';
  peerId: string = '';
  peerAvatar: string = '';
  name: string = '';
  lastContent: string = '';
  lastTime: string = '';
  unread: number = 0;
  isOfficial: boolean = false;
}

// 景点信息
export class ScenicSpot {
  id: string = '';
  name: string = '';
  level: string = '';
  rating: number = 0;
  reviews: number = 0;
  distance: number = 0;
  price: number = 0;
  isFree: boolean = false;
  heatLevel: number = 0;
  location: string = '';
  description: string = '';
  category: string = '';
  images: string[] = [];
}

// t_attraction
export class AttractionDto {
  id: number = 0;
  name: string = '';
  city: string = '';
  address: string = '';
  category: string = '';
  rating: number = 0;
  review_count: number = 0;
  description: string = '';
  images: string = ''; // 数据库存放 JSON 数组字符串
}

// 推荐内容
export class RecommendItem {
  id: string = '';
  type: string = '';
  title: string = '';
  coverImage: string = '';
  author: User = new User();
  views: number = 0;
  likes: number = 0;
  comments: number = 0;
  createTime: string = '';
  isVideo: boolean = false;
  videoUrl: string = '';
}

// 功能项
export class FeatureItem {
  id: string = '';
  icon: string = '';
  name: string = '';
  color: string = '';
  badge: string = '';
  route: string = '';
}

// 酒店订单
export class HotelOrder {
  id: string = '';
  status: string = '';
  hotelName: string = '';
  address: string = '';
  checkInDate: string = '';
  checkOutDate: string = '';
  nights: number = 0;
  rooms: number = 0;
  roomType: string = '';
  price: number = 0;
  orderTime: string = '';
}

// t_ticket_type
export class TicketTypeDto {
  id: number = 0;
  attraction_id: number = 0;
  name: string = '';
  description: string = '';
  price: number = 0; // 分
  original_price: number = 0;
  stock: number = 0;
  valid_days: number = 1;
  min_advance_hours: number = 0;
  refund_rule: string = '';
  status: number = 1;
}

// t_ticket_booking
export class TicketBookingDto {
  id: number = 0;
  order_no: string = '';
  user_id: number = 0;
  attraction_id: number = 0;
  ticket_type_id: number = 0;
  quantity: number = 1;
  visit_date: string = '';
  visitor_name: string = '';
  visitor_phone: string = '';
  visitor_id_card: string = '';
  total_amount: number = 0;
  status: number = 0;
  payment_time: string = '';
  cancel_time: string = '';
  created_at: string = '';
  updated_at: string = '';
}

// t_hotel_booking
export class HotelBookingDto {
  id: number = 0;
  order_no: string = '';
  user_id: number = 0;
  hotel_id: number = 0;
  room_id: number = 0;
  checkin_date: string = '';
  checkout_date: string = '';
  nights: number = 0;
  guest_name: string = '';
  guest_phone: string = '';
  total_amount: number = 0;
  status: number = 0; // 0-待支付,1-已支付,2-已取消,3-已退款
  payment_time: string = '';
  cancel_time: string = '';
  created_at: string = '';
  updated_at: string = '';
}

// 反馈信息
export class Feedback {
  id: string = '';
  type: string = '';
  content: string = '';
  phone: string = '';
  images: string[] = [];
  createTime: string = '';
  status: string = '';
}

// 游记/发布内容
export class TravelPost {
  id: string = '';
  title: string = '';
  content: string = '';
  images: string[] = [];
  location: string = '';
  authorId: string = '';
  createTime: string = '';
  likes: number = 0;
  comments: number = 0;
  views: number = 0;
}

// 视频内容
export class VideoItem {
  id: string = '';
  title: string = '';
  coverImage: string = '';
  videoUrl: string = '';
  author: User = new User();
  views: number = 0;
  comments: number = 0;
  likes: number = 0;
  duration: string = '';
  createTime: string = '';
}