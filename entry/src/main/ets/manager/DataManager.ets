import ApiService from '../service/ApiService';
import { User, Message, ScenicSpot, RecommendItem, FeatureItem, HotelOrder, Feedback, TravelPost, VideoItem } from '../models/Types';

class DataManager {
  // 用户数据
  userInfo: User = new User();

  // 数据数组
  messages: Message[] = [];
  scenicSpots: ScenicSpot[] = [];
  recommendations: RecommendItem[] = [];
  hotelOrders: HotelOrder[] = [];
  hotTags: string[] = [];
  features: FeatureItem[] = [];
  videos: VideoItem[] = [];

  // 加载状态
  isLoading: boolean = false;

  // 初始化数据
  async initData(): Promise<void> {
    this.isLoading = true;
    try {
      await Promise.all([
        this.loadUserInfo(),
        this.loadMessages(),
        this.loadHotTags(),
        this.loadFeatures(),
        this.loadRecommendations(),
      ]);
    } catch (error) {
      console.error('初始化数据失败: ' + JSON.stringify(error));
      throw new Error('初始化数据失败');
    } finally {
      this.isLoading = false;
    }
  }

  // 加载用户信息
  async loadUserInfo(): Promise<void> {
    try {
      this.userInfo = await ApiService.getUserInfo();
    } catch (error) {
      console.error('加载用户信息失败: ' + JSON.stringify(error));
      // 设置默认用户数据
      this.userInfo = {
        id: '1',
        username: 'user1',
        nickname: '晚风心里吹',
        avatar: 'app.media.banner_hot_spring',
        gender: 'male',
        level: 1,
        couponCount: 3,
        coinCount: 30000,
        phone: '',
        location: '北京市',
      };
    }
  }

  // 更新用户信息
  async updateUserInfo(userInfo: Partial<User>): Promise<void> {
    try {
      // 手动合并 userInfo 属性到新的 User 对象
      const updatedUser: User = new User();
      updatedUser.id = userInfo.id !== undefined ? userInfo.id : this.userInfo.id;
      updatedUser.username = userInfo.username !== undefined ? userInfo.username : this.userInfo.username;
      updatedUser.nickname = userInfo.nickname !== undefined ? userInfo.nickname : this.userInfo.nickname;
      updatedUser.avatar = userInfo.avatar !== undefined ? userInfo.avatar : this.userInfo.avatar;
      updatedUser.gender = userInfo.gender !== undefined ? userInfo.gender : this.userInfo.gender;
      updatedUser.level = userInfo.level !== undefined ? userInfo.level : this.userInfo.level;
      updatedUser.couponCount = userInfo.couponCount !== undefined ? userInfo.couponCount : this.userInfo.couponCount;
      updatedUser.coinCount = userInfo.coinCount !== undefined ? userInfo.coinCount : this.userInfo.coinCount;
      updatedUser.phone = userInfo.phone !== undefined ? userInfo.phone : this.userInfo.phone;
      updatedUser.location = userInfo.location !== undefined ? userInfo.location : this.userInfo.location;

      await ApiService.updateUserInfo(updatedUser);
      this.userInfo = updatedUser;
    } catch (error) {
      console.error('更新用户信息失败: ' + JSON.stringify(error));
      throw new Error('更新用户信息失败');
    }
  }

  // 加载消息列表
  async loadMessages(page: number = 1, pageSize: number = 20): Promise<void> {
    try {
      this.messages = await ApiService.getMessageList(page, pageSize);
    } catch (error) {
      console.error('加载消息列表失败: ' + JSON.stringify(error));
      // 设置默认消息数据
      this.messages = [
        {
          id: '1',
          type: 'system',
          title: '系统通知',
          content: '欢迎体验我们的新功能！',
          time: new Date().toISOString(),
          badgeCount: 1,
          isOfficial: true,
          senderId: '',
          senderAvatar: '',
        },
      ];
    }
  }

  // 标记消息为已读
  async readMessage(messageId: string): Promise<void> {
    try {
      await ApiService.readMessage(messageId);
      const message = this.messages.find((msg) => msg.id === messageId);
      if (message) {
        message.badgeCount = 0;
      }
    } catch (error) {
      console.error('标记消息为已读失败: ' + JSON.stringify(error));
      throw new Error('标记消息为已读失败');
    }
  }

  // 加载景点列表
  async loadScenicSpots(category?: string, keyword?: string, page: number = 1): Promise<void> {
    try {
      this.scenicSpots = await ApiService.getScenicSpots(category, keyword, page);
    } catch (error) {
      console.error('加载景点列表失败: ' + JSON.stringify(error));
      // 设置默认景点数据
      this.scenicSpots = [
        {
          id: '1',
          name: '故宫博物院',
          level: '5A',
          rating: 4.8,
          reviews: 1200,
          distance: 5,
          price: 60,
          isFree: false,
          heatLevel: 5,
          location: '北京市',
          description: '世界文化遗产，古代皇宫建筑群',
          category: 'history',
          images: ['app.media.banner_hot_spring'],
        },
      ];
    }
  }

  // 加载推荐内容
  async loadRecommendations(location: string = '北京市', type?: string): Promise<void> {
    try {
      this.recommendations = await ApiService.getRecommendations(location, type);
    } catch (error) {
      console.error('加载推荐内容失败: ' + JSON.stringify(error));
      // 设置默认推荐数据
      this.recommendations = [
        {
          id: '1',
          type: 'scenic',
          title: '北京一日游',
          coverImage: 'app.media.banner_hot_spring',
          author: this.userInfo,
          views: 1000,
          likes: 200,
          comments: 50,
          createTime: new Date().toISOString(),
          isVideo: false,
          videoUrl: '',
        },
      ];
    }
  }

