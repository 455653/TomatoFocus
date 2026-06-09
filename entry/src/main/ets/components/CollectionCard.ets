import { router } from '@kit.ArkUI';

@Component
export struct CollectionCard {
  @Prop collectionId: number = 0;
  @Prop name: string = '';
  @Prop description: string = '';
  @Prop color: string = '#E74C3C';
  @Prop icon: string = '📚';
  @Prop taskCount: number = 0;
  onEdit?: () => void;
  onDelete?: () => void;

  build() {
    Row() {
      // ---- Left color stripe ----
      Row()
        .width(6)
        .height('100%')
        .backgroundColor(this.color || '#E74C3C')
        .borderRadius(3)
        .hitTestBehavior(HitTestMode.None);

      // ---- Center content ----
      Column() {
        Row() {
          Text(this.icon || '📚')
            .fontSize(20);

          Text(this.name)
            .fontSize(16)
            .fontWeight(FontWeight.Medium)
            .fontColor('#333333')
            .margin({ left: 8 });

          Text(`${this.taskCount}个任务`)
            .fontSize(12)
            .fontColor('#999999')
            .margin({ left: 8 });
        }
        .width('100%');

        if (this.description) {
          Text(this.description)
            .fontSize(13)
            .fontColor('#999999')
            .maxLines(1)
            .textOverflow({ overflow: TextOverflow.Ellipsis })
            .margin({ top: 4 });
        }
      }
      .layoutWeight(1)
      .alignItems(HorizontalAlign.Start)
      .margin({ left: 12 })
      .hitTestBehavior(HitTestMode.None);

      // ---- Right action buttons ----
      Row() {
        Button() {
          Text('✏️').fontSize(14);
        }
        .type(ButtonType.Circle)
        .width(32)
        .height(32)
        .backgroundColor('#F0F0F0')
        .onClick(() => {
          this.onEdit?.();
        });

        Button() {
          Text('🗑️').fontSize(14);
        }
        .type(ButtonType.Circle)
        .width(32)
        .height(32)
        .backgroundColor('#F0F0F0')
        .margin({ left: 8 })
        .onClick(() => {
          this.onDelete?.();
        });
      }
    }
    .width('100%')
    .height(72)
    .backgroundColor(Color.White)
    .borderRadius(12)
    .padding({ left: 12, right: 4, top: 12, bottom: 12 })
    .shadow({
      radius: 4,
      color: '#10000000',
      offsetX: 0,
      offsetY: 2
    })
    .margin({ bottom: 12 })
    .onClick(() => {
      router.pushUrl({
        url: 'pages/CollectionDetailPage',
        params: {
          collectionId: this.collectionId,
          collectionName: this.name
        }
      });
    });
  }
}
