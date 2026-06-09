import { TaskModel } from '../database/DBHelper';

@Component
export struct TaskItem {
  @Prop task: TaskModel;
  onEdit?: () => void;
  onDelete?: () => void;

  private priorityColors: string[] = ['#95A5A6', '#3498DB', '#F39C12', '#E74C3C'];
  private priorityLabels: string[] = ['低', '中', '较高', '高'];

  build() {
    Row() {
      // ---- Priority color bar ----
      Row()
        .width(4)
        .height('100%')
        .backgroundColor(this.priorityColors[this.task.priority] ?? '#95A5A6')
        .borderRadius(2);

      // ---- Content ----
      Column() {
        Row() {
          Text(this.task.title)
            .fontSize(15)
            .fontWeight(FontWeight.Medium)
            .fontColor(this.task.isCompleted ? '#999999' : '#333333')
            .decoration({
              type: this.task.isCompleted ? TextDecorationType.LineThrough : TextDecorationType.None
            });

          Blank()
            .width(8);

          // Task type badge
          Text(this.task.taskType === 'habit' ? '习惯' : '阶段')
            .fontSize(10)
            .fontColor(Color.White)
            .backgroundColor(this.task.taskType === 'habit' ? '#3498DB' : '#F39C12')
            .borderRadius(4)
            .padding({ left: 6, right: 6, top: 2, bottom: 2 });
        };

        // Date range for phase tasks
        if (this.task.taskType === 'phase' && this.task.startDate && this.task.endDate) {
          Text(this.formatDateRange(this.task.startDate, this.task.endDate))
            .fontSize(11)
            .fontColor('#999999')
            .margin({ top: 4 });
        }

        // Priority label
        Text(`优先级：${this.priorityLabels[this.task.priority] ?? '低'}`)
          .fontSize(11)
          .fontColor('#AAAAAA')
          .margin({ top: 4 });
      }
      .layoutWeight(1)
      .alignItems(HorizontalAlign.Start)
      .margin({ left: 10 });

      // ---- Action buttons ----
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
    .padding({ left: 12, right: 8, top: 12, bottom: 12 })
    .backgroundColor(Color.White)
    .borderRadius(8)
    .margin({ bottom: 8 });
  }

  private formatDateRange(startDate: number, endDate: number): string {
    const start = new Date(startDate);
    const end = new Date(endDate);
    const fmt = (d: Date): string =>
      `${d.getFullYear()}-${String(d.getMonth() + 1).padStart(2, '0')}-${String(d.getDate()).padStart(2, '0')}`;
    return `${fmt(start)} ~ ${fmt(end)}`;
  }
}
