import router from '@ohos.router';
import ApiService from '../service/ApiService';
import DataManager from '../manager/DataManager';
import { Message } from '../models/Types';

@Entry
@Component
struct ChatDetailPage {
  @State peerId: string = '';
  @State peerName: string = '';
  @State peerAvatar: string = 'app.media.banner_hot_spring';
  @State inputText: string = '';
  @State messages: Message[] = [];
  @State isLoading: boolean = false;
  @State currentUserId: string = '';
  scroller: Scroller = new Scroller();
  private pollTimer: number = 0;

  aboutToAppear() {
    const params = router.getParams() as Record<string, string>;
    this.peerId = params?.peerId || '';
    this.peerName = params?.peerName || '会话';
    this.peerAvatar = params?.peerAvatar || 'app.media.banner_hot_spring';
    this.currentUserId = (DataManager.userInfo && DataManager.userInfo.id) ? DataManager.userInfo.id : '1';
    this.loadConversation();
    // 开启轮询刷新
    this.startPolling();
  }

  aboutToDisappear() {
    this.stopPolling();
  }

  private async loadConversation() {
    if (!this.peerId) { return; }
    this.isLoading = true;
    try {
      const list = await ApiService.getConversation(this.currentUserId, this.peerId);
      this.messages = list;
      // 将对方发来的未读标记为已读
      const unreadMine: Message[] = this.messages.filter((m) => m.senderId !== this.currentUserId && m.badgeCount > 0);
      for (const m of unreadMine) {
        try { await ApiService.markChatRead(m.id); m.badgeCount = 0; } catch (_) {}
      }
      // 刷新首页会话聚合
      try { await DataManager.loadMessages(); } catch (_) {}
      // 滚动到底部
      this.scrollToBottom();
    } catch (e) {
      console.error('loadConversation error: ' + JSON.stringify(e));
    } finally {
      this.isLoading = false;
    }
  }

  private async onSend() {
    const text = this.inputText.trim();
    if (!text || !this.peerId) return;
    try {
      const sent = await ApiService.sendChat(this.currentUserId, this.peerId, text);
      this.messages.push(sent);
      this.inputText = '';
      // 刷新首页会话聚合
      try { await DataManager.loadMessages(); } catch (_) {}
      this.scrollToBottom();
    } catch (e) {
      console.error('sendChat error: ' + JSON.stringify(e));
    }
  }

  private scrollToBottom() {
    // 简单滚动到较大位置以确保到底
    try { this.scroller.scrollTo({ xOffset: 0, yOffset: 999999, animation: { duration: 200 } }); } catch (_) {}
  }

  private startPolling() {
    if (this.pollTimer !== 0) return;
    // 每 4 秒轮询一次，避免并发
    const id: number = setInterval(async () => {
      if (this.isLoading) return;
      try {
        await this.loadConversation();
      } catch (_) {}
    }, 4000);
    this.pollTimer = id;
  }

  private stopPolling() {
    if (this.pollTimer !== 0) {
      try { clearInterval(this.pollTimer); } catch (_) {}
      this.pollTimer = 0;
    }
  }

  @Builder
  Header() {
    Row() {
      Image($r(this.peerAvatar))
        .width(28)
        .height(28)
        .borderRadius(14)
        .margin({ right: 8 })
      Text(this.peerName)
        .fontSize(18)
        .fontWeight(FontWeight.Medium)
      Blank()
      Text('返回')
        .fontSize(14)
        .fontColor('#2196F3')
        .onClick(() => router.back())
    }
    .padding({ left: 16, right: 16, top: 12, bottom: 12 })
    .width('100%')
    .backgroundColor(Color.White)
  }

  @Builder
  Bubble(item: Message) {
    Row() {
      if (!this.isMine(item)) {
        Image($r(this.peerAvatar)).width(28).height(28).borderRadius(14).margin({ right: 8 })
      } else {
        Blank().width(28).height(28).margin({ right: 8 })
      }
      Text(item.content)
        .fontSize(14)
        .fontColor(this.isMine(item) ? Color.White : '#333')
        .padding({ left: 10, right: 10, top: 8, bottom: 8 })
        .backgroundColor(this.isMine(item) ? '#2196F3' : '#F1F1F1')
        .borderRadius(10)
        .layoutWeight(1)
      if (this.isMine(item)) {
        Blank().width(8)
      }
    }
    .justifyContent(this.isMine(item) ? FlexAlign.End : FlexAlign.Start)
    .padding({ left: 12, right: 12, top: 8, bottom: 8 })
  }

  private isMine(item: Message): boolean {
    return item.senderId === this.currentUserId;
  }

  build() {
    Column() {
      this.Header()

      if (this.isLoading) {
        Column() { LoadingProgress() }.layoutWeight(1).justifyContent(FlexAlign.Center).alignItems(HorizontalAlign.Center)
      } else {
        Scroll(this.scroller) {
          Column() {
            ForEach(this.messages, (m: Message, idx: number) => {
              this.Bubble(m)
            }, (m: Message, idx: number) => m.id + '_' + idx)
          }
        }
        .layoutWeight(1)
        .backgroundColor('#FAFAFA')
      }

      // 输入栏
      Row() {
        TextInput({ placeholder: '输入消息...', text: this.inputText })
          .height(44)
          .backgroundColor('#F5F5F5')
          .borderRadius(22)
          .padding({ left: 12, right: 12 })
          .layoutWeight(1)
          .onChange((v: string) => this.inputText = v)
        Button('发送')
          .height(44)
          .backgroundColor('#2196F3')
          .fontColor(Color.White)
          .borderRadius(22)
          .padding({ left: 16, right: 16 })
          .onClick(() => this.onSend())
      }
      .padding({ left: 12, right: 12, top: 8, bottom: 12 })
      .backgroundColor(Color.White)
    }
    .width('100%')
    .height('100%')
    .backgroundColor(Color.White)
  }
}


