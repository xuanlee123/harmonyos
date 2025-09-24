import { router } from '@kit.ArkUI';
import DataManager from '../manager/DataManager';
import { FeatureItem, Message, RecommendItem, ScenicSpot, VideoItem, Conversation } from '../models/Types';
import ApiService from '../service/ApiService';

interface GeneratedObjectLiteralInterface_1 {
  radius: number;
  color: string;
  offsetX: number;
  offsetY: number;
}

@Entry
@Component
struct TravelHomePage {
  @State currentIndex: number = 0;
  @State videoTabIndex: number = 0;
  @State scenicSearchText: string = '';
  @State scenicCategory: string = 'all';
  @State isRefreshing: boolean = false;
  @State isLoadingMessages: boolean = false;
  @State messageError: string = '';

  private readonly PRIMARY_COLOR: string = '#2196F3';
  private readonly ACCENT_COLOR: string = '#FF5652';
  private readonly TEXT_PRIMARY: string = '#333';
  private readonly TEXT_SECONDARY: string = '#666';
  private readonly TEXT_MUTED: string = '#999';
  private readonly BG_LIGHT: string = '#F5F5F5';
  private readonly CARD_SHADOW: GeneratedObjectLiteralInterface_1 ={radius: 8, color: '#12000000', offsetX: 0, offsetY: 1 };

  aboutToAppear() {
    DataManager.initData();
  }

  // 下拉刷新
  async onRefresh() {
    this.isRefreshing = true;
    await DataManager.initData();
    this.isRefreshing = false;
  }

  // 仅刷新消息/会话数据
  private async reloadConversations(): Promise<void> {
    this.isLoadingMessages = true;
    this.messageError = '';
    try {
      await DataManager.loadMessages();
    } catch (e) {
      this.messageError = '消息加载失败，请稍后重试';
    } finally {
      this.isLoadingMessages = false;
    }
  }

  // 工具: 分组景点
  private chunkScenicSpots(input: ScenicSpot[], chunkSize: number = 3): ScenicSpot[][] {
    const chunks: ScenicSpot[][] = [];
    for (let i = 0; i < input.length; i += chunkSize) {
      chunks.push(input.slice(i, i + chunkSize));
    }
    return chunks;
  }

  // 事件: 搜索触发
  private triggerScenicSearch() {
    DataManager.loadScenicSpots(this.scenicCategory, this.scenicSearchText);
  }

  // 事件: 切换视频Tab
  private switchVideoTab(tabIndex: number) {
    this.videoTabIndex = tabIndex;
    if (tabIndex === 0) {
      DataManager.loadVideos('关注');
    } else if (tabIndex === 1) {
      DataManager.loadScenicSpots();
    } else {
      DataManager.loadVideos('推荐');
    }
  }

  build() {
    Column() {
      Stack() {
        if (this.currentIndex === 0) {
          this.HomeContent()
        }
        if (this.currentIndex === 1) {
          this.VideoContent()
        }
        if (this.currentIndex === 2) {
          this.MessageContent()
        }
        if (this.currentIndex === 3) {
          this.ProfileContent()
        }
      }
      .width('100%')
      .layoutWeight(1)

      // 底部导航栏
      this.BottomNav()
    }
  }

  // 底部导航栏
  @Builder
  BottomNav() {
    Row() {
      this.NavItem('首页', $r('app.media.ic_home'), 0)
      this.NavItem('视频', $r('app.media.ic_video'), 1)
      this.NavItem('消息', $r('app.media.ic_message'), 2, DataManager.messages.some(msg => msg.badgeCount > 0))
      this.NavItem('我的', $r('app.media.ic_mine'), 3)
    }
    .height(56)
    .backgroundColor(Color.White)
    .width('100%')
  }

