import router from '@ohos.router';
import ApiService from '../service/ApiService';
import { Message } from '../models/Types';

@Entry
@Component
struct ChatPage {
  @State isLoading: boolean = false;
  @State errorText: string = '';
  @State messages: Message[] = [];

  aboutToAppear() {
    this.fetchMessages();
  }

  private async fetchMessages() {
    this.isLoading = true;
    this.errorText = '';
    try {
      const list = await ApiService.getMessageList(1, 50);
      this.messages = Array.isArray(list) ? list : [];
    } catch (e) {
      this.errorText = '加载消息失败，请稍后重试';
      console.error('getMessageList error: ' + JSON.stringify(e));
    } finally {
      this.isLoading = false;
    }
  }

  @Builder
  renderHeader() {
    Row() {
      Image($r('app.media.ic_message1'))
        .width(22)
        .height(22)
        .margin({ right: 8 })
      Text('消息中心')
        .fontSize(20)
        .fontWeight(FontWeight.Medium)
      Blank()
      Text('刷新')
        .fontSize(14)
        .fontColor('#2196F3')
        .onClick(() => this.fetchMessages())
    }
    .padding({ left: 16, right: 16, top: 12, bottom: 12 })
    .width('100%')
  }

  @Builder
  renderEmpty() {
    Column() {
      Image($r('app.media.ic_message1'))
        .width(80)
        .height(80)
        .margin({ bottom: 12 })
      Text('暂无消息')
        .fontSize(14)
        .fontColor('#999')
    }
    .width('100%')
    .height('70%')
    .justifyContent(FlexAlign.Center)
    .alignItems(HorizontalAlign.Center)
  }

  @Builder
  renderCard(item: Message) {
    Column() {
      Row() {
        Image(item.senderAvatar && item.senderAvatar.length > 0 ? item.senderAvatar : $r('app.media.app_icon'))
          .width(42)
          .height(42)
          .borderRadius(21)
          .objectFit(ImageFit.Cover)
          .margin({ right: 12 })

        Column({ space: 6 }) {
          Row() {
            Text(item.title || '系统消息')
              .fontSize(16)
              .fontWeight(FontWeight.Medium)
              .maxLines(1)
              .textOverflow({ overflow: TextOverflow.Ellipsis })
            Blank()
            Text(item.time || '')
              .fontSize(12)
              .fontColor('#999')
          }

          Text(item.content || '')
            .fontSize(14)
            .fontColor('#666')
            .maxLines(2)
            .textOverflow({ overflow: TextOverflow.Ellipsis })

          if (item.badgeCount && item.badgeCount > 0) {
            Row() {
              Text(`${item.badgeCount} 条未读`)
                .fontSize(12)
                .fontColor(Color.White)
                .padding({ left: 8, right: 8, top: 2, bottom: 2 })
                .backgroundColor('#FF7043')
                .borderRadius(10)
            }
          }
        }
        .flexGrow(1)
      }
    }
    .padding(14)
    .width('100%')
    .backgroundColor(Color.White)
    .borderRadius(12)
    .shadow({ radius: 12, color: '#1A000000', offsetX: 0, offsetY: 2 })
  }

  build() {
    Column() {
      // 顶部栏
      this.renderHeader()

      // 内容区
      if (this.isLoading) {
        Column() {
          LoadingProgress()
          Text('加载中...').fontSize(12).fontColor('#999').margin({ top: 8 })
        }
        .height('80%')
        .justifyContent(FlexAlign.Center)
        .alignItems(HorizontalAlign.Center)
      } else if (this.errorText) {
        Column() {
          Text(this.errorText).fontSize(14).fontColor('#F44336').margin({ bottom: 8 })
          Button('重试')
            .backgroundColor('#2196F3')
            .fontColor(Color.White)
            .borderRadius(8)
            .padding(10)
            .onClick(() => this.fetchMessages())
        }
        .height('80%')
        .justifyContent(FlexAlign.Center)
        .alignItems(HorizontalAlign.Center)
      } else if (this.messages.length === 0) {
        this.renderEmpty()
      } else {
        List() {
          ForEach(this.messages, (m: Message) => {
            ListItem() {
              this.renderCard(m)
            }
            .margin({ left: 16, right: 16, top: 8, bottom: 8 })
            .onClick(async () => {
              try {
                if (m.id) {
                  await ApiService.readMessage(m.id);
                }
                // 未来可跳转到会话详情页
              } catch (e) {
                console.warn('readMessage failed: ' + JSON.stringify(e));
              }
            })
          }, (m: Message) => m.id)
        }
        .edgeEffect(EdgeEffect.None)
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#F5F6F7')
  }
}


