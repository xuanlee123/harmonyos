import { router, promptAction } from '@kit.ArkUI';
import DataManager from '../manager/DataManager';
import { TravelPost } from '../models/Types';

@Entry
@Component
struct TravelPostPage {
  @State title: string = '';
  @State content: string = '';
  @State location: string = '故宫博物馆';
  @State images: string[] = [];
  @State isAgree: boolean = false;
  @State isSubmitting: boolean = false;

  build() {
    Column({ space: 16 }) {
      // 顶部操作栏
      Row({ space: 10 }) {
        Text('取消')
          .fontSize(16)
          .fontColor('#333')
          .onClick(() => {
            router.back();
          })
        Blank()
        Button('发布')
          .fontSize(16)
          .fontColor(Color.White)
          .backgroundColor(this.isSubmitting ? '#CCCCCC' : '#2196F3')
          .borderRadius(8)
          .width(80)
          .enabled(!this.isSubmitting)
          .onClick(async () => {
            await this.submitPost();
          })
      }
      .padding({ top: 16, left: 16, right: 16, bottom: 8 })
      .width('100%')

      // 图片上传区域
      Scroll() {
        Column() {
          // 图片上传
          Row() {
            ForEach(this.images, (imgUrl: string, index: number) => {
              Stack() {
                Image(imgUrl)
                  .width(100)
                  .height(100)
                  .objectFit(ImageFit.Cover)
                  .borderRadius(8)
                Image($r('app.media.ic_close'))
                  .width(20)
                  .height(20)
                  .position({ x: 80, y: 0 })
                  .onClick(() => {
                    this.images.splice(index, 1);
                  })
              }
              .margin({ right: 8 })
            }, (imgUrl: string, index: number) => index.toString())

            if (this.images.length < 9) {
              Stack() {
                Image($r('app.media.ic_add'))
                  .width(100)
                  .height(100)
                  .objectFit(ImageFit.Contain)
                  .backgroundColor('#F5F5F5')
                  .borderRadius(8)
                Text(`上传图片\n(${this.images.length}/9)`)
                  .fontSize(12)
                  .fontColor('#999')
                  .textAlign(TextAlign.Center)
              }
              .onClick(() => {
                // 模拟选择图片
                if (this.images.length < 9) {
                  this.images.push('app.media.banner_hot_spring');
                }
              })
            }
          }
          .padding({ left: 16, right: 16, bottom: 16 })

          Text('上传图片会让更多人看到你的精彩旅拍哦~')
            .fontSize(12)
            .fontColor('#999')
            .padding({ left: 16, right: 16, bottom: 16 })

          // 标题输入
          TextInput({ placeholder: '请输入标题...', text: this.title })
            .placeholderColor('#999')
            .fontSize(16)
            .height(40)
            .padding({ left: 16, right: 16 })
            .width('100%')
            .onChange((value: string) => {
              this.title = value;
            })
          Text(`${this.title.length}/30`)
            .fontSize(12)
            .fontColor('#999')
            .padding({ right: 16 })
            .alignSelf(ItemAlign.End)

          // 内容输入
          TextArea({ placeholder: '请详细分享你的真实体验、实用攻略或一些小贴士...', text: this.content })
            .placeholderColor('#999')
            .fontSize(14)
            .height(200)
            .padding({ left: 16, right: 16, top: 8 })
            .width('100%')
            .onChange((value: string) => {
              this.content = value;
            })
          Text(`${this.content.length}/10000`)
            .fontSize(12)
            .fontColor('#999')
            .padding({ right: 16 })
            .alignSelf(ItemAlign.End)

          // 位置选择
          Row({ space: 8 }) {
            Image($r('app.media.ic_location'))
              .width(20)
              .height(20)
              .fillColor('#999')
            Text(this.location)
              .fontSize(16)
              .fontColor('#333')
              .flexGrow(1)
            Image($r('app.media.ic_message1'))
              .width(16)
              .height(16)
              .fillColor('#999')
          }
          .padding({ left: 16, right: 16, top: 8, bottom: 8 })
          .width('100%')
          .backgroundColor('#F5F5F5')
          .borderRadius(8)

          // 协议勾选
          Row({ space: 8 }) {
            Checkbox()
              .select(this.isAgree)
              .onChange((value: boolean) => {
                this.isAgree = value;
              })
            Text('我已阅读并同意')
              .fontSize(12)
              .fontColor('#666')
            Text('《内容上传协议》')
              .fontSize(12)
              .fontColor('#2196F3')
          }
          .padding({ left: 16, right: 16, bottom: 16 })
        }
      }
      .layoutWeight(1)
    }
    .width('100%')
    .height('100%')
    .backgroundColor(Color.White)
  }

  async submitPost() {
    if (!this.isAgree) {
      promptAction.showToast({ message: '请同意内容上传协议', duration: 2000 });
      return;
    }

    if (this.title.trim() === '') {
      promptAction.showToast({ message: '请输入标题', duration: 2000 });
      return;
    }

    if (this.content.trim() === '') {
      promptAction.showToast({ message: '请输入内容', duration: 2000 });
      return;
    }

    this.isSubmitting = true;

    try {
      const post: TravelPost = {
        id: '',
        title: this.title,
        content: this.content,
        images: this.images,
        location: this.location,
        authorId: DataManager.userInfo.id,
        likes: 0,
        comments: 0,
        views: 0,
        createTime: new Date().toISOString()
      };

      const success = await DataManager.createTravelPost(post);

      if (success) {
        promptAction.showToast({ message: '发布成功', duration: 2000 });
        router.back();
      } else {
        promptAction.showToast({ message: '发布失败，请重试', duration: 2000 });
      }
    } catch (error) {
      promptAction.showToast({ message: '发布失败，请检查网络', duration: 2000 });
    } finally {
      this.isSubmitting = false;
    }
  }
}