  @Builder
  NavItem(name: string, icon: Resource, index: number, hasBadge: boolean = false) {
    Column() {
      if (hasBadge) {
        Stack() {
          Image(icon)
            .width(24)
            .height(24)
            .fillColor(this.currentIndex === index ? this.PRIMARY_COLOR : this.TEXT_MUTED)
          Circle()
            .fill('#F44336')
            .width(8)
            .height(8)
            .margin({ top: -2, left: 14 })
        }
        .height(24)
      } else {
        Image(icon)
          .width(24)
          .height(24)
          .fillColor(this.currentIndex === index ? this.PRIMARY_COLOR : this.TEXT_MUTED)
      }

      Text(name)
        .fontSize(11)
        .fontColor(this.currentIndex === index ? this.PRIMARY_COLOR : this.TEXT_MUTED)
        .margin({ top: 2 })
    }
    .layoutWeight(1)
    .height(56)
    .justifyContent(FlexAlign.Center)
    .onClick(() => {
      this.currentIndex = index
      if (index === 1) {
        DataManager.loadVideos('关注');
      }
    })
  }

  // 首页内容
  @Builder
  HomeContent() {
    Column() {
      // 顶部搜索栏
      this.HomeSearchBar()

      // 主内容区
      Scroll() {
        Column() {
          // 功能导航区
          this.FeaturesGrid()

          // 横幅广告
          this.BannerHotSpring()

          // 内容推荐区
          this.RecommendSection()

          Blank()
            .height(60)
        }
        .width('100%')
      }
      .layoutWeight(1)
      .backgroundColor(this.BG_LIGHT)
      .onScrollEdge((side) => {
        if (side.toString() === 'Top') {
          this.onRefresh();
        }
      })
    }
  }

  // 顶部搜索栏(首页)
  @Builder
  HomeSearchBar() {
    Column() {
      Row() {
        // 搜索框
        Row() {
          Image($r('app.media.ic_search'))
            .width(20)
            .height(20)
            .margin({ left: 12 })
            .fillColor(this.TEXT_MUTED)

          TextInput({ placeholder: '搜索目的地 / 景点', text: this.scenicSearchText })
            .height(40)
            .backgroundColor(Color.White)
            .borderRadius(20)
            .padding({ left: 8, right: 8 })
            .layoutWeight(1)
            .onChange((value: string) => {
              this.scenicSearchText = value;
            })
            .onSubmit((enterKey, event) => {
              this.triggerScenicSearch();
            })
        }
        .backgroundColor(Color.White)
        .borderRadius(20)
        .height(40)
        .layoutWeight(1)
        .margin({ right: 10 })

        // 搜索按钮
        Button('搜索')
          .fontSize(14)
          .fontWeight(FontWeight.Medium)
          .backgroundColor('#1976D2')
          .fontColor(Color.White)
          .borderRadius(20)
          .padding({ left: 15, right: 15 })
          .height(40)
          .width(80)
          .onClick(() => this.triggerScenicSearch())
      }
      .justifyContent(FlexAlign.SpaceBetween)
      .padding({ left: 15, right: 15, top: 12, bottom: 8 })
      .width('100%')

      // 热门标签
      Flex({ wrap: FlexWrap.Wrap }) {
        ForEach(DataManager.hotTags, (tag: string) => {
          Text(tag)
            .fontSize(12)
            .backgroundColor('#1976D2')
            .fontColor(Color.White)
            .borderRadius(12)
            .padding({ left: 10, right: 10, top: 4, bottom: 4 })
            .margin({ right: 8, bottom: 8 })
            .onClick(() => {
              this.scenicSearchText = tag;
              this.triggerScenicSearch();
            })
        }, (tag: string) => tag)
      }
      .padding({ left: 15, right: 15, top: 0, bottom: 12 })
      .width('100%')
    }
    .backgroundColor(this.PRIMARY_COLOR)
    .width('100%')
  }

