@Entry
@Component
struct TravelHomePage {
  // 当前选中的页面索引
  @State currentIndex: number = 0;
  // 消息数据
  private messages: MessageItem[] = [
    {
      type: 'order',
      title: '订单消息',
      content: '你的订单已完结',
      time: '3分钟前',
      badgeCount: 0,
      isOfficial: false
    },
    {
      type: 'interaction',
      title: '互动消息',
      content: '@用户1008600评论了你的内容',
      time: '5小时前',
      badgeCount: 0,
      isOfficial: false
    },
    {
      type: 'system',
      title: '系统消息',
      content: '你提交的个人信息审核通过',
      time: '23小时前',
      badgeCount: 0,
      isOfficial: true
    },
    {
      type: 'private',
      title: '果汁分你一半',
      content: '[游记消息]',
      time: '2天前',
      badgeCount: 1,
      isOfficial: false
    },
    {
      type: 'private',
      title: '飞来 飞去',
      content: '老炮来北京玩啊~',
      time: '1周前',
      badgeCount: 0,
      isOfficial: false
    }
  ]


  // 热门搜索标签数据
  private hotTags: string[] = ['北京', '故宫', '天安门', '温泉', '世界杯', '景山公园']

  // 功能导航数据
  private features: FeatureItem[] = [
    { icon: $r('app.media.ic_parent_child'), name: '亲子游', color: '#4CAF50' },
    { icon: $r('app.media.ic_culture'), name: '文化游', color: '#2196F3' },
    { icon: $r('app.media.ic_hot_spring'), name: '温泉游', color: '#F44336' },
    { icon: $r('app.media.ic_surrounding'), name: '周边游', color: '#9C27B0' },
    { icon: $r('app.media.ic_map'), name: '旅游地图', color: '#7B1FA2' },
    { icon: $r('app.media.ic_hotel'), name: '酒店民宿', color: '#EF5350' },
    { icon: $r('app.media.ic_bus'), name: '汽车票', color: '#1976D2', badge: '规划中' },
    { icon: $r('app.media.ic_plane'), name: '飞机票', color: '#FF9800', badge: '规划中' }
  ]

  // 推荐内容数据
  private recommendItems: RecommendItem[] = [
    {
      image: $r('app.media.banner_hot_spring'),
      title: '和家人果断在北京续住3天的神仙小院',
      author: '晚风心里吹',
      avatar: $r('app.media.banner_hot_spring'),
      views: '1.9万'
    },
    {
      image: $r('app.media.banner_hot_spring'),
      title: '人少景美"京西小故宫"修缮五年后惊艳开放',
      author: '唐糖唐来了',
      avatar: $r('app.media.banner_hot_spring'),
      views: '1.1万',
      isVideo: true
    }
  ]

