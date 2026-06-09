import { router } from '@kit.ArkUI';
import { UserSession } from '../utils/UserSession';

@Entry
@Component
struct MainPage {
  build() {
    Column() {
      Text('番茄专注')
        .fontSize(24)
        .fontWeight(FontWeight.Bold)
        .fontColor('#E74C3C')
        .margin({ top: 100, bottom: 16 });

      Text('欢迎回来！')
        .fontSize(18)
        .fontColor('#666666')
        .margin({ bottom: 8 });

      Text(UserSession.getInstance().username)
        .fontSize(20)
        .fontWeight(FontWeight.Medium)
        .fontColor('#333333')
        .margin({ bottom: 60 });

      Button('退出登录')
        .fontSize(16)
        .width('60%')
        .height(44)
        .backgroundColor('#E74C3C')
        .borderRadius(22)
        .type(ButtonType.Capsule)
        .onClick(() => {
          UserSession.getInstance().logout();
          router.replaceUrl({ url: 'pages/LoginPage' });
        });
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#FAFAFA')
    .alignItems(HorizontalAlign.Center);
  }
}
