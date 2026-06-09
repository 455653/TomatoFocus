import { TaskModel } from '../database/DBHelper';

@CustomDialog
export struct AddEditTaskDialog {
  controller: CustomDialogController;
  task?: TaskModel;
  onConfirm?: (title: string, taskType: string, priority: number, startDate: number, endDate: number) => void;

  @State title: string = '';
  @State taskType: string = 'habit';
  @State priority: number = 0;
  @State startDate: number = Date.now();
  @State endDate: number = Date.now() + 7 * 24 * 60 * 60 * 1000;
  @State titleError: string = '';

  private priorityColors: string[] = ['#95A5A6', '#3498DB', '#F39C12', '#E74C3C'];
  private priorityLabels: string[] = ['低', '中', '较高', '高'];

  aboutToAppear(): void {
    if (this.task) {
      this.title = this.task.title;
      this.taskType = this.task.taskType;
      this.priority = this.task.priority;
      this.startDate = this.task.startDate ?? Date.now();
      this.endDate = this.task.endDate ?? (Date.now() + 7 * 24 * 60 * 60 * 1000);
    }
  }

  build() {
    Column() {
      // ---- Title (fixed at top) ----
      Text(this.task ? '编辑任务' : '新增任务')
        .fontSize(18)
        .fontWeight(FontWeight.Bold)
        .fontColor('#333333')
        .margin({ top: 24, bottom: 20 });

      // ---- Scrollable content ----
      Scroll() {
        Column() {
          // ---- Task name ----
          TextInput({ placeholder: '任务名称 *', text: this.title })
            .fontSize(15)
            .height(44)
            .backgroundColor('#F5F5F5')
            .borderRadius(8)
            .padding({ left: 12, right: 12 })
            .margin({ bottom: 4 })
            .onChange((value: string) => {
              this.title = value;
              if (value.trim().length > 0) {
                this.titleError = '';
              }
            });

          if (this.titleError) {
            Text(this.titleError)
              .fontSize(12)
              .fontColor('#E74C3C')
              .margin({ bottom: 8 })
              .alignSelf(ItemAlign.Start);
          }

          // ---- Task type ----
          Text('任务类型')
            .fontSize(14)
            .fontColor('#666666')
            .margin({ top: 12, bottom: 8 })
            .alignSelf(ItemAlign.Start);

          Row() {
            Row() {
              Radio({ value: 'habit', group: 'taskTypeGroup' })
                .checked(this.taskType === 'habit')
                .width(20)
                .height(20)
                .onChange((isChecked: boolean) => {
                  if (isChecked) {
                    this.taskType = 'habit';
                  }
                });
              Text('习惯性任务')
                .fontSize(14)
                .fontColor('#333333')
                .margin({ left: 6 });
            }
            .margin({ right: 28 })
            .onClick(() => {
              this.taskType = 'habit';
            });

            Row() {
              Radio({ value: 'phase', group: 'taskTypeGroup' })
                .checked(this.taskType === 'phase')
                .width(20)
                .height(20)
                .onChange((isChecked: boolean) => {
                  if (isChecked) {
                    this.taskType = 'phase';
                  }
                });
              Text('阶段性任务')
                .fontSize(14)
                .fontColor('#333333')
                .margin({ left: 6 });
            }
            .onClick(() => {
              this.taskType = 'phase';
            });
          }
          .width('100%')
          .margin({ bottom: 16 });

          // ---- Priority ----
          Text('优先级')
            .fontSize(14)
            .fontColor('#666666')
            .margin({ bottom: 8 })
            .alignSelf(ItemAlign.Start);

          Row() {
            ForEach(this.priorityLabels, (label: string, index: number) => {
              Button(label)
                .fontSize(13)
                .height(36)
                .layoutWeight(1)
                .backgroundColor(this.priority === index ? this.priorityColors[index] : '#F0F0F0')
                .fontColor(this.priority === index ? Color.White : '#666666')
                .borderRadius(18)
                .margin({ right: index < 3 ? 8 : 0 })
                .onClick(() => {
                  this.priority = index;
                });
            });
          }
          .width('100%')
          .margin({ bottom: 16 });

          // ---- Date pickers (only for phase tasks) ----
          if (this.taskType === 'phase') {
            Text('开始日期')
              .fontSize(14)
              .fontColor('#666666')
              .margin({ bottom: 6 })
              .alignSelf(ItemAlign.Start);

            DatePicker({
              start: new Date(2024, 0, 1),
              end: new Date(2030, 11, 31),
              selected: new Date(this.startDate)
            })
              .margin({ bottom: 12 })
              .onChange((value: DatePickerResult) => {
                const y = value.year ?? 2025;
                const m = value.month ?? 0;
                const d = value.day ?? 1;
                this.startDate = new Date(y, m, d).getTime();
              });

            Text('结束日期')
              .fontSize(14)
              .fontColor('#666666')
              .margin({ bottom: 6 })
              .alignSelf(ItemAlign.Start);

            DatePicker({
              start: new Date(2024, 0, 1),
              end: new Date(2030, 11, 31),
              selected: new Date(this.endDate)
            })
              .margin({ bottom: 12 })
              .onChange((value: DatePickerResult) => {
                const y = value.year ?? 2025;
                const m = value.month ?? 0;
                const d = value.day ?? 1;
                this.endDate = new Date(y, m, d).getTime();
              });
          }

          // ---- Buttons (inside Scroll so they're reachable) ----
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
                const trimmed = this.title.trim();
                if (trimmed.length === 0) {
                  this.titleError = '请输入任务名称';
                  return;
                }
                this.onConfirm?.(
                  trimmed,
                  this.taskType,
                  this.priority,
                  this.taskType === 'phase' ? this.startDate : 0,
                  this.taskType === 'phase' ? this.endDate : 0
                );
                this.controller.close();
              });
          }
          .width('100%')
          .margin({ top: 16 });
        }
        .width('100%');
      }
      .scrollBar(BarState.Off)
      .width('100%')
      .layoutWeight(1);
    }
    .width('100%')
    .height('80%')
    .padding({ left: 24, right: 24, bottom: 24 });
  }
}
