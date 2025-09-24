import router from '@ohos.router';
import http from '@ohos.net.http';
import ApiService from '../service/ApiService';

// 定义API响应数据类型
// 后端登录返回结构（与后端 LoginResponse 对应）
interface LoginResponseDto {
  token: string;
  tokenType: string; // Bearer
  userId: number;
  username: string;
  nickname: string;
  role: string;
}

// 定义HTTP错误类型（替代http.HttpError）
interface HttpError {
  code: number;
  message: string;
}

@Entry
@Component
struct Index {
  // 状态管理
  @State isLoginMode: boolean = true; // true: 登录模式, false: 注册模式
  @State username: string = '';
  @State password: string = '';
  @State confirmPassword: string = '';
  @State isLoading: boolean = false;
  @State errorMessage: string = '';

  build() {
    Column() {
      // 标题
      Text(this.isLoginMode ? '欢迎登录' : '账号注册')
        .fontSize(28)
        .fontWeight(FontWeight.Bold)
        .margin({ top: 80, bottom: 60 })
        .textAlign(TextAlign.Center)
        .width('100%')

      // 错误提示
      if (this.errorMessage) {
        Text(this.errorMessage)
          .fontSize(14)
          .fontColor('#F44336')
          .margin({ bottom: 15 })
          .textAlign(TextAlign.Center)
          .width('100%')
      }

      // 输入框区域
      Column({ space: 20 }) {
        // 用户名输入
        TextInput({
          placeholder: '请输入用户名'
        })
          .type(InputType.Normal)
          .onChange((value: string) => {
            this.username = value;
            this.errorMessage = '';
          })
          .padding(15)
          .backgroundColor('#F5F5F5')
          .borderRadius(10)
          .width('80%')

        // 密码输入
        TextInput({
          placeholder: '请输入密码'
        })
          .type(InputType.Password)
          .onChange((value: string) => {
            this.password = value;
            this.errorMessage = '';
          })
          .padding(15)
          .backgroundColor('#F5F5F5')
          .borderRadius(10)
          .width('80%')

        // 确认密码（仅注册模式显示）
        if (!this.isLoginMode) {
          TextInput({
            placeholder: '请确认密码'
          })
            .type(InputType.Password)
            .onChange((value: string) => {
              this.confirmPassword = value;
              this.errorMessage = '';
            })
            .padding(15)
            .backgroundColor('#F5F5F5')
            .borderRadius(10)
            .width('80%')
        }
      }

      // 操作按钮
      Column({ space: 15 }) {
        // 登录/注册按钮
        Button(this.isLoginMode ? '登录' : '注册')
          .fontSize(16)
          .fontWeight(FontWeight.Medium)
          .backgroundColor('#2196F3')
          .fontColor(Color.White)
          .borderRadius(10)
          .padding(12)
          .width('80%')
          .onClick(() => {
            this.handleAuth();
          })
          .enabled(!this.isLoading)

        // 临时跳转按钮（用于测试）
        Button('跳过登录，直接进入')
          .fontSize(16)
          .fontWeight(FontWeight.Medium)
          .backgroundColor(Color.White)
          .fontColor('#2196F3')
          .border({ width: 1, color: '#2196F3' })
          .borderRadius(10)
          .padding(12)
          .width('80%')
          .onClick(() => {
            this.navigateToHomePage();
          })

        // 切换模式按钮
        Text(this.isLoginMode ? '还没有账号？立即注册' : '已有账号？立即登录')
          .fontSize(14)
          .fontColor('#2196F3')
          .onClick(() => {
            this.switchMode();
          })
      }
      .margin({ top: 40 })
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#F9F9F9')
  }

  // 切换登录/注册模式
  switchMode(): void {
    this.isLoginMode = !this.isLoginMode;
    this.username = '';
    this.password = '';
    this.confirmPassword = '';
    this.errorMessage = '';
  }

  // 处理登录/注册逻辑
  handleAuth(): void {
    // 简单验证
    if (!this.username) {
      this.errorMessage = '请输入用户名';
      return;
    }

    if (!this.password) {
      this.errorMessage = '请输入密码';
      return;
    }

    if (!this.isLoginMode && this.password !== this.confirmPassword) {
      this.errorMessage = '两次输入的密码不一致';
      return;
    }

    this.isLoading = true;

    if (this.isLoginMode) {
      this.login();
    } else {
      this.register();
    }
  }

  // 登录逻辑 - 调用 ApiService 对接后端
  async login(): Promise<void> {
    try {
      const result: LoginResponseDto = await ApiService.login(this.username, this.password);
      // 可选：持久化 token
      // AppStorage.SetOrCreate('authToken', `${result.tokenType} ${result.token}`);
      // 登录成功进入主页
      this.navigateToHomePage();
    } catch (e) {
      console.error('登录失败: ' + JSON.stringify(e));
      this.errorMessage = '登录失败，请检查用户名或密码';
    } finally {
      this.isLoading = false;
    }
  }

  // 注册逻辑 - 调用 ApiService 对接后端
  async register(): Promise<void> {
    try {
      const ok = await ApiService.register(this.username, this.password);
      if (ok) {
        this.errorMessage = '注册成功，请登录';
        this.switchMode();
      } else {
        this.errorMessage = '注册失败，请稍后重试';
      }
    } catch (e) {
      console.error('注册失败: ' + JSON.stringify(e));
      this.errorMessage = '注册失败，请稍后重试';
    } finally {
      this.isLoading = false;
    }
  }

  // 跳转到TravelHomePage
  navigateToHomePage(): void {
    router.pushUrl({
      url: 'pages/TravelHomePage'
    }).then(() => {
      console.log('跳转到TravelHomePage成功');
    }).catch((err: Error) => {
      console.error(`跳转失败: ${JSON.stringify(err)}`);
      this.errorMessage = '页面跳转失败，请重试';
    });
  }
}
    