  // 功能导航区
  @Builder
  FeaturesGrid() {
    Grid() {
      ForEach(DataManager.features, (item: FeatureItem) => {
        GridItem() {
          Column() {
            Stack() {
              Circle()
                .fill(item.color)
                .width(45)
                .height(45)

              Image($r(item.icon))
                .width(22)
                .height(22)
                .fillColor(Color.White)

              if (item.badge) {
                Text(item.badge)
                  .fontSize(9)
                  .backgroundColor('#FFEB3B')
                  .fontColor(Color.Black)
                  .borderRadius(5)
                  .padding({ left: 2, right: 2, top: 1, bottom: 1 })
                  .position({ x: 32, y: -3 })
              }
            }
            .onClick(() => {
              if (item.route) {
                router.pushUrl({ url: item.route });
              }
            })

            Text(item.name)
              .fontSize(12)
              .margin({ top: 5 })
              .fontColor(this.TEXT_PRIMARY)
              .maxLines(1)
          }
          .justifyContent(FlexAlign.Center)
          .height(90)
        }
      }, (item: FeatureItem) => item.id)
    }
    .columnsTemplate('1fr 1fr 1fr 1fr')
    .rowsGap(10)
    .columnsGap(8)
    .padding({ left: 15, right: 15, top: 15 })
    .width('100%')
  }

  // 横幅广告
  @Builder
  BannerHotSpring() {
    Stack() {
      Image($r('app.media.banner_hot_spring'))
        .width('100%')
        .height(100)
        .objectFit(ImageFit.Cover)
        .borderRadius(8)

      Column() {
        Text('冬日温泉')
          .fontSize(20)
          .fontWeight(FontWeight.Medium)
          .fontColor(Color.White)

        Text('暖/冬/旅/游/一/起/来/泡/温/泉/吧')
          .fontSize(11)
          .fontColor(Color.White)
          .margin({ top: 3 })
      }
      .margin({ left: 12, bottom: 10 })
      .alignItems(HorizontalAlign.Start)
      .justifyContent(FlexAlign.End)
    }
    .padding({ left: 15, right: 15, top: 12, bottom: 5 })
  }

  // 内容推荐区
  @Builder
  RecommendSection() {
    Column() {
      Row() {
        Image($r('app.media.ic_location'))
          .width(14)
          .height(14)
          .fillColor(this.PRIMARY_COLOR)

        Text(`带你玩遍 ${DataManager.userInfo.location}`)
          .fontSize(14)
          .fontWeight(FontWeight.Medium)
          .fontColor(this.PRIMARY_COLOR)
          .margin({ left: 4 })
      }
      .padding({ left: 15, right: 15, top: 12, bottom: 8 })

      Row() {
        ForEach(DataManager.recommendations, (item: RecommendItem) => {
          this.RecommendCard(item)
        }, (item: RecommendItem) => item.id)
      }
      .justifyContent(FlexAlign.SpaceBetween)
      .padding({ left: 15, right: 15 })
    }
  }

  @Builder
  RecommendCard(item: RecommendItem) {
    Column() {
      Stack() {
        Image($r(item.coverImage))
          .width('100%')
          .height(120)
          .objectFit(ImageFit.Cover)
          .borderRadius({ topLeft: 8, topRight: 8 })

        if (item.isVideo) {
          Column() {
            Image($r('app.media.ic_play'))
              .width(16)
              .height(16)
              .fillColor(Color.White)
          }
          .width(25)
          .height(25)
          .backgroundColor('rgba(0, 0, 0, 0.5)')
          .borderRadius(12)
          .justifyContent(FlexAlign.Center)
          .alignItems(HorizontalAlign.Center)
          .position({ x: '85%', y: 8 })
        }
      }

      Column() {
        Text(item.title)
          .fontSize(12)
          .fontWeight(FontWeight.Medium)
          .fontColor(this.TEXT_PRIMARY)
          .margin({ bottom: 6 })
          .maxLines(2)
          .textOverflow({ overflow: TextOverflow.Ellipsis })
          .height(40)

        Row() {
          Row() {
            Image($r(item.author.avatar))
              .width(18)
              .height(18)
              .borderRadius(9)

            Text(item.author.nickname)
              .fontSize(11)
              .fontColor(this.TEXT_MUTED)
              .margin({ left: 4 })
              .layoutWeight(1)
              .maxLines(1)
          }

          Text(`${item.views}次浏览`)
            .fontSize(11)
            .fontColor(this.TEXT_MUTED)
        }
        .alignItems(VerticalAlign.Center)
        .height(20)
      }
      .padding(8)
      .backgroundColor(Color.White)
      .borderRadius({ bottomLeft: 8, bottomRight: 8 })
    }
    .width('48%')
    .shadow({ radius: 3, color: '#EEEEEE' })
    .borderRadius(8)
    .margin({ bottom: 10 })
    .height(200)
  }

