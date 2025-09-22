import { router, promptAction } from '@kit.ArkUI';
import DataManager from '../manager/DataManager';
import { HotelOrder } from '../models/Types';

@Entry
@Component
struct HotelOrderPage {
  @State currentTab: string = '全部';
  @State isLoading: boolean = false;

  aboutToAppear() {
    this.loadOrders();
  }

  async loadOrders() {
    this.isLoading = true;
    await DataManager.loadHotelOrders(this.currentTab === '全部' ? undefined : this.currentTab);
    this.isLoading = false;
  }

  build() {
    Column() {
      // 顶部栏
      Row({ space: 10 }) {
        Image($r('app.media.ic_back'))
          .width(24)
          .height(24)
          .onClick(() => router.back())
        Text('酒店订单')
          .fontSize(20)
          .fontWeight(FontWeight.Bold)
          .fontColor('#000000')
        Blank()
        Image($r('app.media.ic_search'))
          .width(24)
          .height(24)
      }
      .padding({ top: 16, left: 16, right: 16, bottom: 12 })
      .width('100%')
      .backgroundColor('#FFFFFF')

      // 选项卡
      Scroll() {
        Row({ space: 20 }) {
          this.TabItem('全部', this.currentTab === '全部')
          this.TabItem('待付款', this.currentTab === '待付款')
          this.TabItem('未使用', this.currentTab === '未使用')
          this.TabItem('已取消', this.currentTab === '已取消')
        }
        .padding({ left: 16, right: 16 })
      }
      .scrollable(ScrollDirection.Horizontal)
      .height(44)
      .backgroundColor('#FFFFFF')

      // 加载状态
      if (this.isLoading) {
        Column() {
          Progress({ value: 0, total: 100 })
            .width(60)
            .height(60)
          Text('加载中...')
            .fontSize(14)
            .fontColor('#666')
            .margin({ top: 12 })
        }
        .width('100%')
        .height(200)
        .justifyContent(FlexAlign.Center)
      } else {
        // 订单列表
        List({ space: 16 }) {
          if (DataManager.hotelOrders.length === 0) {
            ListItem() {
              Column() {
                Image($r('app.media.ic_hotel'))
                  .width(100)
                  .height(100)
                  .margin({ bottom: 16 })
                Text(this.currentTab === '全部' ? '暂无订单' : `暂无${this.currentTab}的订单`)
                  .fontSize(16)
                  .fontColor('#999')
                Text('去预订酒店开启您的旅程吧~')
                  .fontSize(14)
                  .fontColor('#CCC')
                  .margin({ top: 8 })
              }
              .width('100%')
              .height(300)
              .justifyContent(FlexAlign.Center)
            }
          } else {
            ForEach(DataManager.hotelOrders, (order: HotelOrder) => {
              ListItem() {
                Column() {
                  // 酒店类型和状态行
                  Row({ space: 8 }) {
                    Image($r('app.media.ic_hotel'))
                      .width(20)
                      .height(20)
                    Text('酒店')
                      .fontSize(14)
                      .fontColor('#666666')
                    Blank()
                    Text(this.getStatusText(order.status))
                      .fontSize(14)
                      .fontColor(this.getStatusColor(order.status))
                  }
                  .width('100%')
                  .padding({ bottom: 12 })

                  // 酒店名称
                  Text(order.hotelName)
                    .fontSize(16)
                    .fontWeight(FontWeight.Medium)
                    .fontColor('#000000')
                    .margin({ bottom: 6 })
                    .width('100%')

                  // 酒店地址
                  Text(order.address)
                    .fontSize(12)
                    .fontColor('#999999')
                    .margin({ bottom: 6 })
                    .width('100%')

                  // 日期信息
                  Text(`${order.checkInDate} 到 ${order.checkOutDate} · ${order.nights}晚${order.rooms}间`)
                    .fontSize(12)
                    .fontColor('#999999')
                    .margin({ bottom: 6 })
                    .width('100%')

                  // 房间类型
                  Text(order.roomType)
                    .fontSize(12)
                    .fontColor('#999999')
                    .margin({ bottom: 12 })
                    .width('100%')

                  // 底部操作按钮和价格
                  Row({ space: 10 }) {
                    Blank()
                    if (order.status === 'pending') {
                      Button('取消')
                        .fontSize(14)
                        .fontColor('#666666')
                        .backgroundColor('#F2F2F2')
                        .borderRadius(4)
                        .width(80)
                        .height(32)
                        .onClick(() => {
                          this.cancelOrder(order.id);
                        })
                      Button('去支付')
                        .fontSize(14)
                        .fontColor(Color.White)
                        .backgroundColor('#FF9500')
                        .borderRadius(4)
                        .width(80)
                        .height(32)
                        .onClick(() => {
                          this.payOrder(order.id);
                        })
                    } else if (order.status === 'unused') {
                      Text(`¥${order.price}`)
                        .fontSize(16)
                        .fontColor('#FF9500')
                        .fontWeight(FontWeight.Bold)
                      Button('去使用')
                        .fontSize(14)
                        .fontColor(Color.White)
                        .backgroundColor('#34C759')
                        .borderRadius(4)
                        .width(80)
                        .height(32)
                    } else if (order.status === 'used') {
                      Text(`¥${order.price}`)
                        .fontSize(16)
                        .fontColor('#999999')
                        .fontWeight(FontWeight.Bold)
                      Button('再次预订')
                        .fontSize(14)
                        .fontColor('#666666')
                        .backgroundColor('#F2F2F2')
                        .borderRadius(4)
                        .width(80)
                        .height(32)
                    } else if (order.status === 'cancelled') {
                      Text(`¥${order.price}`)
                        .fontSize(16)
                        .fontColor('#999999')
                        .fontWeight(FontWeight.Bold)
                      Button('删除订单')
                        .fontSize(14)
                        .fontColor('#666666')
                        .backgroundColor('#F2F2F2')
                        .borderRadius(4)
                        .width(80)
                        .height(32)
                    }
                  }
                  .width('100%')
                }
                .padding(16)
                .backgroundColor(Color.White)
                .borderRadius(8)
                .shadow({ radius: 4, color: '#10000000', offsetX: 0, offsetY: 2 })
              }
            }, (order: HotelOrder) => order.id)
          }
        }
        .width('100%')
        .layoutWeight(1)
        .padding({ left: 16, right: 16, top: 12, bottom: 16 })
        .backgroundColor('#F5F5F5')
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#F5F5F5')
  }

  @Builder
  TabItem(name: string, isActive: boolean = false) {
    Column() {
      Text(name)
        .fontSize(16)
        .fontColor(isActive ? '#FF9500' : '#666666')
        .fontWeight(isActive ? FontWeight.Medium : FontWeight.Normal)
        .padding({ bottom: 8 })

      if (isActive) {
        Rect()
          .width(20)
          .height(2)
          .fill('#FF9500')
          .margin({ bottom: 4 })
      }
    }
    .height(44)
    .justifyContent(FlexAlign.End)
    .onClick(() => {
      this.currentTab = name;
      this.loadOrders();
    })
  }

  getStatusText(status: string): string {
    const statusMap: Record<string, string> = {
      'pending': '待支付',
      'unused': '未使用',
      'used': '已使用',
      'cancelled': '已取消'
    };
    return statusMap[status] || status;
  }

  getStatusColor(status: string): string {
    const colorMap: Record<string, string> = {
      'pending': '#FF9500',
      'unused': '#34C759',
      'used': '#999999',
      'cancelled': '#FF3B30'
    };
    return colorMap[status] || '#666666';
  }

  async cancelOrder(orderId: string) {
    promptAction.showDialog({
      title: '确认取消',
      message: '确定要取消这个订单吗？',
      buttons: [
        { text: '再想想', color: '#666666' },
        { text: '确定取消', color: '#FF3B30' }
      ]
    }).then(result => {
      if (result.index === 1) {
        DataManager.cancelHotelOrder(orderId);
        promptAction.showToast({ message: '订单已取消', duration: 2000 });
      }
    });
  }

  async payOrder(orderId: string) {
    const success = await DataManager.payHotelOrder(orderId);
    if (success) {
      promptAction.showToast({ message: '支付成功', duration: 2000 });
    } else {
      promptAction.showToast({ message: '支付失败，请重试', duration: 2000 });
    }
  }
}