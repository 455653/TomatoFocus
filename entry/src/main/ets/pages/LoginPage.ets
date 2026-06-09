import { router } from '@kit.ArkUI';
import { promptAction } from '@kit.ArkUI';
import { DBHelper } from '../database/DBHelper';
import { md5 } from '../utils/CryptoUtil';
import { UserSession } from '../utils/UserSession';

@Entry
@Component
struct LoginPage {
  @State username: string = '';
  @State password: string = '';
  @State isLoading: boolean = false;

  build() {
    Scroll() {
      Column() {
        // ---- Logo & Title ----
        Text('🍅')
          .fontSize(72)
          .margin({ top: 60, bottom: 8 });

        Text('番茄专注')
          .fontSize(28)
          .fontWeight(FontWeight.Bold)
          .fontColor('#E74C3C')
          .margin({ bottom: 48 });

        // ---- Form Card ----
        Column() {
          TextInput({ placeholder: '请输入用户名' })
            .fontSize(16)
            .height(52)
            .backgroundColor(Color.White)
            .borderRadius(12)
            .padding({ left: 16, right: 16 })
            .margin({ bottom: 1 })
            .type(InputType.Normal)
            .onChange((value: string) => {
              this.username = value;
            });

          Divider()
            .color('#E8E8E8')
            .width('88%');

          TextInput({ placeholder: '请输入密码' })
            .fontSize(16)
            .height(52)
            .backgroundColor(Color.White)
            .borderRadius(12)
            .padding({ left: 16, right: 16 })
            .margin({ top: 1 })
            .type(InputType.Password)
            .showPasswordIcon(true)
            .onChange((value: string) => {
              this.password = value;
            });
        }
        .width('88%')
        .backgroundColor(Color.White)
        .borderRadius(16)
        .shadow({
          radius: 12,
          color: '#10000000',
          offsetX: 0,
          offsetY: 2
        })
        .margin({ bottom: 32 });

        // ---- Login Button ----
        Button(this.isLoading ? '登录中...' : '登录')
          .fontSize(18)
          .fontWeight(FontWeight.Medium)
          .width('88%')
          .height(50)
          .backgroundColor(this.isLoading ? '#E88B7E' : '#E74C3C')
          .borderRadius(25)
          .type(ButtonType.Capsule)
          .enabled(!this.isLoading)
          .shadow({
            radius: 8,
            color: '#40E74C3C',
            offsetX: 0,
            offsetY: 4
          })
          .margin({ bottom: 20 })
          .onClick(() => {
            this.handleLogin();
          });

        // ---- Register Link ----
        Row() {
          Text('还没有账号？')
            .fontSize(14)
            .fontColor('#999999');

          Text('去注册')
            .fontSize(14)
            .fontColor('#E74C3C')
            .fontWeight(FontWeight.Medium)
            .margin({ left: 4 });
        }
        .onClick(() => {
          router.pushUrl({ url: 'pages/RegisterPage' });
        });
      }
      .width('100%')
      .alignItems(HorizontalAlign.Center);
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#FAFAFA')
    .scrollBar(BarState.Off)
    .edgeEffect(EdgeEffect.Spring);
  }

  /**
   * Validates input and attempts login.
   */
  private async handleLogin(): Promise<void> {
    // Input validation
    if (this.username.trim().length === 0) {
      promptAction.showToast({ message: '请输入用户名', duration: 2000 });
      return;
    }
    if (this.password.length === 0) {
      promptAction.showToast({ message: '请输入密码', duration: 2000 });
      return;
    }

    this.isLoading = true;

    try {
      const user = await DBHelper.getInstance().getUserByUsername(this.username.trim());

      if (user === null) {
        promptAction.showToast({ message: '用户名或密码错误', duration: 2000 });
        this.isLoading = false;
        return;
      }

      const inputHash = md5(this.password);
      if (inputHash !== user.passwordMd5) {
        promptAction.showToast({ message: '用户名或密码错误', duration: 2000 });
        this.isLoading = false;
        return;
      }

      // Login success
      UserSession.getInstance().login(user.id, user.username);
      router.replaceUrl({ url: 'pages/MainPage' });
    } catch (err) {
      promptAction.showToast({ message: '登录失败，请稍后重试', duration: 2000 });
    } finally {
      this.isLoading = false;
    }
  }
}