  // 视频页面内容
  @Builder
  VideoContent() {
    Column() {
      // 视频页面顶部选项卡
      Row() {
        Text('关注')
          .fontSize(16)
          .fontColor(this.videoTabIndex === 0 ? this.ACCENT_COLOR : this.TEXT_MUTED)
          .fontWeight(this.videoTabIndex === 0 ? FontWeight.Medium : FontWeight.Normal)
          .margin({ right: 24 })
          .onClick(() => this.switchVideoTab(0))

        Text('名胜')
          .fontSize(16)
          .fontColor(this.videoTabIndex === 1 ? this.ACCENT_COLOR : this.TEXT_MUTED)
          .fontWeight(this.videoTabIndex === 1 ? FontWeight.Medium : FontWeight.Normal)
          .margin({ right: 24 })
          .onClick(() => this.switchVideoTab(1))

        Text('推荐')
          .fontSize(16)
          .fontColor(this.videoTabIndex === 2 ? this.ACCENT_COLOR : this.TEXT_MUTED)
          .fontWeight(this.videoTabIndex === 2 ? FontWeight.Medium : FontWeight.Normal)
          .onClick(() => this.switchVideoTab(2))

        Blank()
          .layoutWeight(1)
      }
      .padding({ top: 16, bottom: 16, left: 16, right: 16 })
      .width('100%')
      .backgroundColor(Color.White)

      if (this.videoTabIndex === 0) {
        this.VideoListContent()
      } else if (this.videoTabIndex === 1) {
        this.ScenicSpotsContent()
      } else {
        this.VideoRecommendContent()
      }
    }
  }

  @Builder
  VideoListContent() {
    Scroll() {
      Column() {
        ForEach(DataManager.videos, (video: VideoItem) => {
          this.VideoCard(video)
        }, (video: VideoItem) => video.id)
      }
      .padding(12)
    }
    .layoutWeight(1)
  }

  @Builder
  VideoCard(video: VideoItem) {
    Column() {
      Stack() {
        Image($r(video.coverImage))
          .width('100%')
          .height(200)
          .objectFit(ImageFit.Cover)

        Column() {
          Image($r('app.media.ic_play'))
            .width(40)
            .height(40)
            .fillColor(Color.White)
        }
        .width(60)
        .height(60)
        .backgroundColor('rgba(0, 0, 0, 0.5)')
        .borderRadius(30)
        .justifyContent(FlexAlign.Center)
        .alignItems(HorizontalAlign.Center)
      }

      Column() {
        Text(video.title)
          .fontSize(16)
          .fontWeight(FontWeight.Medium)
          .fontColor(this.TEXT_PRIMARY)
          .margin({ bottom: 8 })
          .maxLines(2)

        Row() {
          Row() {
            Image($r(video.author.avatar))
              .width(30)
              .height(30)
              .borderRadius(15)
              .margin({ right: 8 })

            Text(video.author.nickname)
              .fontSize(14)
              .fontColor(this.TEXT_SECONDARY)
          }
          .layoutWeight(1)

          Row() {
            Image($r('app.media.ic_bus'))
              .width(16)
              .height(16)
              .fillColor(this.TEXT_MUTED)
              .margin({ right: 4 })

            Text(`${video.views}次播放`)
              .fontSize(12)
              .fontColor(this.TEXT_MUTED)
              .margin({ right: 12 })

            Image($r('app.media.ic_message'))
              .width(16)
              .height(16)
              .fillColor(this.TEXT_MUTED)
              .margin({ right: 4 })

            Text(video.comments.toString())
              .fontSize(12)
              .fontColor(this.TEXT_MUTED)
          }
        }
        .alignItems(VerticalAlign.Center)
      }
      .padding(12)
      .backgroundColor(Color.White)
    }
    .margin({ bottom: 12 })
    .backgroundColor(Color.White)
    .borderRadius(8)
    .width('100%')
  }

