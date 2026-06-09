import { router } from '@kit.ArkUI';
import { promptAction } from '@kit.ArkUI';
import { DBHelper } from '../database/DBHelper';
import { md5 } from '../utils/CryptoUtil';

@Entry
@Component
struct RegisterPage {
  @State username: string = '';
  @State password: string = '';
  @State confirmPassword: string = '';
  @State isLoading: boolean = false;

  build() {
    Scroll() {
      Column() {
        // ---- Title ----
        Text('创建账号')
          .fontSize(28)
          .fontWeight(FontWeight.Bold)
          .fontColor('#E74C3C')
          .margin({ top: 48, bottom: 8 });

        Text('注册一个番茄专注账号')
          .fontSize(14)
          .fontColor('#999999')
          .margin({ bottom: 36 });

        // ---- Form Card ----
        Column() {
          // Username
          TextInput({ placeholder: '请输入用户名（2-20个字符）' })
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

          // Password
          TextInput({ placeholder: '请输入密码（6-20个字符）' })
            .fontSize(16)
            .height(52)
            .backgroundColor(Color.White)
            .borderRadius(12)
            .padding({ left: 16, right: 16 })
            .type(InputType.Password)
            .showPasswordIcon(true)
            .onChange((value: string) => {
              this.password = value;
            });

          Divider()
            .color('#E8E8E8')
            .width('88%');

          // Confirm Password
          TextInput({ placeholder: '请再次输入密码' })
            .fontSize(16)
            .height(52)
            .backgroundColor(Color.White)
            .borderRadius(12)
            .padding({ left: 16, right: 16 })
            .type(InputType.Password)
            .showPasswordIcon(true)
            .onChange((value: string) => {
              this.confirmPassword = value;
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

        // ---- Register Button ----
        Button(this.isLoading ? '注册中...' : '注册')
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
            this.handleRegister();
          });

        // ---- Login Link ----
        Row() {
          Text('已有账号？')
            .fontSize(14)
            .fontColor('#999999');

          Text('去登录')
            .fontSize(14)
            .fontColor('#E74C3C')
            .fontWeight(FontWeight.Medium)
            .margin({ left: 4 });
        }
        .onClick(() => {
          router.back();
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
   * Validates input and attempts registration.
   */
  private async handleRegister(): Promise<void> {
    const trimmedUsername = this.username.trim();

    // Validate username
    if (trimmedUsername.length < 2 || trimmedUsername.length > 20) {
      promptAction.showToast({ message: '用户名长度应为 2-20 个字符', duration: 2000 });
      return;
    }

    // Validate password
    if (this.password.length < 6 || this.password.length > 20) {
      promptAction.showToast({ message: '密码长度应为 6-20 个字符', duration: 2000 });
      return;
    }

    // Validate confirm password
    if (this.password !== this.confirmPassword) {
      promptAction.showToast({ message: '两次输入的密码不一致', duration: 2000 });
      return;
    }

    this.isLoading = true;

    try {
      const userId = await DBHelper.getInstance().insertUser(trimmedUsername, md5(this.password));

      if (userId > 0) {
        promptAction.showToast({ message: '注册成功，请登录', duration: 2000 });
        router.back();
      } else {
        promptAction.showToast({ message: '注册失败，请稍后重试', duration: 2000 });
      }
    } catch (err) {
      // Check for duplicate username error (UNIQUE constraint)
      const errMsg = String(err);
      if (errMsg.includes('UNIQUE') || errMsg.includes('unique')) {
        promptAction.showToast({ message: '用户名已被使用', duration: 2000 });
      } else {
        promptAction.showToast({ message: '注册失败，请稍后重试', duration: 2000 });
      }
    } finally {
      this.isLoading = false;
    }
  }
}
