import { promptAction } from '@kit.ArkUI';
import { DBHelper, CollectionModel } from '../database/DBHelper';
import { UserSession } from '../utils/UserSession';
import { CollectionCard } from '../components/CollectionCard';
import { AddEditCollectionDialog } from '../components/AddEditCollectionDialog';

@Component
export struct TaskManagerPage {
  @State collections: CollectionModel[] = [];
  @State taskCountMap: Map<number, number> = new Map<number, number>();
  @State isRefreshing: boolean = false;
  @State isLoading: boolean = true;

  private userId: number = UserSession.getInstance().userId;

  private addEditDialogController: CustomDialogController | null = null;

  aboutToAppear(): void {
    this.loadCollections();
  }

  /**
   * Loads all collections and their task counts from the database.
   */
  private async loadCollections(): Promise<void> {
    try {
      const collections = await DBHelper.getInstance().getCollectionsByUser(this.userId);
      this.collections = collections;

      // Compute task counts per collection
      const countMap = new Map<number, number>();
      for (const col of collections) {
        const tasks = await DBHelper.getInstance().getTasksByCollection(col.id);
        countMap.set(col.id, tasks.length);
      }
      this.taskCountMap = countMap;
    } catch (err) {
      promptAction.showToast({ message: '加载合集失败', duration: 2000 });
    } finally {
      this.isLoading = false;
      this.isRefreshing = false;
    }
  }

  /**
   * Opens the Add/Edit collection dialog.
   */
  private showAddDialog(): void {
    this.addEditDialogController = new CustomDialogController({
      builder: AddEditCollectionDialog({
        onConfirm: (name: string, description: string, color: string, icon: string) => {
          this.handleAddCollection(name, description, color, icon);
        }
      }),
      autoCancel: true,
      customStyle: false,
      alignment: DialogAlignment.Center
    });
    this.addEditDialogController.open();
  }

  /**
   * Opens the dialog pre-filled for editing an existing collection.
   */
  private showEditDialog(collection: CollectionModel): void {
    this.addEditDialogController = new CustomDialogController({
      builder: AddEditCollectionDialog({
        collection: collection,
        onConfirm: (name: string, description: string, color: string, icon: string) => {
          this.handleEditCollection(collection.id, name, description, color, icon);
        }
      }),
      autoCancel: true,
      customStyle: false,
      alignment: DialogAlignment.Center
    });
    this.addEditDialogController.open();
  }

  /**
   * Inserts a new collection into the database.
   */
  private async handleAddCollection(
    name: string,
    description: string,
    color: string,
    icon: string
  ): Promise<void> {
    try {
      const now = Date.now();
      const newCol: CollectionModel = {
        id: 0,
        userId: this.userId,
        name: name,
        description: description,
        color: color,
        icon: icon,
        createdAt: now,
        updatedAt: now
      };
      const colId = await DBHelper.getInstance().insertCollection(newCol);
      if (colId > 0) {
        newCol.id = colId;
        this.collections = [...this.collections, newCol];
        const newMap = new Map(this.taskCountMap);
        newMap.set(colId, 0);
        this.taskCountMap = newMap;
        promptAction.showToast({ message: '合集已创建', duration: 2000 });
      }
    } catch (err) {
      promptAction.showToast({ message: '创建合集失败', duration: 2000 });
    }
  }

  /**
   * Updates an existing collection in the database.
   */
  private async handleEditCollection(
    colId: number,
    name: string,
    description: string,
    color: string,
    icon: string
  ): Promise<void> {
    try {
      const col: CollectionModel = {
        id: colId,
        userId: this.userId,
        name: name,
        description: description,
        color: color,
        icon: icon,
        createdAt: 0,
        updatedAt: Date.now()
      };
      await DBHelper.getInstance().updateCollection(col);

      // Update local state
      const updated = this.collections.map(c => {
        if (c.id === colId) {
          return {
            id: c.id,
            userId: c.userId,
            name: name,
            description: description,
            color: color,
            icon: icon,
            createdAt: c.createdAt,
            updatedAt: col.updatedAt
          };
        }
        return c;
      });
      this.collections = updated;
      promptAction.showToast({ message: '合集已更新', duration: 2000 });
    } catch (err) {
      promptAction.showToast({ message: '更新合集失败', duration: 2000 });
    }
  }