  // 名胜景点内容
  @Builder
  ScenicSpotsContent() {
    Column() {
      this.ScenicSearchBar()
      this.ScenicCategories()

      Scroll() {
        Column() {
          Text('名胜 推荐')
            .fontSize(18)
            .fontWeight(FontWeight.Medium)
            .fontColor(this.TEXT_PRIMARY)
            .margin({ top: 16, left: 16, bottom: 12 })
            .width('100%')

          // 分组显示景点（不在 @Builder 内声明变量）
          ForEach(this.chunkScenicSpots(DataManager.scenicSpots, 3), (chunk: ScenicSpot[], idx: number) => {
            Row() {
              ForEach(chunk, (spot: ScenicSpot) => {
                this.ScenicSpotCard(spot)
              }, (spot: ScenicSpot) => spot.id)
            }
            .width('100%')
            .padding({ left: 16, right: 16 })
            .justifyContent(FlexAlign.SpaceBetween)
            .margin({ bottom: 16 })

            if (idx < this.chunkScenicSpots(DataManager.scenicSpots, 3).length - 1) {
              Divider()
                .color('#EEEEEE')
                .margin({ left: 16, right: 16, bottom: 16 })
            }
          }, (chunk: ScenicSpot[], idx: number) => idx.toString())
        }
      }
      .layoutWeight(1)
    }
  }

  // 名胜景点搜索栏
  @Builder
  ScenicSearchBar() {
    Row() {
      Row() {
        Image($r('app.media.ic_search'))
          .width(20)
          .height(20)
          .margin({ left: 12, right: 8 })
          .fillColor(this.TEXT_MUTED)

        TextInput({ placeholder: '搜索景点/目的地', text: this.scenicSearchText })
          .placeholderColor(this.TEXT_MUTED)
          .placeholderFont({ size: 16, weight: FontWeight.Normal })
          .height(40)
          .backgroundColor(Color.Transparent)
          .layoutWeight(1)
          .onChange((value: string) => {
            this.scenicSearchText = value;
          })
          .onSubmit((enterKey, event) => this.triggerScenicSearch())
      }
      .height(40)
      .backgroundColor(Color.White)
      .borderRadius(20)
      .layoutWeight(1)
      .margin({ right: 12 })

      Image($r('app.media.ic_culture'))
        .width(24)
        .height(24)
    }
    .padding({ left: 16, right: 16, top: 12, bottom: 12 })
    .backgroundColor(this.BG_LIGHT)
    .width('100%')
  }

  // 分类筛选
  @Builder
  ScenicCategories() {
    Scroll() {
      Row() {
        this.CategoryChip('全部', this.scenicCategory === 'all')
        this.CategoryChip('自然风光', this.scenicCategory === 'nature')
        this.CategoryChip('历史古迹', this.scenicCategory === 'history')
        this.CategoryChip('主题公园', this.scenicCategory === 'park')
        this.CategoryChip('博物馆', this.scenicCategory === 'museum')
        this.CategoryChip('宗教场所', this.scenicCategory === 'religion')
      }
      .padding({ left: 16, right: 16 })
    }
    .scrollable(ScrollDirection.Horizontal)
    .height(48)
    .backgroundColor(Color.White)
    .width('100%')
  }

