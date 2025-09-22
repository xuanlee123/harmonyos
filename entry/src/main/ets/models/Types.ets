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