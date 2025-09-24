import http from '@ohos.net.http';
import { User, Message, ScenicSpot, RecommendItem, FeatureItem, HotelOrder, Feedback, TravelPost, VideoItem, AttractionDto, TicketTypeDto, HotelBookingDto } from '../models/Types';

// Define interface for API response
interface ApiResponse<T> {
  code: number;
  message: string;
  data: T;
}

// Define interface for image upload data
interface ImageUploadData {
  image: ArrayBuffer;
}

// Define interface for createTravelPost response
interface PostResponse {
  id: string;
}

// Define interface for uploadImage response
interface UploadResponse {
  url: string;
}

// 后端登录返回结构
export interface LoginResponseDto {
  token: string;
  tokenType: string;
  userId: number;
  username: string;
  nickname: string;
  role: string;
}

// 后端通用错误返回（当非 2xx 时可能包含 message）
interface ErrorResponseDto {
  message?: string;
}

// 聊天相关 DTO（需在类外声明以符合 ArkTS 语法）
interface ChatMessageDto {
  id: number | string;
  senderId: number | string;
  receiverId?: number | string;
  content: string;
  contentType?: string;
  createdAt?: string;
  time?: string;
  read?: boolean;
  senderAvatar?: string;
  title?: string;
}

interface SendChatPayload {
  senderId: number;
  receiverId: number;
  content: string;
  contentType: string;
}

class ApiService {
  // 配置后端基础地址（仅修改这里即可切换环境）
  private baseUrl: string = 'http://localhost:8081/api';
  private httpRequest: http.HttpRequest = http.createHttp();

  // 通用请求方法
  private async request<T>(url: string, method: http.RequestMethod, data?: object): Promise<T> {
    try {
      let options: http.HttpRequestOptions = {
        method: method,
        header: {
          'Content-Type': 'application/json',
        },
        extraData: data ? JSON.stringify(data) : ''
      };

      let response = await this.httpRequest.request(`${this.baseUrl}${url}`, options);

      if (response.responseCode === 200) {
        let result = JSON.parse(response.result as string) as ApiResponse<T>;
        if (result.code === 0) {
          return result.data;
        } else {
          throw new Error(result.message);
        }
      } else {
        throw new Error(`HTTP Error: ${response.responseCode}`);
      }
    } catch (error) {
      console.error('API Request Error: ' + JSON.stringify(error));
      throw new Error('API request failed');
    }
  }

  // GET 辅助
  private async httpGet<T>(path: string): Promise<T> {
    const options: http.HttpRequestOptions = { method: http.RequestMethod.GET };
    const resp = await this.httpRequest.request(`${this.baseUrl}${path}`, options);
    if (resp.responseCode === 200) {
      return JSON.parse(resp.result as string) as T;
    }
    throw new Error(`HTTP Error: ${resp.responseCode}`);
  }

  // 映射：AttractionDto -> ScenicSpot
  private mapAttractionToScenicSpot(a: AttractionDto): ScenicSpot {
    const images: string[] = a.images ? this.safeParseImages(a.images) : [];
    const reviews = (a.review_count !== undefined ? a.review_count : 0);
    const location = a.city ? a.city : (a.address ? a.address : '');
    const spot: ScenicSpot = new ScenicSpot();
    spot.id = String(a.id);
    spot.name = a.name || '';
    spot.level = a.category || '';
    spot.rating = a.rating ?? 0;
    spot.reviews = reviews;
    spot.distance = 0;
    spot.price = 0;
    spot.isFree = false;
    spot.heatLevel = 0;
    spot.location = location;
    spot.description = a.description || '';
    spot.category = a.category || '';
    spot.images = images.length > 0 ? images : [];
    return spot;
  }

  // 映射：HotelBookingDto -> HotelOrder（UI）
  private mapHotelBookingToOrder(b: HotelBookingDto): HotelOrder {
    const order = new HotelOrder();
    order.id = String(b.id);
    // 状态码到 UI 文本的映射由页面完成，这里保留 status code 语义
    order.status = (b.status === 0 ? 'pending' : (b.status === 1 ? 'unused' : (b.status === 2 ? 'cancelled' : 'used')));
    order.hotelName = `酒店#${b.hotel_id}`;
    order.address = '';
    order.checkInDate = b.checkin_date;
    order.checkOutDate = b.checkout_date;
    order.nights = b.nights;
    order.rooms = 1;
    order.roomType = '';
    order.price = Math.round(b.total_amount / 100);
    order.orderTime = b.created_at;
    return order;
  }

