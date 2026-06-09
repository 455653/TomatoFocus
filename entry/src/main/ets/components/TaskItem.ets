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
        .width(3)
        .height('100%')
        .backgroundColor(this.priorityColors[this.task.priority] ?? '#95A6A6')
        .borderRadius(1.5);

      // ---- Title (flex, single line with ellipsis) ----
      Text(this.task.title)
        .fontSize(13)
        .fontWeight(FontWeight.Medium)
        .maxLines(1)
        .textOverflow({ overflow: TextOverflow.Ellipsis })
        .fontColor(this.task.isCompleted ? '#999999' : '#333333')
        .decoration({
          type: this.task.isCompleted ? TextDecorationType.LineThrough : TextDecorationType.None
        })
        .layoutWeight(1)
        .margin({ left: 8, right: 6 });

      // ---- Task type badge ----
      Text(this.task.taskType === 'habit' ? '习惯' : '阶段')
        .fontSize(9)
        .fontColor(Color.White)
        .backgroundColor(this.task.taskType === 'habit' ? '#3498DB' : '#F39C12')
        .borderRadius(3)
        .padding({ left: 3, right: 3, top: 1, bottom: 1 });

      // ---- Compact date range for phase tasks ----
      if (this.task.taskType === 'phase' && this.task.startDate && this.task.endDate) {
        Text(this.formatDateRangeCompact(this.task.startDate, this.task.endDate))
          .fontSize(9)
          .fontColor('#AAAAAA')
          .margin({ left: 6 });
      }

      // ---- Priority label ----
      Text(this.priorityLabels[this.task.priority] ?? '低')
        .fontSize(9)
        .fontColor('#AAAAAA')
        .margin({ left: 6, right: 6 });

      // ---- Edit button ----
      Button() {
        Text('✏️').fontSize(10);
      }
      .type(ButtonType.Circle)
      .width(22)
      .height(22)
      .backgroundColor('#F0F0F0')
      .onClick(() => {
        this.onEdit?.();
      });

      // ---- Delete button ----
      Button() {
        Text('🗑️').fontSize(10);
      }
      .type(ButtonType.Circle)
      .width(22)
      .height(22)
      .backgroundColor('#F0F0F0')
      .margin({ left: 4 })
      .onClick(() => {
        this.onDelete?.();
      });
    }
    .width('100%')
    .height(36)
    .padding({ left: 8, right: 6 })
    .backgroundColor(Color.White)
    .borderRadius(6)
    .margin({ bottom: 4 })
    .alignItems(VerticalAlign.Center);
  }

  private formatDateRange(startDate: number, endDate: number): string {
    const start = new Date(startDate);
    const end = new Date(endDate);
    const fmt = (d: Date): string =>
    `${d.getFullYear()}-${String(d.getMonth() + 1).padStart(2, '0')}-${String(d.getDate()).padStart(2, '0')}`;
    return `${fmt(start)} ~ ${fmt(end)}`;
  }

  private formatDateRangeCompact(startDate: number, endDate: number): string {
    const start = new Date(startDate);
    const end = new Date(endDate);
    const fmt = (d: Date): string =>
      `${String(d.getMonth() + 1).padStart(2, '0')}/${String(d.getDate()).padStart(2, '0')}`;
    return `${fmt(start)}~${fmt(end)}`;
  }
}