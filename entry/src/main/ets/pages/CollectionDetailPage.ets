import { router } from '@kit.ArkUI';
import { promptAction } from '@kit.ArkUI';
import { DBHelper, TaskModel } from '../database/DBHelper';
import { UserSession } from '../utils/UserSession';
import { TaskItem } from '../components/TaskItem';
import { AddEditTaskDialog } from '../components/AddEditTaskDialog';

@Entry
@Component
struct CollectionDetailPage {
  @State collectionId: number = -1;
  @State collectionName: string = '';
  @State tasks: TaskModel[] = [];
  @State isLoading: boolean = true;

  private userId: number = UserSession.getInstance().userId;
  private addEditDialogController: CustomDialogController | null = null;

  aboutToAppear(): void {
    const params = router.getParams() as Record<string, Object>;
    if (params) {
      this.collectionId = (params['collectionId'] as number) || -1;
      this.collectionName = (params['collectionName'] as string) || '';
    }

    if (this.collectionId > 0) {
      this.loadTasks();
    }
  }

  /**
   * Loads all tasks for the current collection, sorted by priority descending.
   */
  private async loadTasks(): Promise<void> {
    try {
      const rawTasks = await DBHelper.getInstance().getTasksByCollection(this.collectionId);
      // Sort by priority descending (high to low), then by updatedAt descending
      this.tasks = rawTasks.sort((a, b) => {
        if (b.priority !== a.priority) {
          return b.priority - a.priority;
        }
        return b.updatedAt - a.updatedAt;
      });
    } catch (err) {
      promptAction.showToast({ message: '加载任务失败', duration: 2000 });
    } finally {
      this.isLoading = false;
    }
  }

  /**
   * Opens the Add/Edit task dialog.
   */
  private showAddDialog(): void {
    this.addEditDialogController = new CustomDialogController({
      builder: AddEditTaskDialog({
        onConfirm: (
          title: string,
          taskType: string,
          priority: number,
          startDate: number,
          endDate: number
        ) => {
          this.handleAddTask(title, taskType, priority, startDate, endDate);
        }
      }),
      autoCancel: true,
      customStyle: false,
      alignment: DialogAlignment.Center
    });
    this.addEditDialogController.open();
  }

  /**
   * Opens the dialog pre-filled for editing an existing task.
   */
  private showEditDialog(task: TaskModel): void {
    this.addEditDialogController = new CustomDialogController({
      builder: AddEditTaskDialog({
        task: task,
        onConfirm: (
          title: string,
          taskType: string,
          priority: number,
          startDate: number,
          endDate: number
        ) => {
          this.handleEditTask(task.id, title, taskType, priority, startDate, endDate);
        }
      }),
      autoCancel: true,
      customStyle: false,
      alignment: DialogAlignment.Center
    });
    this.addEditDialogController.open();
  }

  /**
   * Inserts a new task into the database and refreshes the list.
   */
  private async handleAddTask(
    title: string,
    taskType: string,
    priority: number,
    startDate: number,
    endDate: number
  ): Promise<void> {
    try {
      const now = Date.now();
      const newTask: TaskModel = {
        id: 0,
        collectionId: this.collectionId,
        userId: this.userId,
        title: title,
        taskType: taskType,
        priority: priority,
        startDate: taskType === 'phase' && startDate > 0 ? startDate : undefined,
        endDate: taskType === 'phase' && endDate > 0 ? endDate : undefined,
        isCompleted: 0,
        isDeleted: 0,
        createdAt: now,
        updatedAt: now
      };
      const taskId = await DBHelper.getInstance().insertTask(newTask);
      if (taskId > 0) {
        newTask.id = taskId;
        // Insert and re-sort
        const updated = [...this.tasks, newTask].sort((a, b) => {
          if (b.priority !== a.priority) {
            return b.priority - a.priority;
          }
          return b.updatedAt - a.updatedAt;
        });
        this.tasks = updated;
        promptAction.showToast({ message: '任务已创建', duration: 2000 });
      }
    } catch (err) {
      promptAction.showToast({ message: '创建任务失败', duration: 2000 });
    }
  }