  private safeParseImages(raw: string): string[] {
    try {
      const parsed: string[] = JSON.parse(raw) as string[];
      if (Array.isArray(parsed)) {
        const valid: boolean = parsed.every((item: string) => typeof item === 'string');
        return valid ? parsed : [];
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  // 用户相关接口
  async login(username: string, password: string): Promise<LoginResponseDto> {
    try {
      const options: http.HttpRequestOptions = {
        method: http.RequestMethod.POST,
        header: { 'Content-Type': 'application/json' },
        extraData: JSON.stringify({ username, password })
      };
      const resp = await this.httpRequest.request(`${this.baseUrl}/users/login`, options);
      if (resp.responseCode === 200) {
        return JSON.parse(resp.result as string) as LoginResponseDto;
      }
      throw new Error(`HTTP Error: ${resp.responseCode}`);
    } catch (e) {
      console.error('Login API Error: ' + JSON.stringify(e));
      throw new Error('登录失败');
    }
  }

  async register(username: string, password: string): Promise<boolean> {
    try {
      const options: http.HttpRequestOptions = {
        method: http.RequestMethod.POST,
        header: { 'Content-Type': 'application/json' },
        extraData: JSON.stringify({ username, password })
      };
      const resp = await this.httpRequest.request(`${this.baseUrl}/users`, options);
      if (resp.responseCode === 201 || resp.responseCode === 200) {
        return true;
      }
      try {
        const body = JSON.parse(resp.result as string) as ErrorResponseDto;
        if (body && body.message) {
          throw new Error(body.message);
        }
      } catch (_e) {}
      throw new Error(`HTTP Error: ${resp.responseCode}`);
    } catch (e) {
      console.error('Register API Error: ' + JSON.stringify(e));
      throw new Error('注册失败');
    }
  }

  async getUserInfo(): Promise<User> {
    return await this.request<User>('/user/info', http.RequestMethod.GET);
  }

  async updateUserInfo(userInfo: User): Promise<void> {
    return await this.request<void>('/user/info', http.RequestMethod.PUT, userInfo);
  }

  // 消息相关接口（对齐后端 /api/chats）
  // 兼容方法：返回指定接收者的未读消息列表，用于消息中心聚合
  async getMessageList(page: number = 1, pageSize: number = 20, receiverId?: string): Promise<Message[]> {
    // 若未提供 receiverId，将尝试读取全部未读（需要上层传入当前用户ID）
    if (!receiverId) {
      // 返回空列表，避免误请求
      return [];
    }
    const raw = await this.httpGet<ChatMessageDto[]>(`/chats/unread?receiverId=${encodeURIComponent(receiverId)}`);
    return Array.isArray(raw) ? raw.map((r) => this.mapChatDtoToMessage(r)) : [];
  }

  async readMessage(messageId: string): Promise<void> {
    return await this.request<void>(`/chats/${messageId}/read`, http.RequestMethod.PUT);
  }

  // 景点相关接口（后端 /api/attractions）
  async getScenicSpots(category?: string, keyword?: string, page: number = 1): Promise<ScenicSpot[]> {
    const list = await this.httpGet<AttractionDto[]>(`/attractions`);
    let mapped = list.map((a) => this.mapAttractionToScenicSpot(a));
    if (category && category !== 'all') {
      mapped = mapped.filter(s => (s.category || '').toLowerCase().includes(category.toLowerCase()));
    }
    if (keyword && keyword.trim().length > 0) {
      const k = keyword.trim().toLowerCase();
      mapped = mapped.filter(s => s.name.toLowerCase().includes(k) || (s.location || '').toLowerCase().includes(k));
    }
    const pageSize = 50;
    const start = (page - 1) * pageSize;
    return mapped.slice(start, start + pageSize);
  }

  async getScenicSpotDetail(id: string): Promise<ScenicSpot> {
    const a = await this.httpGet<AttractionDto>(`/attractions/${id}`);
    return this.mapAttractionToScenicSpot(a);
  }

  // 推荐内容接口
  async getRecommendations(location: string = '北京市', type?: string): Promise<RecommendItem[]> {
    let url = `/recommendations?location=${encodeURIComponent(location)}`;
    if (type) {
      url += `&type=${type}`;
    }
    return await this.request<RecommendItem[]>(url, http.RequestMethod.GET);
  }

  // 热门搜索标签
  async getHotTags(): Promise<string[]> {
    return await this.request<string[]>('/search/hot-tags', http.RequestMethod.GET);
  }

  // 功能导航数据
  async getFeatures(): Promise<FeatureItem[]> {
    return await this.request<FeatureItem[]>('/features', http.RequestMethod.GET);
  }

  // 酒店订单（后端 t_hotel_booking）
  async getHotelOrders(status?: string, page: number = 1): Promise<HotelOrder[]> {
    let url = `/hotel-bookings?page=${page}`;
    const list = await this.httpGet<HotelBookingDto[]>(url);
    return list.map(b => this.mapHotelBookingToOrder(b));
  }

  async cancelHotelOrder(orderId: string): Promise<void> {
    return await this.request<void>(`/hotel-bookings/${orderId}/cancel`, http.RequestMethod.PUT);
  }

  async payHotelOrder(orderId: string): Promise<void> {
    return await this.request<void>(`/hotel-bookings/${orderId}/pay`, http.RequestMethod.PUT);
  }

  // 反馈接口
  async submitFeedback(feedback: Feedback): Promise<void> {
    return await this.request<void>('/feedback', http.RequestMethod.POST, feedback);
  }

  // 游记发布接口
  async createTravelPost(post: TravelPost): Promise<PostResponse> {
    return await this.request<PostResponse>('/travel/posts', http.RequestMethod.POST, post);
  }

  // 视频内容接口
  async getVideos(tab: string, page: number = 1): Promise<VideoItem[]> {
    return await this.request<VideoItem[]>(`/videos?tab=${tab}&page=${page}`, http.RequestMethod.GET);
  }

  // 上传图片接口
  async uploadImage(imageData: ArrayBuffer): Promise<UploadResponse> {
    const uploadData: ImageUploadData = { image: imageData };
    return await this.request<UploadResponse>('/upload/image', http.RequestMethod.POST, uploadData);
  }

  // 门票相关接口（根据后端 /api/ticket-types 与 /api/ticket-bookings）
  async getTicketTypesByAttraction(attractionId: string): Promise<TicketTypeDto[]> {
    return await this.httpGet<TicketTypeDto[]>(`/ticket-types/attraction/${attractionId}`);
  }

  async getAvailableTicketTypesByAttraction(attractionId: string): Promise<TicketTypeDto[]> {
    return await this.httpGet<TicketTypeDto[]>(`/ticket-types/attraction/${attractionId}/available`);
  }

  // 聊天相关接口（后端 /api/chats）
  private mapChatDtoToMessage(dto: ChatMessageDto): Message {
    const m: Message = new Message();
    m.id = String(dto.id ?? '');
    m.type = 'chat';
    m.title = dto.title ?? '';
    m.content = dto.content ?? '';
    m.time = dto.createdAt ?? dto.time ?? '';
    m.badgeCount = dto.read ? 0 : 1;
    m.isOfficial = false;
    m.senderId = String(dto.senderId ?? '');
    m.senderAvatar = dto.senderAvatar ?? '';
    return m;
  }

  async getConversation(user1: string, user2: string): Promise<Message[]> {
    const raw = await this.httpGet<ChatMessageDto[]>(`/chats/conversation?user1=${encodeURIComponent(user1)}&user2=${encodeURIComponent(user2)}`);
    if (Array.isArray(raw)) {
      return raw.map((r) => this.mapChatDtoToMessage(r));
    }
    return [];
  }

  async getUnreadByReceiver(receiverId: string): Promise<number> {
    const raw = await this.httpGet<ChatMessageDto[]>(`/chats/unread?receiverId=${encodeURIComponent(receiverId)}`);
    return Array.isArray(raw) ? raw.length : 0;
  }

  async sendChat(senderId: string, receiverId: string, content: string): Promise<Message> {
    const payload: SendChatPayload = { senderId: Number(senderId), receiverId: Number(receiverId), content, contentType: 'TEXT' };
    const resp = await this.request<ChatMessageDto>(`/chats`, http.RequestMethod.POST, payload);
    return this.mapChatDtoToMessage(resp);
  }

  async markChatRead(messageId: string): Promise<void> {
    return await this.request<void>(`/chats/${messageId}/read`, http.RequestMethod.PUT);
  }
}

export default new ApiService();