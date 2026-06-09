import { router } from '@kit.ArkUI';
import { UserSession } from '../utils/UserSession';
import { TaskManagerPage } from './TaskManagerPage';

@Entry
@Component
struct MainPage {
  @State currentIndex: number = 0;

  build() {
    Tabs({ barPosition: BarPosition.End, index: this.currentIndex }) {
      // ==================== Tab 0: 任务管理 ====================
      TabContent() {
        TaskManagerPage()
      }
      .tabBar(this.TabBar0)

      // ==================== Tab 1: 今日待办（开发中） ====================
      TabContent() {
        this.PlaceholderToday
      }
      .tabBar(this.TabBar1)

      // ==================== Tab 2: 专注（开发中） ====================
      TabContent() {
        this.PlaceholderFocus
      }
      .tabBar(this.TabBar2)

      // ==================== Tab 3: 统计（开发中） ====================
      TabContent() {
        this.PlaceholderStats
      }
      .tabBar(this.TabBar3)

      // ==================== Tab 4: 我的 ====================
      TabContent() {
        this.MeTabContent
      }
      .tabBar(this.TabBar4)
    }
    .width('100%')
    .height('100%')
    .barHeight(56)
    .barMode(BarMode.Fixed)
    .vertical(false)
    .scrollable(false)
    .onChange((index: number) => {
      this.currentIndex = index;
    });
  }

  // ==================== Tab Bar Builders (non-parameterized) ====================

  @Builder TabBar0() {
    Column() {
      Text('📋').fontSize(22).margin({ bottom: 2 })
      Text('任务管理').fontSize(10).fontColor(this.currentIndex === 0 ? '#E74C3C' : '#999999')
    }
    .width('100%').height('100%').justifyContent(FlexAlign.Center).alignItems(HorizontalAlign.Center).padding({ top: 4 })
  }

  @Builder TabBar1() {
    Column() {
      Text('📅').fontSize(22).margin({ bottom: 2 })
      Text('今日待办').fontSize(10).fontColor(this.currentIndex === 1 ? '#E74C3C' : '#999999')
    }
    .width('100%').height('100%').justifyContent(FlexAlign.Center).alignItems(HorizontalAlign.Center).padding({ top: 4 })
  }

  @Builder TabBar2() {
    Column() {
      Text('🍅').fontSize(22).margin({ bottom: 2 })
      Text('专注').fontSize(10).fontColor(this.currentIndex === 2 ? '#E74C3C' : '#999999')
    }
    .width('100%').height('100%').justifyContent(FlexAlign.Center).alignItems(HorizontalAlign.Center).padding({ top: 4 })
  }

  @Builder TabBar3() {
    Column() {
      Text('📊').fontSize(22).margin({ bottom: 2 })
      Text('统计').fontSize(10).fontColor(this.currentIndex === 3 ? '#E74C3C' : '#999999')
    }
    .width('100%').height('100%').justifyContent(FlexAlign.Center).alignItems(HorizontalAlign.Center).padding({ top: 4 })
  }

  @Builder TabBar4() {
    Column() {
      Text('👤').fontSize(22).margin({ bottom: 2 })
      Text('我的').fontSize(10).fontColor(this.currentIndex === 4 ? '#E74C3C' : '#999999')
    }
    .width('100%').height('100%').justifyContent(FlexAlign.Center).alignItems(HorizontalAlign.Center).padding({ top: 4 })
  }

  // ==================== Placeholder Builders ====================

  @Builder PlaceholderToday() {
    Column() {
      Text('📅').fontSize(64).margin({ bottom: 16 })
      Text('今日待办').fontSize(20).fontWeight(FontWeight.Medium).fontColor('#333333').margin({ bottom: 8 })
      Text('每日任务规划与执行').fontSize(14).fontColor('#999999')
      Text('开发中，敬请期待')
        .fontSize(12).fontColor('#CCCCCC').margin({ top: 24 })
        .padding({ left: 16, right: 16, top: 6, bottom: 6 })
        .border({ width: 1, color: '#E0E0E0', radius: 12 })
    }
    .width('100%').height('100%').justifyContent(FlexAlign.Center).alignItems(HorizontalAlign.Center).backgroundColor('#FAFAFA')
  }

  @Builder PlaceholderFocus() {
    Column() {
      Text('🍅').fontSize(64).margin({ bottom: 16 })
      Text('专注').fontSize(20).fontWeight(FontWeight.Medium).fontColor('#333333').margin({ bottom: 8 })
      Text('番茄钟计时与专注记录').fontSize(14).fontColor('#999999')
      Text('开发中，敬请期待')
        .fontSize(12).fontColor('#CCCCCC').margin({ top: 24 })
        .padding({ left: 16, right: 16, top: 6, bottom: 6 })
        .border({ width: 1, color: '#E0E0E0', radius: 12 })
    }
    .width('100%').height('100%').justifyContent(FlexAlign.Center).alignItems(HorizontalAlign.Center).backgroundColor('#FAFAFA')
  }

  @Builder PlaceholderStats() {
    Column() {
      Text('📊').fontSize(64).margin({ bottom: 16 })
      Text('统计').fontSize(20).fontWeight(FontWeight.Medium).fontColor('#333333').margin({ bottom: 8 })
      Text('专注时间数据分析').fontSize(14).fontColor('#999999')
      Text('开发中，敬请期待')
        .fontSize(12).fontColor('#CCCCCC').margin({ top: 24 })
        .padding({ left: 16, right: 16, top: 6, bottom: 6 })
        .border({ width: 1, color: '#E0E0E0', radius: 12 })
    }
    .width('100%').height('100%').justifyContent(FlexAlign.Center).alignItems(HorizontalAlign.Center).backgroundColor('#FAFAFA')
  }

  // ==================== "我的" Tab Content ====================

  @Builder MeTabContent() {
    Column() {
      Text('👤').fontSize(72).margin({ top: 80, bottom: 16 })
      Text(UserSession.getInstance().username || '未登录')
        .fontSize(20).fontWeight(FontWeight.Medium).fontColor('#333333').margin({ bottom: 8 })
      Text('番茄专注用户').fontSize(14).fontColor('#999999').margin({ bottom: 48 })

      Button('退出登录')
        .fontSize(16).fontWeight(FontWeight.Medium)
        .width('70%').height(48)
        .backgroundColor('#E74C3C').fontColor(Color.White)
        .borderRadius(24)
        .onClick(() => {
          UserSession.getInstance().logout();
          router.replaceUrl({ url: 'pages/LoginPage' });
        })
    }
    .width('100%').height('100%').alignItems(HorizontalAlign.Center).backgroundColor('#FAFAFA')
  }
}