  // 分类标签
  @Builder
  CategoryChip(name: string, isSelected: boolean) {
    Text(name)
      .fontSize(14)
      .fontColor(isSelected ? this.PRIMARY_COLOR : this.TEXT_SECONDARY)
      .backgroundColor(isSelected ? '#E3F2FD' : this.BG_LIGHT)
      .borderRadius(16)
      .padding({ left: 16, right: 16, top: 8, bottom: 8 })
      .margin({ right: 12 })
      .onClick(() => {
        this.scenicCategory = name === '全部' ? 'all' :
          name === '自然风光' ? 'nature' :
            name === '历史古迹' ? 'history' :
              name === '主题公园' ? 'park' :
                name === '博物馆' ? 'museum' : 'religion';
        this.triggerScenicSearch();
      })
  }

  // 景点卡片组件
  @Builder
  ScenicSpotCard(spot: ScenicSpot) {
    Column() {
      Stack() {
        Image(spot.images.length > 0 ? $r(spot.images[0]) : $r('app.media.banner_hot_spring'))
          .width(100)
          .height(100)
          .objectFit(ImageFit.Cover)
          .borderRadius(8)

        Row() {
          ForEach(Array(5).fill(0), (item: number, index: number) => {
            if (index < spot.heatLevel) {
              Image($r('app.media.ic_video'))
                .width(12)
                .height(12)
                .margin({ right: 2 })
            } else {
              Image($r('app.media.ic_video1'))
                .width(12)
                .height(12)
                .margin({ right: 2 })
            }
          }, (item: number, index: number) => index.toString())
        }
        .position({ x: 5, y: 5 })
        .backgroundColor('rgba(0, 0, 0, 0.4)')
        .padding({ left: 4, right: 4, top: 2, bottom: 2 })
        .borderRadius(10)
      }

      Text(spot.name)
        .fontSize(14)
        .fontWeight(FontWeight.Medium)
        .fontColor(this.TEXT_PRIMARY)
        .margin({ top: 8 })
        .maxLines(1)
        .textOverflow({ overflow: TextOverflow.Ellipsis })
        .width(100)

      Text(spot.location)
        .fontSize(12)
        .fontColor(this.TEXT_SECONDARY)
        .margin({ top: 4 })
        .maxLines(1)
        .textOverflow({ overflow: TextOverflow.Ellipsis })
        .width(100)
    }
    .onClick(() => {
      router.pushUrl({ url: `pages/ScenicDetailPage?id=${spot.id}` });
    })
  }

  // 视频推荐内容
  @Builder
  VideoRecommendContent() {
    this.VideoListContent()
  }

  // 消息页面内容
  @Builder
  MessageContent() {
    Column() {
      this.ChatHeader()

      if (this.isLoadingMessages) {
        Column() {
          LoadingProgress()
          Text('加载中...')
            .fontSize(12)
            .fontColor(this.TEXT_MUTED)
            .margin({ top: 8 })
        }
        .height('80%')
        .justifyContent(FlexAlign.Center)
        .alignItems(HorizontalAlign.Center)
      } else if (this.messageError) {
        Column() {
          Text(this.messageError)
            .fontSize(14)
            .fontColor('#F44336')
            .margin({ bottom: 8 })
          Button('重试')
            .backgroundColor(this.PRIMARY_COLOR)
            .fontColor(Color.White)
            .borderRadius(8)
            .padding(10)
            .onClick(() => this.reloadConversations())
        }
        .height('80%')
        .justifyContent(FlexAlign.Center)
        .alignItems(HorizontalAlign.Center)
      } else if (DataManager.messages.length === 0) {
        this.ChatEmpty()
      } else {
        List() {
          ForEach(DataManager.messages, (m: Message) => {
            ListItem() {
              this.ChatMessageCard(m)
            }
            .margin({ left: 16, right: 16, top: 8, bottom: 8 })
            .onClick(async () => {
              try {
                if (m.id) {
                  await ApiService.readMessage(m.id);
                  m.badgeCount = 0;
                }
              } catch (e) {
                console.warn('readMessage failed: ' + JSON.stringify(e));
              }
              const peerId: string = m.senderId || '';
              const peerName: string = m.title || '会话';
              const peerAvatar: string = m.senderAvatar || 'app.media.banner_hot_spring';
              router.pushUrl({ url: `pages/ChatDetailPage?peerId=${encodeURIComponent(peerId)}&peerName=${encodeURIComponent(peerName)}&peerAvatar=${encodeURIComponent(peerAvatar)}` });
            })
          }, (m: Message) => m.id)
        }
        .edgeEffect(EdgeEffect.None)
      }
    }
    .width('100%')
    .backgroundColor(this.BG_LIGHT)
  }