  /**
   * Deletes a collection after user confirmation.
   */
  private handleDeleteCollection(collection: CollectionModel): void {
    promptAction.showDialog({
      title: '确认删除',
      message: `确定要删除合集"${collection.name}"吗？合集内的任务也将被删除。`,
      buttons: [
        { text: '取消', color: '#999999' },
        { text: '删除', color: '#E74C3C' }
      ]
    }).then((result) => {
      if (result.index === 1) {
        this.confirmDeleteCollection(collection.id);
      }
    }).catch(() => {
      // dialog dismissed
    });
  }

  /**
   * Performs the actual deletion after confirmation.
   */
  private async confirmDeleteCollection(colId: number): Promise<void> {
    try {
      await DBHelper.getInstance().deleteCollection(colId);
      this.collections = this.collections.filter(c => c.id !== colId);
      const newMap = new Map(this.taskCountMap);
      newMap.delete(colId);
      this.taskCountMap = newMap;
      promptAction.showToast({ message: '合集已删除', duration: 2000 });
    } catch (err) {
      promptAction.showToast({ message: '删除合集失败', duration: 2000 });
    }
  }

  build() {
    Column() {
      // ---- Top Bar ----
      Row() {
        Text('任务管理')
          .fontSize(20)
          .fontWeight(FontWeight.Bold)
          .fontColor('#333333');

        Blank();

        // AI Plan button
        Button() {
          Text('🤖 AI规划')
            .fontSize(13)
            .fontColor('#E74C3C');
        }
        .height(32)
        .backgroundColor('#FFF0EE')
        .borderRadius(16)
        .padding({ left: 12, right: 12 })
        .onClick(() => {
          promptAction.showToast({ message: 'AI规划功能开发中', duration: 2000 });
        });

        Blank().width(8);

        // Add collection button
        Button() {
          Text('+ 新增合集')
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
      .padding({ left: 16, right: 16, top: 12, bottom: 12 })
      .backgroundColor(Color.White);

      // ---- Content ----
      if (this.isLoading && this.collections.length === 0) {
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
      } else {
        Refresh({ refreshing: $$this.isRefreshing }) {
          if (this.collections.length === 0) {
            // Empty state
            Scroll() {
              Column() {
                Text('📋')
                  .fontSize(64)
                  .margin({ top: 120, bottom: 16 });

                Text('还没有合集')
                  .fontSize(16)
                  .fontColor('#999999')
                  .margin({ bottom: 8 });

                Text('点击右上角"+ 新增合集"创建第一个合集')
                  .fontSize(13)
                  .fontColor('#BBBBBB')
                  .margin({ bottom: 24 });

                Button('+ 新增合集')
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
              .alignItems(HorizontalAlign.Center);
            }
            .width('100%')
            .layoutWeight(1)
            .scrollBar(BarState.Off);
          } else {
            List() {
              ForEach(this.collections, (collection: CollectionModel) => {
                ListItem() {
                  CollectionCard({
                    collectionId: collection.id,
                    name: collection.name,
                    description: collection.description,
                    color: collection.color,
                    icon: collection.icon,
                    taskCount: this.taskCountMap.get(collection.id) ?? 0,
                    onEdit: () => {
                      this.showEditDialog(collection);
                    },
                    onDelete: () => {
                      this.handleDeleteCollection(collection);
                    }
                  });
                }
              }, (collection: CollectionModel) => collection.id.toString());
            }
            .width('100%')
            .layoutWeight(1)
            .padding({ left: 16, right: 16, top: 12, bottom: 12 });
          }
        }
        .layoutWeight(1)
        .onRefreshing(() => {
          this.loadCollections();
        });
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#FAFAFA');
  }
}
