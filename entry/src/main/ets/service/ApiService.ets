import http from '@ohos.net.http';
import { User, Message, ScenicSpot, RecommendItem, FeatureItem, HotelOrder, Feedback, TravelPost, VideoItem } from '../models/Types';

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

// 后端 Attraction DTO（依据数据库与控制器推断的常见字段）
interface AttractionDto {
  id: number;
  name: string;
  city?: string;
  address?: string;
  category?: string;
  rating?: number;
  reviewCount?: number; // 对应 review_count
  review_count?: number; // 兼容不同命名
  description?: string;
  images?: string | string[]; // 可能为 JSON 数组或数组
}

// 门票相关 DTO（根据后端 /api/ticket-types）
interface TicketTypeDto {
  id: number;
  attractionId: number;
  name: string;
  description?: string;
  price: number; // 分
  originalPrice?: number;
  stock: number;
  validDays?: number;
}

class ApiService {
  // 配置后端基础地址（仅修改这里即可切换环境）
  private baseUrl: string = 'http://localhost:8081';
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

  // 用户相关接口
  // 登录：POST /api/users/login  请求体 { username, password }
  // 响应: { token, tokenType, userId, username, nickname, role }
  async login(username: string, password: string): Promise<LoginResponseDto> {
    // 直接使用通用 request 以保持错误处理一致
    // 后端未包裹 code/message/data 的统一结构，这里解析原始返回
    try {
      const options: http.HttpRequestOptions = {
        method: http.RequestMethod.POST,
        header: { 'Content-Type': 'application/json' },
        extraData: JSON.stringify({ username, password })
      };
      const resp = await this.httpRequest.request(`${this.baseUrl}/api/users/login`, options);
      if (resp.responseCode === 200) {
        return JSON.parse(resp.result as string) as LoginResponseDto;
      }
      throw new Error(`HTTP Error: ${resp.responseCode}`);
    } catch (e) {
      console.error('Login API Error: ' + JSON.stringify(e));
      throw new Error('登录失败');
    }
  }

  // 注册：POST /api/users  请求体 { username, password }
  // 响应: 创建的用户对象（不需要此处详细类型，前端仅需成功与否）
  async register(username: string, password: string): Promise<boolean> {
    try {
      const options: http.HttpRequestOptions = {
        method: http.RequestMethod.POST,
        header: { 'Content-Type': 'application/json' },
        extraData: JSON.stringify({ username, password })
      };
      const resp = await this.httpRequest.request(`${this.baseUrl}/api/users`, options);
      if (resp.responseCode === 201 || resp.responseCode === 200) {
        return true;
      }
      // 尝试读取错误消息
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

  // 消息相关接口
  async getMessageList(page: number = 1, pageSize: number = 20): Promise<Message[]> {
    return await this.request<Message[]>(`/messages?page=${page}&pageSize=${pageSize}`, http.RequestMethod.GET);
  }

  async readMessage(messageId: string): Promise<void> {
    return await this.request<void>(`/messages/${messageId}/read`, http.RequestMethod.PUT);
  }

  // 景点相关接口
  // 后端真实接口为 /api/attractions 与 /api/attractions/{id}
  // 定义后端 Attraction 结构并在前端进行映射，保持前端 ScenicSpot 类型不变
  private async httpGet<T>(path: string): Promise<T> {
    const options: http.HttpRequestOptions = { method: http.RequestMethod.GET };
    const resp = await this.httpRequest.request(`${this.baseUrl}${path}`, options);
    if (resp.responseCode === 200) {
      return JSON.parse(resp.result as string) as T;
    }
    throw new Error(`HTTP Error: ${resp.responseCode}`);
  }

  private mapAttractionToScenicSpot(a: AttractionDto): ScenicSpot {
    const images: string[] = Array.isArray(a.images)
      ? a.images as string[]
      : (typeof a.images === 'string' && a.images ? this.safeParseImages(a.images) : []);
    const reviews = (a.reviewCount !== undefined ? a.reviewCount : (a.review_count !== undefined ? a.review_count : 0));
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


  private safeParseImages(raw: string): string[] {
    try {
      const parsed: string[] = JSON.parse(raw) as string[];
      if (Array.isArray(parsed)) {
        // 严格校验元素均为字符串，避免隐式 any
        const valid: boolean = parsed.every((item: string) => typeof item === 'string');
        return valid ? parsed : [];
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  async getScenicSpots(category?: string, keyword?: string, page: number = 1): Promise<ScenicSpot[]> {
    const list = await this.httpGet<AttractionDto[]>(`/api/attractions`);
    let mapped = list.map((a) => this.mapAttractionToScenicSpot(a));
    if (category && category !== 'all') {
      mapped = mapped.filter(s => (s.category || '').toLowerCase().includes(category.toLowerCase()));
    }
    if (keyword && keyword.trim().length > 0) {
      const k = keyword.trim().toLowerCase();
      mapped = mapped.filter(s => s.name.toLowerCase().includes(k) || (s.location || '').toLowerCase().includes(k));
    }
    // 简单分页（前端分页），page 从 1 开始
    const pageSize = 50;
    const start = (page - 1) * pageSize;
    return mapped.slice(start, start + pageSize);
  }

  async getScenicSpotDetail(id: string): Promise<ScenicSpot> {
    const a = await this.httpGet<AttractionDto>(`/api/attractions/${id}`);
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

  // 酒店订单接口
  async getHotelOrders(status?: string, page: number = 1): Promise<HotelOrder[]> {
    let url = `/hotel/orders?page=${page}`;
    if (status && status !== '全部') {
      const statusMap: Record<string, string> = {
        '全部': '',
        '待付款': 'pending',
        '未使用': 'unused',
        '已取消': 'cancelled'
      };
      url += `&status=${statusMap[status]}`;
    }
    return await this.request<HotelOrder[]>(url, http.RequestMethod.GET);
  }

  async cancelHotelOrder(orderId: string): Promise<void> {
    return await this.request<void>(`/hotel/orders/${orderId}/cancel`, http.RequestMethod.PUT);
  }

  async payHotelOrder(orderId: string): Promise<void> {
    return await this.request<void>(`/hotel/orders/${orderId}/pay`, http.RequestMethod.PUT);
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
    return await this.httpGet<TicketTypeDto[]>(`/api/ticket-types/attraction/${attractionId}`);
  }

  async getAvailableTicketTypesByAttraction(attractionId: string): Promise<TicketTypeDto[]> {
    return await this.httpGet<TicketTypeDto[]>(`/api/ticket-types/attraction/${attractionId}/available`);
  }
}

export default new ApiService();