  @Builder
  ChatHeader() {
    Row() {
      Image($r('app.media.ic_message1'))
        .width(22)
        .height(22)
        .margin({ right: 8 })
      Text('消息中心')
        .fontSize(20)
        .fontWeight(FontWeight.Medium)
      Blank()
      if (this.isLoadingMessages) {
        LoadingProgress()
      } else {
        Text('刷新')
          .fontSize(14)
          .fontColor(this.PRIMARY_COLOR)
          .onClick(() => this.reloadConversations())
      }
    }
    .padding({ left: 16, right: 16, top: 12, bottom: 12 })
    .width('100%')
    .backgroundColor(Color.White)
  }

  @Builder
  ChatEmpty() {
    Column() {
      Image($r('app.media.ic_message1'))
        .width(80)
        .height(80)
        .margin({ bottom: 12 })
      Text('暂无消息')
        .fontSize(14)
        .fontColor(this.TEXT_MUTED)
    }
    .width('100%')
    .height('70%')
    .justifyContent(FlexAlign.Center)
    .alignItems(HorizontalAlign.Center)
  }

  @Builder
  ChatMessageCard(item: Message) {
    Column() {
      Row() {
        Image(item.senderAvatar && item.senderAvatar.length > 0 ? item.senderAvatar : $r('app.media.app_icon'))
          .width(42)
          .height(42)
          .borderRadius(21)
          .objectFit(ImageFit.Cover)
          .margin({ right: 12 })

        Column() {
          Row() {
            Text(item.title || '系统消息')
              .fontSize(16)
              .fontWeight(FontWeight.Medium)
              .maxLines(1)
              .textOverflow({ overflow: TextOverflow.Ellipsis })
            Blank()
            Text(item.time || '')
              .fontSize(12)
              .fontColor(this.TEXT_MUTED)
          }

          Text(item.content || '')
            .fontSize(14)
            .fontColor(this.TEXT_SECONDARY)
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

  // 我的页面内容
  @Builder
  ProfileContent() {
    Scroll() {
      Column() {
        Column() {
          Row() {
            Image($r(DataManager.userInfo.avatar))
              .width(60)
              .height(60)
              .borderRadius(30)
              .margin({ right: 12 })
            Column() {
              Row() {
                Text(DataManager.userInfo.nickname)
                  .fontSize(18)
                  .fontWeight(FontWeight.Medium)
                  .fontColor(this.TEXT_PRIMARY)

                Text(`Lv.${DataManager.userInfo.level}`)
                  .fontSize(12)
                  .fontColor('#FF9800')
                  .backgroundColor('#FFF3E0')
                  .borderRadius(4)
                  .padding({ left: 6, right: 6, top: 2, bottom: 2 })
                  .margin({ left: 8 })
              }

              Row() {
                Text(DataManager.userInfo.gender === 'male' ? '男' : '女')
                  .fontSize(14)
                  .fontColor(this.TEXT_SECONDARY)
                  .margin({ right: 20 })

                Text('个人主页 >')
                  .fontSize(14)
                  .fontColor(this.PRIMARY_COLOR)
              }
              .margin({ top: 6 })
            }
            .height(60)
          }

          Divider()
            .color('#EEEEEE')
            .margin({ top: 15, bottom: 15 })

          Column() {
            Text(`优惠券：${DataManager.userInfo.couponCount}张`)
              .fontSize(14)
              .fontColor(this.TEXT_PRIMARY)
              .margin({ bottom: 4 })

            Text(`金币：${DataManager.userInfo.coinCount.toLocaleString()}个`)
              .fontSize(14)
              .fontColor(this.TEXT_PRIMARY)
              .fontWeight(FontWeight.Medium)
          }

          Divider()
            .color('#EEEEEE')
            .margin({ top: 15, bottom: 15 })
        }
        .padding(20)
        .backgroundColor(Color.White)
        .margin({ top: 10 })

        Column() {
          Text('我的门票')
            .fontSize(16)
            .fontWeight(FontWeight.Medium)
            .fontColor(this.TEXT_PRIMARY)
            .margin({ bottom: 15 })

          Grid() {
            this.ProfileGridItem('全部门票', DataManager.hotelOrders.length.toString(), this.PRIMARY_COLOR)
            this.ProfileGridItem('待付款', DataManager.hotelOrders.filter(order => order.status === 'pending').length.toString(), this.TEXT_PRIMARY)
            this.ProfileGridItem('未使用', DataManager.hotelOrders.filter(order => order.status === 'unused').length.toString(), this.TEXT_PRIMARY)
            this.ProfileGridItem('待评价', '0', this.TEXT_PRIMARY)
          }
          .columnsTemplate('1fr 1fr 1fr 1fr')
          .rowsGap(10)
          .columnsGap(10)
        }
        .padding(20)
        .backgroundColor(Color.White)
        .margin({ top: 10 })

        Column() {
          Text('基础服务')
            .fontSize(16)
            .fontWeight(FontWeight.Medium)
            .fontColor(this.TEXT_PRIMARY)
            .margin({ bottom: 15 })

          Grid() {
            this.ServiceItem('我要发布', $r('app.media.ic_map'))
            this.ServiceItem('酒店订单', $r('app.media.ic_hotel'))
            this.ServiceItem('我的机票', $r('app.media.ic_plane'))
            this.ServiceItem('我的车票', $r('app.media.ic_bus'))
            this.ServiceItem('我的金币', $r('app.media.ic_culture'))
            this.ServiceItem('我的收藏', $r('app.media.ic_parent_child'))
            this.ServiceItem('联系客服', $r('app.media.ic_hot_spring'))
            this.ServiceItem('意见反馈', $r('app.media.ic_surrounding'))
          }
          .columnsTemplate('1fr 1fr 1fr 1fr')
          .rowsGap(15)
          .columnsGap(10)
        }
        .padding(20)
        .backgroundColor(Color.White)
        .margin({ top: 10, bottom: 20 })

        Blank()
          .height(60)
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor(this.BG_LIGHT)
  }

  @Builder
  ProfileGridItem(title: string, value: string, color: string) {
    GridItem() {
      Column() {
        Text(title)
          .fontSize(14)
          .fontColor(color)
        Text(value)
          .fontSize(12)
          .fontColor(this.TEXT_MUTED)
          .margin({ top: 4 })
      }
      .width('100%')
      .height(60)
      .justifyContent(FlexAlign.Center)
    }
  }

  @Builder
  ServiceItem(name: string, icon: Resource) {
    GridItem() {
      Column() {
        Image(icon)
          .width(24)
          .height(24)
          .fillColor(this.PRIMARY_COLOR)
          .margin({ bottom: 8 })
        Text(name)
          .fontSize(12)
          .fontColor(this.TEXT_PRIMARY)
          .maxLines(1)
          .textOverflow({ overflow: TextOverflow.Ellipsis })
      }
      .width('100%')
      .height(70)
      .justifyContent(FlexAlign.Center)
      .onClick(() => {
        if (name === '我要发布') {
          router.pushUrl({ url: 'pages/TravelPostPage' });
        } else if (name === '酒店订单') {
          router.pushUrl({ url: 'pages/HotelOrderPage' });
        } else if (name === '意见反馈') {
          router.pushUrl({ url: 'pages/FeedbackPage' });
        }
      })
    }
  }
}