  build() {
    // 使用Column作为根布局，通过权重控制内容区域
    Column() {
      // 主内容区域 - 占据除导航栏外的所有空间
      Column() {
        // 根据当前选中的页面显示不同内容
        if (this.currentIndex === 0) {
          // 首页内容
          this.HomeContent()
        } else if (this.currentIndex === 1) {
          // 视频页面
          this.VideoContent()
        } else if (this.currentIndex === 2) {
          // 消息页面
          this.MessageContent()
        } else if (this.currentIndex === 3) {
          // 我的页面
          this.ProfileContent()
        }
      }
      .flexGrow(1) // 占满剩余空间
      .width('100%')

      // 底部导航栏 - 固定在底部
      Row() {
        // 首页
        Column() {
          Image($r('app.media.ic_home'))
            .width(22)
            .height(22)
            .fillColor(this.currentIndex === 0 ? '#2196F3' : '#999')

          Text('首页')
            .fontSize(11)
            .fontColor(this.currentIndex === 0 ? '#2196F3' : '#999')
            .margin({ top: 2 })
        }
        .flexGrow(1)
        .height(45)
        .justifyContent(FlexAlign.Center)
        .onClick(() => {
          this.currentIndex = 0
        })

        // 视频
        Column() {
          Image($r('app.media.ic_video'))
            .width(22)
            .height(22)
            .fillColor(this.currentIndex === 1 ? '#2196F3' : '#999')

          Text('视频')
            .fontSize(11)
            .fontColor(this.currentIndex === 1 ? '#2196F3' : '#999')
            .margin({ top: 2 })
        }
        .flexGrow(1)
        .height(45)
        .justifyContent(FlexAlign.Center)
        .onClick(() => {
          this.currentIndex = 1
        })

        // 消息
        Column() {
          Stack() {
            Image($r('app.media.ic_message'))
              .width(22)
              .height(22)
              .fillColor(this.currentIndex === 2 ? '#2196F3' : '#999')

            Circle()
              .fill('#F44336')
              .width(10)
              .height(10)
              .position({ x: 14, y: -2 })

            Text('1')
              .fontSize(7)
              .fontColor(Color.White)
              .position({ x: 14, y: -2 })
          }

          Text('消息')
            .fontSize(11)
            .fontColor(this.currentIndex === 2 ? '#2196F3' : '#999')
            .margin({ top: 2 })
        }
        .flexGrow(1)
        .height(45)
        .justifyContent(FlexAlign.Center)
        .onClick(() => {
          this.currentIndex = 2
        })

        // 我的
        Column() {
          Image($r('app.media.ic_mine'))
            .width(22)
            .height(22)
            .fillColor(this.currentIndex === 3 ? '#2196F3' : '#999')

          Text('我的')
            .fontSize(11)
            .fontColor(this.currentIndex === 3 ? '#2196F3' : '#999')
            .margin({ top: 2 })
        }
        .flexGrow(1)
        .height(45)
        .justifyContent(FlexAlign.Center)
        .onClick(() => {
          this.currentIndex = 3
        })
      }
      .height(50)
      .backgroundColor(Color.White)
      .borderRadius({ topLeft: 12, topRight: 12 })
      .padding({ top: 4 })
      .width('100%')
      // 使用绝对定位固定在底部
      .alignSelf(ItemAlign.End)
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#F5F5F5')
  }

  // 首页内容
  @Builder
  HomeContent() {
    Column() {
      // 顶部搜索栏
      Column() {
        Row() {
          // 搜索框
          Row() {
            Image($r('app.media.ic_search'))
              .width(20)
              .height(20)
              .margin({ left: 12 })
              .fillColor('#999')

            TextInput({ placeholder: '搜索目的地 / 景点' })
              .height(40)
              .backgroundColor(Color.White)
              .borderRadius(20)
              .padding({ left: 8, right: 8 })
              .flexGrow(1)
          }
          .backgroundColor(Color.White)
          .borderRadius(20)
          .height(40)
          .width('70%')
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
            .width('20%')
        }
        .justifyContent(FlexAlign.SpaceBetween)
        .padding({ left: 15, right: 15, top: 12, bottom: 8 })
        .width('100%')

        // 热门标签
        Column() {
          Flex({ direction: FlexDirection.Row, wrap: FlexWrap.Wrap }) {
            ForEach(this.hotTags, (tag: string) => {
              Text(tag)
                .fontSize(12)
                .backgroundColor('#1976D2')
                .fontColor(Color.White)
                .borderRadius(12)
                .padding({ left: 10, right: 10, top: 4, bottom: 4 })
                .margin({ right: 8, bottom: 8 })
            })
          }
        }
        .padding({ left: 15, right: 15, top: 0, bottom: 12 })
        .width('100%')
      }
      .backgroundColor('#2196F3')
      .width('100%')
      .height('auto')

      // 主内容区
      Scroll() {
        Column() {
          // 功能导航区
          Grid() {
            ForEach(this.features, (item: FeatureItem) => {
              GridItem() {
                Column() {
                  Stack() {
                    Circle()
                      .fill(item.color)
                      .width(45)
                      .height(45)

                    Image(item.icon)
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

                  Text(item.name)
                    .fontSize(12)
                    .margin({ top: 5 })
                    .fontColor('#333')
                    .maxLines(1)
                }
                .justifyContent(FlexAlign.Center)
                .height(90)
              }
            })
          }
          .columnsTemplate('1fr 1fr 1fr 1fr')
          .rowsGap(10)
          .columnsGap(8)
          .padding({ left: 15, right: 15, top: 15 })
          .width('100%')

          // 横幅广告
          Stack() {
            Image($r('app.media.banner_hot_spring'))
              .width('100%')
              .height(100)
              .objectFit(ImageFit.Cover)
              .borderRadius(8)

            Column() {
              Text('冬日温泉')
                .fontSize(20)
                .fontWeight(FontWeight.Bold)
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

          // 内容推荐区
          Column() {
            Row() {
              Image($r('app.media.ic_location'))
                .width(14)
                .height(14)
                .fillColor('#2196F3')

              Text('带你玩遍 北京市')
                .fontSize(14)
                .fontWeight(FontWeight.Medium)
                .fontColor('#2196F3')
                .margin({ left: 4 })
            }
            .padding({ left: 15, right: 15, top: 12, bottom: 8 })

            Row() {
              ForEach(this.recommendItems, (item: RecommendItem) => {
                Column() {
                  Stack() {
                    Image(item.image)
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
                      .fontColor('#333')
                      .margin({ bottom: 6 })
                      .maxLines(2)
                      .textOverflow({ overflow: TextOverflow.Ellipsis })
                      .height(40)

                    Row() {
                      Image(item.avatar)
                        .width(18)
                        .height(18)
                        .borderRadius(9)

                      Text(item.author)
                        .fontSize(11)
                        .fontColor('#999')
                        .margin({ left: 4 })
                        .flexGrow(1)
                        .maxLines(1)

                      Text(item.views)
                        .fontSize(11)
                        .fontColor('#999')
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
              })
            }
            .justifyContent(FlexAlign.SpaceBetween)
            .padding({ left: 15, right: 15 })
          }

          // 添加底部空白区域避免被导航栏遮挡
          Blank()
            .height(60)
        }
        .width('100%')
      }
      .flexGrow(1)
      .backgroundColor('#F5F5F5')
      .margin({ top: 0 })
    }
  }

  // 视频页面内容
  @Builder
  VideoContent() {
    Column() {
      Text('视频页面')
        .fontSize(20)
        .fontWeight(FontWeight.Bold)
        .margin({ top: 100 })
        .width('100%')
        .textAlign(TextAlign.Center)

      // 添加底部空白区域
      Blank()
        .height(60)
    }
    .width('100%')
    .height('100%')
    .justifyContent(FlexAlign.Center)
  }

  // 消息页面内容
  @Builder
  MessageContent() {
    Column() {
      // 消息页面标题
      Text('消息')
        .fontSize(20)
        .fontWeight(FontWeight.Bold)
        .fontColor('#333')
        .padding({ left: 20, top: 15, bottom: 10 })
        .width('100%')
        .backgroundColor(Color.White)

      // 消息列表
      Scroll() {
        Column() {
          ForEach(this.messages, (item: MessageItem, index: number) => {
            Column() {
              // 消息项
              Row() {
                // 头像/图标
                if (item.type === 'order') {
                  Image($r('app.media.ic_bus'))
                    .width(40)
                    .height(40)
                    .borderRadius(20)
                    .backgroundColor('#E3F2FD')
                } else if (item.type === 'interaction') {
                  Image($r('app.media.ic_culture'))
                    .width(40)
                    .height(40)
                    .borderRadius(20)
                    .backgroundColor('#E8F5E8')
                } else if (item.type === 'system') {
                  Image($r('app.media.ic_map'))
                    .width(40)
                    .height(40)
                    .borderRadius(20)
                    .backgroundColor('#FFF3E0')
                } else {
                  Image($r('app.media.banner_hot_spring'))
                    .width(40)
                    .height(40)
                    .borderRadius(20)
                }

                // 消息内容
                Column() {
                  // 标题行
                  Row() {
                    Text(item.title)
                      .fontSize(16)
                      .fontWeight(FontWeight.Medium)
                      .fontColor('#333')
                      .flexGrow(1)

                    if (item.isOfficial) {
                      Text('官方')
                        .fontSize(12)
                        .fontColor('#2196F3')
                        .backgroundColor('#E3F2FD')
                        .borderRadius(4)
                        .padding({ left: 6, right: 6, top: 2, bottom: 2 })
                        .margin({ right: 8 })
                    }

                    Text(item.time)
                      .fontSize(12)
                      .fontColor('#999')
                  }

                  // 内容
                  Text(item.content)
                    .fontSize(14)
                    .fontColor('#666')
                    .margin({ top: 4 })
                    .maxLines(1)
                    .textOverflow({ overflow: TextOverflow.Ellipsis })
                }
                .margin({ left: 12 })
                .flexGrow(1)

                // 未读消息标识
                if (item.badgeCount > 0) {
                  Circle()
                    .fill('#F44336')
                    .width(8)
                    .height(8)
                    .margin({ left: 8 })
                }
              }
              .padding({ left: 16, right: 16, top: 12, bottom: 12 })

              // 分隔线
              if (index < this.messages.length - 1) {
                Divider()
                  .color('#EEEEEE')
                  .margin({ left: 68, right: 16 })
              }
            }
          })

          // 添加底部空白区域
          Blank()
            .height(60)
        }
        .backgroundColor(Color.White)
      }
      .flexGrow(1)
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#F5F5F5')
    .margin({ top: 0 })
  }

  // 我的页面内容
  @Builder
  ProfileContent() {
    Scroll() {
      Column() {
        // 用户信息头部
        Column() {
          // 用户头像和基本信息
          Row() {
            Image($r('app.media.banner_hot_spring'))
              .width(60)
              .height(60)
              .borderRadius(30)
              .margin({ right: 12 })

            Column() {
              Row() {
                Text('晚风心里吹')
                  .fontSize(18)
                  .fontWeight(FontWeight.Bold)
                  .fontColor('#333')

                Text('Lv.1')
                  .fontSize(12)
                  .fontColor('#FF9800')
                  .backgroundColor('#FFF3E0')
                  .borderRadius(4)
                  .padding({ left: 6, right: 6, top: 2, bottom: 2 })
                  .margin({ left: 8 })
              }

              Row() {
                Text('男')
                  .fontSize(14)
                  .fontColor('#666')
                  .margin({ right: 20 })

                Text('个人主页 >')
                  .fontSize(14)
                  .fontColor('#2196F3')
              }
              .margin({ top: 6 })
            }
            .justifyContent(FlexAlign.SpaceBetween)
            .height(60)
          }

          // 分隔线
          Divider()
            .color('#EEEEEE')
            .margin({ top: 15, bottom: 15 })

          // 优惠券和金币
          Row() {
            Column() {
              Text('优惠券：3张')
                .fontSize(14)
                .fontColor('#333')
                .margin({ bottom: 4 })

              Text('金币：30,000个')
                .fontSize(14)
                .fontColor('#333')
                .fontWeight(FontWeight.Medium)
            }
            .flexGrow(1)
          }

          // 分隔线
          Divider()
            .color('#EEEEEE')
            .margin({ top: 15, bottom: 15 })
        }
        .padding(20)
        .backgroundColor(Color.White)
        .margin({ top: 10 })

        // 我的门票区域
        Column() {
          Text('我的门票')
            .fontSize(16)
            .fontWeight(FontWeight.Medium)
            .fontColor('#333')
            .margin({ bottom: 15 })

          Grid() {
            GridItem() {
              Column() {
                Text('全部门票')
                  .fontSize(14)
                  .fontColor('#2196F3')
                Text('0')
                  .fontSize(12)
                  .fontColor('#999')
                  .margin({ top: 4 })
              }
              .width('100%')
              .height(60)
              .justifyContent(FlexAlign.Center)
            }

            GridItem() {
              Column() {
                Text('待付款')
                  .fontSize(14)
                  .fontColor('#333')
                Text('0')
                  .fontSize(12)
                  .fontColor('#999')
                  .margin({ top: 4 })
              }
              .width('100%')
              .height(60)
              .justifyContent(FlexAlign.Center)
            }

            GridItem() {
              Column() {
                Text('未使用')
                  .fontSize(14)
                  .fontColor('#333')
                Text('0')
                  .fontSize(12)
                  .fontColor('#999')
                  .margin({ top: 4 })
              }
              .width('100%')
              .height(60)
              .justifyContent(FlexAlign.Center)
            }

            GridItem() {
              Column() {
                Text('待评价')
                  .fontSize(14)
                  .fontColor('#333')
                Text('0')
                  .fontSize(12)
                  .fontColor('#999')
                  .margin({ top: 4 })
              }
              .width('100%')
              .height(60)
              .justifyContent(FlexAlign.Center)
            }
          }
          .columnsTemplate('1fr 1fr 1fr 1fr')
          .rowsGap(10)
          .columnsGap(10)
        }
        .padding(20)
        .backgroundColor(Color.White)
        .margin({ top: 10 })

        // 基础服务区域
        Column() {
          Text('基础服务')
            .fontSize(16)
            .fontWeight(FontWeight.Medium)
            .fontColor('#333')
            .margin({ bottom: 15 })

          Grid() {
            // 第一行服务
            this.ServiceItem('我要发布', $r('app.media.ic_map'))
            this.ServiceItem('酒店订单', $r('app.media.ic_hotel'))
            this.ServiceItem('我的机票', $r('app.media.ic_plane'))
            this.ServiceItem('我的车票', $r('app.media.ic_bus'))

            // 第二行服务
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

        // 添加底部空白区域避免被导航栏遮挡
        Blank()
          .height(60)
      }
    }
    .width('100%')
    .height('100%')
    .flexGrow(1)
    .backgroundColor('#F5F5F5')
  }

  // 服务项组件
  @Builder
  ServiceItem(name: string, icon: Resource) {
    GridItem() {
      Column() {
        Image(icon)
          .width(24)
          .height(24)
          .fillColor('#2196F3')
          .margin({ bottom: 8 })

        Text(name)
          .fontSize(12)
          .fontColor('#333')
          .maxLines(1)
          .textOverflow({ overflow: TextOverflow.Ellipsis })
      }
      .width('100%')
      .height(70)
      .justifyContent(FlexAlign.Center)
    }
  }
}

interface MessageItem {
  type: 'order' | 'interaction' | 'system' | 'private'
  title: string
  content: string
  time: string
  badgeCount: number
  isOfficial: boolean
}

interface FeatureItem {
  icon: Resource
  name: string
  color: string
  badge?: string
}

interface RecommendItem {
  image: Resource
  title: string
  author: string
  avatar: Resource
  views: string
  isVideo?: boolean
}
