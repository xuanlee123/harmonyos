import { router, promptAction } from '@kit.ArkUI';
import ApiService from '../service/ApiService';
import { ScenicSpot, User } from '../models/Types';

interface ScenicDetailParams {
  id: string;
}

@Entry
@Component
struct ScenicDetailPage {
  @State isLoading: boolean = false;
  @State errorMessage: string = '';
  @State scenic: ScenicSpot = new ScenicSpot();

  aboutToAppear() {
    const paramsObj: object = router.getParams();
    let id: string = '';
    try {
      const params = paramsObj as ScenicDetailParams;
      id = params && params.id ? params.id : '';
    } catch (e) {
      id = '';
    }

    if (!id) {
      this.errorMessage = '无效的景点ID';
      return;
    }

    this.loadScenicDetail(id);
  }

  async loadScenicDetail(id: string): Promise<void> {
    this.isLoading = true;
    this.errorMessage = '';
    try {
      const detail = await ApiService.getScenicSpotDetail(id);
      this.scenic = detail;
    } catch (e) {
      this.errorMessage = '加载景点详情失败，请稍后重试';
    } finally {
      this.isLoading = false;
    }
  }

  build() {
    Column() {
      // 顶部导航
      Row() {
        Text('返回')
          .fontSize(16)
          .fontColor('#2196F3')
          .onClick(() => router.back())
        Blank()
        Text('景点详情')
          .fontSize(18)
          .fontWeight(FontWeight.Medium)
          .fontColor('#333')
        Blank()
        Text('') // 占位
      }
      .padding({ left: 16, right: 16, top: 14, bottom: 10 })
      .width('100%')
      .backgroundColor(Color.White)

      if (this.isLoading) {
        Column() {
          LoadingProgress()
            .width(40)
            .height(40)
            .margin({ top: 60 })
          Text('正在加载...')
            .fontSize(14)
            .fontColor('#666')
            .margin({ top: 12 })
        }
        .width('100%')
        .height('100%')
        .justifyContent(FlexAlign.Start)
        .alignItems(HorizontalAlign.Center)
      }

      if (this.errorMessage) {
        Column() {
          Text(this.errorMessage)
            .fontSize(14)
            .fontColor('#F44336')
            .margin({ top: 60 })
          Button('重试')
            .margin({ top: 12 })
            .onClick(() => {
              const params = router.getParams() as ScenicDetailParams;
              this.loadScenicDetail(params.id);
            })
        }
        .width('100%')
        .height('100%')
        .justifyContent(FlexAlign.Start)
        .alignItems(HorizontalAlign.Center)
      }

      // 内容
      Scroll() {
        Column() {
          // 顶部图片
          Stack() {
            Image(this.scenic.images && this.scenic.images.length > 0 ? $r(this.scenic.images[0]) : $r('app.media.banner_hot_spring'))
              .width('100%')
              .height(200)
              .objectFit(ImageFit.Cover)

            if (this.scenic.heatLevel && this.scenic.heatLevel > 0) {
              Row() {
                ForEach(Array(5).fill(0), (n: number, idx: number) => {
                  Image($r(idx < this.scenic.heatLevel ? 'app.media.ic_video' : 'app.media.ic_video1'))
                    .width(14)
                    .height(14)
                    .margin({ right: 2 })
                }, (n: number, idx: number) => idx.toString())
              }
              .position({ x: 12, y: 12 })
              .backgroundColor('rgba(0,0,0,0.4)')
              .borderRadius(10)
              .padding({ left: 6, right: 6, top: 3, bottom: 3 })
            }
          }

          // 基本信息
          Column() {
            Text(this.scenic.name)
              .fontSize(20)
              .fontWeight(FontWeight.Medium)
              .fontColor('#333')
              .margin({ top: 12, bottom: 6 })

            Row() {
              Text(this.scenic.location)
                .fontSize(14)
                .fontColor('#666')
                .layoutWeight(1)

              if (this.scenic.rating && this.scenic.reviews) {
                Text(`${this.scenic.rating}分 · ${this.scenic.reviews}条点评`)
                  .fontSize(12)
                  .fontColor('#999')
              }
            }

            if (this.scenic.price && this.scenic.price > 0) {
              Text(`参考票价：¥${this.scenic.price}`)
                .fontSize(14)
                .fontColor('#FF5652')
                .margin({ top: 8 })
            }
          }
          .padding({ left: 16, right: 16, top: 12, bottom: 12 })
          .backgroundColor(Color.White)

          // 介绍
          if (this.scenic.description) {
            Column() {
              Text('景点介绍')
                .fontSize(16)
                .fontWeight(FontWeight.Medium)
                .fontColor('#333')
                .margin({ bottom: 8 })

              Text(this.scenic.description)
                .fontSize(14)
                .fontColor('#555')
                .lineHeight(20)
            }
            .padding(16)
            .backgroundColor(Color.White)
            .margin({ top: 10 })
          }

          // 购票（占位，不改后端接口）
          Column() {
            Text('门票与预订')
              .fontSize(16)
              .fontWeight(FontWeight.Medium)
              .fontColor('#333')
              .margin({ bottom: 8 })

            Text('根据景点不同，门票与票种可能不同，具体以实际为准。')
              .fontSize(13)
              .fontColor('#777')

            Button('购买门票')
              .fontSize(14)
              .fontColor(Color.White)
              .backgroundColor('#2196F3')
              .borderRadius(8)
              .margin({ top: 12 })
              .onClick(() => {
                promptAction.showToast({ message: '购票功能即将开放', duration: 2000 });
              })
          }
          .padding(16)
          .backgroundColor(Color.White)
          .margin({ top: 10, bottom: 20 })
        }
      }
      .layoutWeight(1)
      .backgroundColor('#F5F5F5')
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#F5F5F5')
  }
}