  // 加载热门搜索标签
  async loadHotTags(): Promise<void> {
    try {
      this.hotTags = await ApiService.getHotTags();
    } catch (error) {
      console.error('加载热门搜索标签失败: ' + JSON.stringify(error));
      // 设置默认热门标签
      this.hotTags = ['故宫', '长城', '天坛', '颐和园'];
    }
  }

  // 加载功能导航数据
  async loadFeatures(): Promise<void> {
    try {
      this.features = await ApiService.getFeatures();
    } catch (error) {
      console.error('加载功能导航数据失败: ' + JSON.stringify(error));
      // 设置默认功能数据
      this.features = [
        {
          id: '5',
          icon: 'app.media.ic_hotel',
          name: '酒店民俗',
          color: '#2196F3',
          badge: '',
          route: 'pages/HotelOrderPage',
        },
        {
          id: '6',
          icon: 'app.media.ic_culture',
          name: '旅游地图',
          color: '#FF5652',
          badge: 'HOT',
          route: '',
        },
        {
          id: '3',
          icon: 'app.media.ic_surrounding',
          name: '周边游',
          color: '#34C759',
          badge: '',
          route: 'pages/ThemeTravelPage',
        },
        {
          id: '1',
          icon: 'app.media.ic_parent_child',
          name: '亲子游',
          color: '#FF9800',
          badge: '',
          route: 'pages/ThemeTravelPage',
        },
        {
          id:'4',
          icon: 'app.media.ic_hot_spring',
          name: '温泉游',
          color: '#F44336',
          badge:'',
          route:'',
        },
        { id:'2',
          icon: 'app.media.ic_culture',
          name: '文化游',
          color: '#2196F3',
          badge:'',
          route:'pages/ThemeTravelPage',
        },
        { id:'7',
          icon:'app.media.ic_bus',
          name: '汽车票',
          color: '#1976D2',
          badge: '规划中',
          route:'',
        },
        { id:'8',
          icon:'app.media.ic_plane',
          name: '飞机票',
          color: '#FF9800',
          badge: '规划中',
          route:'',
        }
      ];
    }
  }

  // 加载酒店订单
  async loadHotelOrders(status?: string, page: number = 1): Promise<void> {
    try {
      this.hotelOrders = await ApiService.getHotelOrders(status, page);
    } catch (error) {
      console.error('加载酒店订单失败: ' + JSON.stringify(error));
      // 设置默认订单数据
      this.hotelOrders = [
        {
          id: '1',
          status: 'pending',
          hotelName: '北京国际酒店',
          address: '北京市东城区',
          checkInDate: '2025-10-01',
          checkOutDate: '2025-10-03',
          nights: 2,
          rooms: 1,
          roomType: '豪华大床房',
          price: 1200,
          orderTime: new Date().toISOString(),
        },
      ];
    }
  }

  // 取消酒店订单
  async cancelHotelOrder(orderId: string): Promise<void> {
    try {
      await ApiService.cancelHotelOrder(orderId);
      const order = this.hotelOrders.find((o) => o.id === orderId);
      if (order) {
        order.status = 'cancelled';
      }
    } catch (error) {
      console.error('取消酒店订单失败: ' + JSON.stringify(error));
      throw new Error('取消酒店订单失败');
    }
  }

  // 支付酒店订单
  async payHotelOrder(orderId: string): Promise<boolean> {
    try {
      await ApiService.payHotelOrder(orderId);
      const order = this.hotelOrders.find((o) => o.id === orderId);
      if (order) {
        order.status = 'unused';
      }
      return true;
    } catch (error) {
      console.error('支付酒店订单失败: ' + JSON.stringify(error));
      return false;
    }
  }

  // 提交反馈
  async submitFeedback(feedback: Feedback): Promise<boolean> {
    try {
      await ApiService.submitFeedback(feedback);
      return true;
    } catch (error) {
      console.error('提交反馈失败: ' + JSON.stringify(error));
      return false;
    }
  }

  // 创建游记
  async createTravelPost(post: TravelPost): Promise<boolean> {
    try {
      const result = await ApiService.createTravelPost(post);
      return !!result.id;
    } catch (error) {
      console.error('创建游记失败: ' + JSON.stringify(error));
      return false;
    }
  }

  // 加载视频列表
  async loadVideos(tab: string, page: number = 1): Promise<void> {
    try {
      this.videos = await ApiService.getVideos(tab, page);
    } catch (error) {
      console.error('加载视频列表失败: ' + JSON.stringify(error));
      // 设置默认视频数据
      this.videos = [
        {
          id: '1',
          title: '北京故宫游记',
          coverImage: 'app.media.banner_hot_spring',
          videoUrl: 'https://example.com/video.mp4',
          author: this.userInfo,
          views: 500,
          comments: 20,
          likes: 100,
          duration: '3:45',
          createTime: new Date().toISOString(),
        },
      ];
    }
  }

  // 上传图片
  async uploadImage(imageData: ArrayBuffer): Promise<string> {
    try {
      const result = await ApiService.uploadImage(imageData);
      return result.url;
    } catch (error) {
      console.error('上传图片失败: ' + JSON.stringify(error));
      return '';
    }
  }
}

export default new DataManager();