import { CollectionModel } from '../database/DBHelper';

@CustomDialog
export struct AddEditCollectionDialog {
  controller: CustomDialogController;
  collection?: CollectionModel;
  onConfirm?: (name: string, description: string, color: string, icon: string) => void;

  @State name: string = '';
  @State description: string = '';
  @State selectedColor: string = '#E74C3C';
  @State selectedIcon: string = '📚';
  @State nameError: string = '';

  private colors: string[] = [
    '#E74C3C', '#E67E22', '#F1C40F', '#2ECC71',
    '#3498DB', '#9B59B6', '#1ABC9C', '#95A5A6'
  ];
  private icons: string[] = ['📚', '💻', '🏋️', '🎯', '💡', '🔍'];

  aboutToAppear(): void {
    if (this.collection) {
      this.name = this.collection.name;
      this.description = this.collection.description ?? '';
      this.selectedColor = this.collection.color || '#E74C3C';
      this.selectedIcon = this.collection.icon || '📚';
    }
  }

  build() {
    Column() {
      // ---- Title ----
      Text(this.collection ? '编辑合集' : '新增合集')
        .fontSize(18)
        .fontWeight(FontWeight.Bold)
        .fontColor('#333333')
        .margin({ top: 24, bottom: 20 });

      // ---- Name ----
      TextInput({ placeholder: '合集名称 *', text: this.name })
        .fontSize(15)
        .height(44)
        .backgroundColor('#F5F5F5')
        .borderRadius(8)
        .padding({ left: 12, right: 12 })
        .margin({ bottom: 4 })
        .onChange((value: string) => {
          this.name = value;
          if (value.trim().length > 0) {
            this.nameError = '';
          }
        });

      if (this.nameError) {
        Text(this.nameError)
          .fontSize(12)
          .fontColor('#E74C3C')
          .margin({ bottom: 8 })
          .alignSelf(ItemAlign.Start);
      }

      // ---- Description ----
      TextArea({ placeholder: '描述（可选）', text: this.description })
        .fontSize(14)
        .height(70)
        .backgroundColor('#F5F5F5')
        .borderRadius(8)
        .padding({ left: 12, right: 12, top: 8, bottom: 8 })
        .margin({ bottom: 16 })
        .onChange((value: string) => {
          this.description = value;
        });

      // ---- Color picker ----
      Text('主题色')
        .fontSize(14)
        .fontColor('#666666')
        .margin({ bottom: 8 })
        .alignSelf(ItemAlign.Start);

      Row() {
        ForEach(this.colors, (color: string) => {
          Row()
            .width(32)
            .height(32)
            .backgroundColor(color)
            .borderRadius(16)
            .margin({ right: 10 })
            .border({
              width: this.selectedColor === color ? 3 : 0,
              color: '#333333'
            })
            .onClick(() => {
              this.selectedColor = color;
            });
        });
      }
      .width('100%')
      .margin({ bottom: 16 });

      // ---- Icon picker ----
      Text('图标')
        .fontSize(14)
        .fontColor('#666666')
        .margin({ bottom: 8 })
        .alignSelf(ItemAlign.Start);

      Row() {
        ForEach(this.icons, (icon: string) => {
          Text(icon)
            .fontSize(28)
            .margin({ right: 16 })
            .opacity(this.selectedIcon === icon ? 1.0 : 0.35)
            .scale({ x: this.selectedIcon === icon ? 1.2 : 1.0, y: this.selectedIcon === icon ? 1.2 : 1.0 })
            .animation({ duration: 200 })
            .onClick(() => {
              this.selectedIcon = icon;
            });
        });
      }
      .width('100%')
      .margin({ bottom: 24 });

      // ---- Buttons ----
      Row() {
        Button('取消')
          .fontSize(15)
          .layoutWeight(1)
          .height(44)
          .backgroundColor('#F0F0F0')
          .fontColor('#666666')
          .borderRadius(22)
          .onClick(() => {
            this.controller.close();
          });

        Blank().width(12);

        Button('确认')
          .fontSize(15)
          .layoutWeight(1)
          .height(44)
          .backgroundColor('#E74C3C')
          .fontColor(Color.White)
          .borderRadius(22)
          .onClick(() => {
            const trimmed = this.name.trim();
            if (trimmed.length === 0) {
              this.nameError = '请输入合集名称';
              return;
            }
            this.onConfirm?.(trimmed, this.description.trim(), this.selectedColor, this.selectedIcon);
            this.controller.close();
          });
      }
      .width('100%');
    }
    .width('100%')
    .padding({ left: 24, right: 24, bottom: 24 });
  }
}