  /**
   * Updates an existing task and refreshes the list.
   */
  private async handleEditTask(
    taskId: number,
    title: string,
    taskType: string,
    priority: number,
    startDate: number,
    endDate: number
  ): Promise<void> {
    try {
      const updatedTask: TaskModel = {
        id: taskId,
        collectionId: this.collectionId,
        userId: this.userId,
        title: title,
        taskType: taskType,
        priority: priority,
        startDate: taskType === 'phase' && startDate > 0 ? startDate : undefined,
        endDate: taskType === 'phase' && endDate > 0 ? endDate : undefined,
        isCompleted: 0,
        isDeleted: 0,
        createdAt: 0,
        updatedAt: Date.now()
      };
      await DBHelper.getInstance().updateTask(updatedTask);

      // Update local state
      const updated = this.tasks.map(t => {
        if (t.id === taskId) {
          return {
            id: t.id,
            collectionId: t.collectionId,
            userId: t.userId,
            title: updatedTask.title,
            taskType: updatedTask.taskType,
            priority: updatedTask.priority,
            startDate: updatedTask.startDate,
            endDate: updatedTask.endDate,
            isCompleted: t.isCompleted,
            isDeleted: t.isDeleted,
            createdAt: t.createdAt,
            updatedAt: updatedTask.updatedAt
          };
        }
        return t;
      }).sort((a, b) => {
        if (b.priority !== a.priority) {
          return b.priority - a.priority;
        }
        return b.updatedAt - a.updatedAt;
      });
      this.tasks = updated;
      promptAction.showToast({ message: '任务已更新', duration: 2000 });
    } catch (err) {
      promptAction.showToast({ message: '更新任务失败', duration: 2000 });
    }
  }

  /**
   * Soft-deletes a task after user confirmation.
   */
  private handleDeleteTask(task: TaskModel): void {
    promptAction.showDialog({
      title: '确认删除',
      message: `确定要删除任务"${task.title}"吗？`,
      buttons: [
        { text: '取消', color: '#999999' },
        { text: '删除', color: '#E74C3C' }
      ]
    }).then((result) => {
      if (result.index === 1) {
        this.confirmDeleteTask(task.id);
      }
    }).catch(() => {
      // dialog dismissed
    });
  }

  /**
   * Performs the actual soft-deletion after confirmation.
   */
  private async confirmDeleteTask(taskId: number): Promise<void> {
    try {
      await DBHelper.getInstance().softDeleteTask(taskId);
      this.tasks = this.tasks.filter(t => t.id !== taskId);
      promptAction.showToast({ message: '任务已删除', duration: 2000 });
    } catch (err) {
      promptAction.showToast({ message: '删除任务失败', duration: 2000 });
    }
  }

  build() {
    Column() {
      // ---- Top Bar ----
      Row() {
        Button() {
          Text('←')
            .fontSize(22)
            .fontColor('#333333');
        }
        .type(ButtonType.Circle)
        .width(36)
        .height(36)
        .backgroundColor('#00000000')
        .onClick(() => {
          router.back();
        });

        Text(this.collectionName)
          .fontSize(18)
          .fontWeight(FontWeight.Bold)
          .fontColor('#333333')
          .margin({ left: 8 })
          .layoutWeight(1);

        Button() {
          Text('+ 新增任务')
            .fontSize(13)
            .fontColor(Color.White);
        }
        .height(32)
        .backgroundColor('#E74C3C')
        .borderRadius(16)
        .padding({ left: 12, right: 12 })
        .onClick(() => {
          this.showAddDialog();
        });
      }
      .width('100%')
      .padding({ left: 12, right: 16, top: 12, bottom: 12 })
      .backgroundColor(Color.White);

      // ---- Content ----
      if (this.isLoading) {
        Column() {
          LoadingProgress()
            .width(36)
            .height(36)
            .color('#E74C3C');

          Text('加载中...')
            .fontSize(14)
            .fontColor('#999999')
            .margin({ top: 12 });
        }
        .width('100%')
        .layoutWeight(1)
        .justifyContent(FlexAlign.Center);
      } else if (this.tasks.length === 0) {
        Column() {
          Text('📝')
            .fontSize(64)
            .margin({ top: 100, bottom: 16 });

          Text('还没有任务')
            .fontSize(16)
            .fontColor('#999999')
            .margin({ bottom: 8 });

          Text('点击右上角"+ 新增任务"添加第一个任务')
            .fontSize(13)
            .fontColor('#BBBBBB')
            .margin({ bottom: 24 });

          Button('+ 新增任务')
            .fontSize(15)
            .height(42)
            .backgroundColor('#E74C3C')
            .fontColor(Color.White)
            .borderRadius(21)
            .padding({ left: 24, right: 24 })
            .onClick(() => {
              this.showAddDialog();
            });
        }
        .width('100%')
        .layoutWeight(1)
        .alignItems(HorizontalAlign.Center);
      } else {
        List() {
          ForEach(this.tasks, (task: TaskModel) => {
            ListItem() {
              TaskItem({
                task: task,
                onEdit: () => {
                  this.showEditDialog(task);
                },
                onDelete: () => {
                  this.handleDeleteTask(task);
                }
              });
            }
          }, (task: TaskModel) => task.id.toString());
        }
        .width('100%')
        .layoutWeight(1)
        .padding({ left: 16, right: 16, top: 12, bottom: 12 });
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#FAFAFA');
  }
}
