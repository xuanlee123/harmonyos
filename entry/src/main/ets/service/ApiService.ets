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
  async getScenicSpots(category?: string, keyword?: string, page: number = 1): Promise<ScenicSpot[]> {
    let url = `/scenic/spots?page=${page}`;
    if (category && category !== 'all') {
      url += `&category=${category}`;
    }
    if (keyword) {
      url += `&keyword=${encodeURIComponent(keyword)}`;
    }
    return await this.request<ScenicSpot[]>(url, http.RequestMethod.GET);
  }

  async getScenicSpotDetail(id: string): Promise<ScenicSpot> {
    return await this.request<ScenicSpot>(`/scenic/spots/${id}`, http.RequestMethod.GET);
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
}

export default new ApiService();