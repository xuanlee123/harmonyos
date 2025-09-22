import { router } from '@kit.ArkUI';
import DataManager from '../manager/DataManager';
import { ScenicSpot } from '../models/Types';

@Entry
@Component
struct ThemeTravelPage {
  @State searchText: string = '';
  @State isLoading: boolean = false;

  aboutToAppear() {
    this.loadScenicSpots();
  }

  async loadScenicSpots() {
    this.isLoading = true;
    await DataManager.loadScenicSpots(undefined, this.searchText);
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
        Text('主题旅游')
          .fontSize(20)
          .fontWeight(FontWeight.Bold)
        Blank()
      }
      .padding({ top: 16, left: 16, right: 16, bottom: 12 })
      .width('100%')

      // 搜索栏
      Row() {
        Image($r('app.media.ic_search'))
          .width(20)
          .height(20)
          .margin({ left: 12, right: 8 })
          .fillColor('#999')
        TextInput({
          placeholder: '搜索目的地 / 景点',
          text: this.searchText
        })
          .placeholderColor('#999')
          .height(40)
          .backgroundColor(Color.White)
          .borderRadius(20)
          .padding({ left: 8, right: 8 })
          .layoutWeight(1)
          .onChange((value: string) => {
            this.searchText = value;
          })
          .onSubmit((enterKey, event) => {
            this.loadScenicSpots();
          })
      }
      .backgroundColor(Color.White)
      .borderRadius(20)
      .height(40)
      .padding({ left: 16, right: 16, top: 12, bottom: 12 })
      .width('100%')

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
        // 景点列表
        List({ space: 16 }) {
          if (DataManager.scenicSpots.length === 0) {
            ListItem() {
              Column() {
                Image($r('app.media.ic_culture'))
                  .width(100)
                  .height(100)
                  .margin({ bottom: 16 })
                Text('暂无景点信息')
                  .fontSize(16)
                  .fontColor('#999')
                Text('请尝试其他搜索条件')
                  .fontSize(14)
                  .fontColor('#CCC')
                  .margin({ top: 8 })
              }
              .width('100%')
              .height(300)
              .justifyContent(FlexAlign.Center)
            }
          } else {
            ForEach(DataManager.scenicSpots, (spot: ScenicSpot) => {
              ListItem() {
                Row({ space: 12 }) {
                  Image(spot.images.length > 0 ? $r(spot.images[0]) : $r('app.media.banner_hot_spring'))
                    .width(120)
                    .height(90)
                    .objectFit(ImageFit.Cover)
                    .borderRadius(8)

                  Column({ space: 8 }) {
                    Text(spot.name)
                      .fontSize(16)
                      .fontWeight(FontWeight.Medium)
                      .fontColor('#333')
                      .maxLines(1)
                      .textOverflow({ overflow: TextOverflow.Ellipsis })

                    Row({ space: 8 }) {
                      Text(spot.level)
                        .fontSize(14)
                        .fontColor('#666')
                      Text(`${spot.rating}分`)
                        .fontSize(14)
                        .fontColor('#FF9500')
                      Text(`${spot.reviews}人评价`)
                        .fontSize(14)
                        .fontColor('#666')
                    }

                    Text(`距您${spot.distance}km`)
                      .fontSize(14)
                      .fontColor('#666')

                    Row({ space: 8 }) {
                      Button('可订明日')
                        .fontSize(12)
                        .fontColor('#2196F3')
                        .backgroundColor('#E3F2FD')
                        .borderRadius(4)
                        .padding({ left: 6, right: 6, top: 2, bottom: 2 })

                      Button('随时退')
                        .fontSize(12)
                        .fontColor('#2196F3')
                        .backgroundColor('#E3F2FD')
                        .borderRadius(4)
                        .padding({ left: 6, right: 6, top: 2, bottom: 2 })

                      if (spot.isFree) {
                        Text('免费预约')
                          .fontSize(14)
                          .fontColor('#FF5652')
                          .fontWeight(FontWeight.Bold)
                      } else {
                        Text(`¥${spot.price}起`)
                          .fontSize(14)
                          .fontColor('#FF5652')
                          .fontWeight(FontWeight.Bold)
                      }
                    }
                  }
                  .layoutWeight(1)
                }
                .padding(12)
                .backgroundColor(Color.White)
                .borderRadius(8)
                .shadow({ radius: 2, color: '#EEEEEE' })
                .onClick(() => {
                  router.pushUrl({ url: `pages/ScenicDetailPage?id=${spot.id}` });
                })
              }
            }, (spot: ScenicSpot) => spot.id)
          }
        }
        .width('100%')
        .layoutWeight(1)
        .padding({ left: 16, right: 16, top: 12, bottom: 16 })
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#F5F5F5')
  }
}