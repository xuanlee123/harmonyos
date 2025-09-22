import { router, promptAction } from '@kit.ArkUI';
import DataManager from '../manager/DataManager';
import { Feedback } from '../models/Types';

@Entry
@Component
struct FeedbackPage {
  @State type: '功能体验' | '商品相关' | '其他' = '功能体验';
  @State content: string = '';
  @State phone: string = '';
  @State images: string[] = [];
  @State isSubmitting: boolean = false;

  aboutToAppear() {
    this.phone = DataManager.userInfo.phone || '';
  }

  build() {
    Column({ space: 16 }) {
      // 顶部栏
      Row({ space: 10 }) {
        Image($r('app.media.ic_back'))
          .width(24)
          .height(24)
          .onClick(() => router.back())
        Text('意见反馈')
          .fontSize(20)
          .fontWeight(FontWeight.Bold)
        Blank()
      }
      .padding({ top: 16, left: 16, right: 16, bottom: 12 })
      .width('100%')

      // 意见类型
      Column() {
        Text('意见类型')
          .fontSize(14)
          .fontColor('#333')
          .margin({ bottom: 8 })
        Row({ space: 12 }) {
          this.TypeItem('功能体验', this.type === '功能体验')
          this.TypeItem('商品相关', this.type === '商品相关')
          this.TypeItem('其他', this.type === '其他')
        }
      }
      .padding({ left: 16, right: 16 })

      // 内容输入
      TextArea({ placeholder: '请输入问题或者建议，我们收到后会及时跟进...', text: this.content })
        .placeholderColor('#999')
        .fontSize(14)
        .height(300)
        .padding({ left: 16, right: 16, top: 8 })
        .width('100%')
        .onChange((value: string) => {
          this.content = value;
        })
      Text(`${this.content.length}/200`)
        .fontSize(12)
        .fontColor('#999')
        .padding({ right: 16 })
        .alignSelf(ItemAlign.End)

      // 图片上传
      Column() {
        Text('上传图片')
          .fontSize(14)
          .fontColor('#333')
          .margin({ bottom: 8 })
        Row({ space: 12 }) {
          ForEach(this.images, (imgUrl: string, index: number) => {
            Stack() {
              Image(imgUrl)
                .width(80)
                .height(80)
                .objectFit(ImageFit.Cover)
                .borderRadius(4)
              Image($r('app.media.ic_close'))
                .width(16)
                .height(16)
                .position({ x: 68, y: 2 })
                .onClick(() => {
                  this.images.splice(index, 1);
                })
            }
          }, (imgUrl: string, index: number) => index.toString())
          if (this.images.length < 4) {
            Stack() {
              Image($r('app.media.ic_add'))
                .width(80)
                .height(80)
                .objectFit(ImageFit.Contain)
                .backgroundColor('#F5F5F5')
                .borderRadius(4)
              Text(`(${this.images.length + 1}/4)`)
                .fontSize(12)
                .fontColor('#999')
                .position({ x: 52, y: 64 })
            }
            .onClick(() => {
              // 模拟选择图片，实际开发中需调用系统相册API
              this.images.push('app.media.banner_hot_spring');
            })
          }
        }
      }
      .padding({ left: 16, right: 16 })

      // 联系方式
      Row({ space: 8 }) {
        Text('联系方式：')
          .fontSize(14)
          .fontColor('#333')
        Text('+86')
          .fontSize(14)
          .fontColor('#666')
        TextInput({ placeholder: '请输入联系手机', text: this.phone })
          .placeholderColor('#999')
          .fontSize(14)
          .height(40)
          .width('100%')
          .onChange((value: string) => {
            this.phone = value;
          })
      }
      .padding({ left: 16, right: 16 })

      // 发送按钮
      Button('发送')
        .fontSize(16)
        .fontColor(Color.White)
        .backgroundColor(this.isSubmitting ? '#CCCCCC' : '#2196F3')
        .borderRadius(8)
        .width('90%')
        .height(48)
        .margin({ bottom: 24 })
        .enabled(!this.isSubmitting)
        .onClick(async () => {
          await this.submitFeedback();
        })
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#F5F5F5')
  }

  async submitFeedback() {
    if (this.content.trim() === '') {
      promptAction.showToast({ message: '请填写反馈内容', duration: 2000 });
      return;
    }

    if (this.phone.trim() === '') {
      promptAction.showToast({ message: '请填写联系方式', duration: 2000 });
      return;
    }

    this.isSubmitting = true;

    try {
      const feedback: Feedback = {
        id: '',
        type: this.type === '功能体验' ? 'feature' :
          this.type === '商品相关' ? 'product' : 'other',
        content: this.content,
        phone: this.phone,
        images: this.images,
        createTime: new Date().toISOString(),
        status: 'pending'
      };

      const success = await DataManager.submitFeedback(feedback);

      if (success) {
        promptAction.showToast({ message: '反馈发送成功', duration: 2000 });
        router.back();
      } else {
        promptAction.showToast({ message: '发送失败，请重试', duration: 2000 });
      }
    } catch (error) {
      promptAction.showToast({ message: '发送失败，请检查网络', duration: 2000 });
    } finally {
      this.isSubmitting = false;
    }
  }

  @Builder
  TypeItem(name: string, isActive: boolean = false) {
    Text(name)
      .fontSize(14)
      .fontColor(isActive ? '#2196F3' : '#666')
      .backgroundColor(isActive ? '#E3F2FD' : '#F5F5F5')
      .borderRadius(8)
      .padding({ left: 16, right: 16, top: 6, bottom: 6 })
      .onClick(() => {
        this.type = name as '功能体验' | '商品相关' | '其他';
      })
  }
}