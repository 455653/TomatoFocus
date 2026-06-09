import relationalStore from '@ohos.data.relationalStore';
import { common } from '@kit.AbilityKit';

// ==================== Data Model Interfaces ====================

export interface UserModel {
  id: number;
  username: string;
  passwordMd5: string;
  createdAt: number;
}

export interface CollectionModel {
  id: number;
  userId: number;
  name: string;
  description: string;
  color: string;
  icon: string;
  createdAt: number;
  updatedAt: number;
}

export interface TaskModel {
  id: number;
  collectionId: number;
  userId: number;
  title: string;
  taskType: string;
  priority: number;
  startDate?: number;
  endDate?: number;
  isCompleted: number;
  isDeleted: number;
  createdAt: number;
  updatedAt: number;
}

export interface FocusSessionModel {
  id: number;
  userId: number;
  startTime: number;
  endTime: number;
  durationSeconds: number;
  dateStr: string;
}

// ==================== Database Configuration ====================

const DATABASE_NAME = 'tomato_focus.db';

const SQL_CREATE_USERS = `CREATE TABLE IF NOT EXISTS users (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  username TEXT NOT NULL UNIQUE,
  password_md5 TEXT NOT NULL,
  created_at INTEGER NOT NULL
)`;

const SQL_CREATE_COLLECTIONS = `CREATE TABLE IF NOT EXISTS collections (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  user_id INTEGER NOT NULL,
  name TEXT NOT NULL,
  description TEXT,
  color TEXT,
  icon TEXT,
  created_at INTEGER NOT NULL,
  updated_at INTEGER NOT NULL
)`;

const SQL_CREATE_TASKS = `CREATE TABLE IF NOT EXISTS tasks (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  collection_id INTEGER NOT NULL,
  user_id INTEGER NOT NULL,
  title TEXT NOT NULL,
  task_type TEXT NOT NULL,
  priority INTEGER NOT NULL DEFAULT 1,
  start_date INTEGER,
  end_date INTEGER,
  is_completed INTEGER NOT NULL DEFAULT 0,
  is_deleted INTEGER NOT NULL DEFAULT 0,
  created_at INTEGER NOT NULL,
  updated_at INTEGER NOT NULL
)`;

const SQL_CREATE_HABIT_COMPLETIONS = `CREATE TABLE IF NOT EXISTS habit_completions (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  task_id INTEGER NOT NULL,
  user_id INTEGER NOT NULL,
  complete_date TEXT NOT NULL,
  created_at INTEGER NOT NULL,
  UNIQUE(task_id, complete_date)
)`;

const SQL_CREATE_FOCUS_SESSIONS = `CREATE TABLE IF NOT EXISTS focus_sessions (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  user_id INTEGER NOT NULL,
  start_time INTEGER NOT NULL,
  end_time INTEGER NOT NULL,
  duration_seconds INTEGER NOT NULL,
  date_str TEXT NOT NULL
)`;

const SQL_CREATE_SESSION_TASKS = `CREATE TABLE IF NOT EXISTS session_tasks (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  session_id INTEGER NOT NULL,
  task_id INTEGER NOT NULL
)`;

// ==================== Singleton DBHelper Class ====================

export class DBHelper {
  private static instance: DBHelper | null = null;
  private store: relationalStore.RdbStore | null = null;

  private constructor() {
  }

  /**
   * Returns the singleton instance of DBHelper.
   */
  static getInstance(): DBHelper {
    if (DBHelper.instance === null) {
      DBHelper.instance = new DBHelper();
    }
    return DBHelper.instance;
  }

  /**
   * Initializes the database: creates the RDB store and ensures all tables exist.
   * Must be called once before any other methods, typically from EntryAbility.onCreate.
   * @param context - The UIAbilityContext from the running ability
   */
  async init(context: common.UIAbilityContext): Promise<void> {
    const config: relationalStore.StoreConfig = {
      name: DATABASE_NAME,
      securityLevel: relationalStore.SecurityLevel.S1
    };

    this.store = await relationalStore.getRdbStore(context, config);

    // Create all tables in order (IF NOT EXISTS ensures idempotency)
    await this.store.executeSql(SQL_CREATE_USERS);
    await this.store.executeSql(SQL_CREATE_COLLECTIONS);
    await this.store.executeSql(SQL_CREATE_TASKS);
    await this.store.executeSql(SQL_CREATE_HABIT_COMPLETIONS);
    await this.store.executeSql(SQL_CREATE_FOCUS_SESSIONS);
    await this.store.executeSql(SQL_CREATE_SESSION_TASKS);
  }

  /**
   * Returns the underlying RdbStore instance.
   * Throws if init() has not been called.
   */
  private ensureStore(): relationalStore.RdbStore {
    if (this.store === null) {
      throw new Error('DBHelper not initialized. Call init(context) first.');
    }
    return this.store;
  }

  // ==================== users ====================

  /**
   * Inserts a new user and returns the auto-generated user ID.
   */
  async insertUser(username: string, passwordMd5: string): Promise<number> {
    const store = this.ensureStore();
    const valueBucket: relationalStore.ValuesBucket = {
      'username': username,
      'password_md5': passwordMd5,
      'created_at': Date.now()
    };
    return await store.insert('users', valueBucket);
  }

  /**
   * Retrieves a user by username, or null if not found.
   */
  async getUserByUsername(username: string): Promise<UserModel | null> {
    const store = this.ensureStore();
    const predicates = new relationalStore.RdbPredicates('users');
    predicates.equalTo('username', username);
    const resultSet = await store.query(predicates);
    if (resultSet.goToFirstRow()) {
      const user = this.resultSetToUserModel(resultSet);
      resultSet.close();
      return user;
    }
    resultSet.close();
    return null;
  }

  /**
   * Updates the password (MD5) for a given user.
   */
  async updatePassword(userId: number, newPasswordMd5: string): Promise<void> {
    const store = this.ensureStore();
    const valueBucket: relationalStore.ValuesBucket = {
      'password_md5': newPasswordMd5
    };
    const predicates = new relationalStore.RdbPredicates('users');
    predicates.equalTo('id', userId);
    await store.update(valueBucket, predicates);
  }

  // ==================== collections ====================

  /**
   * Inserts a new collection and returns the auto-generated collection ID.
   */
  async insertCollection(col: CollectionModel): Promise<number> {
    const store = this.ensureStore();
    const now = Date.now();
    const valueBucket: relationalStore.ValuesBucket = {
      'user_id': col.userId,
      'name': col.name,
      'description': col.description ?? '',
      'color': col.color ?? '',
      'icon': col.icon ?? '',
      'created_at': col.createdAt || now,
      'updated_at': col.updatedAt || now
    };
    return await store.insert('collections', valueBucket);
  }

  /**
   * Retrieves all collections belonging to a user.
   */
  async getCollectionsByUser(userId: number): Promise<CollectionModel[]> {
    const store = this.ensureStore();
    const predicates = new relationalStore.RdbPredicates('collections');
    predicates.equalTo('user_id', userId);
    const resultSet = await store.query(predicates);
    const collections: CollectionModel[] = [];
    while (resultSet.goToNextRow()) {
      collections.push(this.resultSetToCollectionModel(resultSet));
    }
    resultSet.close();
    return collections;
  }

  /**
   * Updates an existing collection's fields by its ID.
   */
  async updateCollection(col: CollectionModel): Promise<void> {
    const store = this.ensureStore();
    const valueBucket: relationalStore.ValuesBucket = {
      'name': col.name,
      'description': col.description ?? '',
      'color': col.color ?? '',
      'icon': col.icon ?? '',
      'updated_at': Date.now()
    };
    const predicates = new relationalStore.RdbPredicates('collections');
    predicates.equalTo('id', col.id);
    await store.update(valueBucket, predicates);
  }

  /**
   * Deletes a collection by ID and soft-deletes all tasks within it.
   */
  async deleteCollection(colId: number): Promise<void> {
    const store = this.ensureStore();
    const now = Date.now();

    // 1. Soft-delete all tasks belonging to this collection
    const taskValues: relationalStore.ValuesBucket = {
      'is_deleted': 1,
      'updated_at': now
    };
    const taskPredicates = new relationalStore.RdbPredicates('tasks');
    taskPredicates.equalTo('collection_id', colId);
    await store.update(taskValues, taskPredicates);

    // 2. Hard-delete the collection itself
    const colPredicates = new relationalStore.RdbPredicates('collections');
    colPredicates.equalTo('id', colId);
    await store.delete(colPredicates);
  }

  // ==================== tasks ====================

  /**
   * Inserts a new task and returns the auto-generated task ID.
   */
  async insertTask(task: TaskModel): Promise<number> {
    const store = this.ensureStore();
    const now = Date.now();
    const valueBucket: relationalStore.ValuesBucket = {
      'collection_id': task.collectionId,
      'user_id': task.userId,
      'title': task.title,
      'task_type': task.taskType,
      'priority': task.priority ?? 1,
      'is_completed': task.isCompleted ?? 0,
      'is_deleted': task.isDeleted ?? 0,
      'created_at': task.createdAt || now,
      'updated_at': task.updatedAt || now
    };
    if (task.startDate !== undefined) {
      valueBucket['start_date'] = task.startDate;
    }
    if (task.endDate !== undefined) {
      valueBucket['end_date'] = task.endDate;
    }
    return await store.insert('tasks', valueBucket);
  }

  /**
   * Retrieves all non-deleted tasks in a collection.
   */
  async getTasksByCollection(collectionId: number): Promise<TaskModel[]> {
    const store = this.ensureStore();
    const predicates = new relationalStore.RdbPredicates('tasks');
    predicates.equalTo('collection_id', collectionId)
      .and()
      .equalTo('is_deleted', 0);
    const resultSet = await store.query(predicates);
    const tasks: TaskModel[] = [];
    while (resultSet.goToNextRow()) {
      tasks.push(this.resultSetToTaskModel(resultSet));
    }
    resultSet.close();
    return tasks;
  }

  /**
   * Updates an existing task's fields by its ID.
   */
  async updateTask(task: TaskModel): Promise<void> {
    const store = this.ensureStore();
    const valueBucket: relationalStore.ValuesBucket = {
      'collection_id': task.collectionId,
      'title': task.title,
      'task_type': task.taskType,
      'priority': task.priority,
      'is_completed': task.isCompleted,
      'is_deleted': task.isDeleted,
      'updated_at': Date.now()
    };
    if (task.startDate !== undefined) {
      valueBucket['start_date'] = task.startDate;
    }
    if (task.endDate !== undefined) {
      valueBucket['end_date'] = task.endDate;
    }
    const predicates = new relationalStore.RdbPredicates('tasks');
    predicates.equalTo('id', task.id);
    await store.update(valueBucket, predicates);
  }

  /**
   * Soft-deletes a task by setting is_deleted = 1.
   */
  async softDeleteTask(taskId: number): Promise<void> {
    const store = this.ensureStore();
    const valueBucket: relationalStore.ValuesBucket = {
      'is_deleted': 1,
      'updated_at': Date.now()
    };
    const predicates = new relationalStore.RdbPredicates('tasks');
    predicates.equalTo('id', taskId);
    await store.update(valueBucket, predicates);
  }

  /**
   * Retrieves a single task by its ID, or null if not found.
   */
  async getTaskById(taskId: number): Promise<TaskModel | null> {
    const store = this.ensureStore();
    const predicates = new relationalStore.RdbPredicates('tasks');
    predicates.equalTo('id', taskId);
    const resultSet = await store.query(predicates);
    if (resultSet.goToFirstRow()) {
      const task = this.resultSetToTaskModel(resultSet);
      resultSet.close();
      return task;
    }
    resultSet.close();
    return null;
  }

  // ==================== habit_completions ====================

  /**
   * Marks a habit task as completed for the given date.
   * Does nothing if already completed today (respects UNIQUE constraint).
   */
  async insertHabitCompletion(taskId: number, userId: number, dateStr: string): Promise<void> {
    const store = this.ensureStore();
    // Check first to avoid UNIQUE constraint violation
    const alreadyCompleted = await this.isHabitCompletedToday(taskId, dateStr);
    if (alreadyCompleted) {
      return;
    }
    const valueBucket: relationalStore.ValuesBucket = {
      'task_id': taskId,
      'user_id': userId,
      'complete_date': dateStr,
      'created_at': Date.now()
    };
    await store.insert('habit_completions', valueBucket);
  }

  /**
   * Checks whether a habit task has been completed on the given date.
   */
  async isHabitCompletedToday(taskId: number, dateStr: string): Promise<boolean> {
    const store = this.ensureStore();
    const predicates = new relationalStore.RdbPredicates('habit_completions');
    predicates.equalTo('task_id', taskId)
      .and()
      .equalTo('complete_date', dateStr);
    const resultSet = await store.query(predicates);
    const exists = resultSet.goToFirstRow();
    resultSet.close();
    return exists;
  }

  /**
   * Removes a habit completion record for the given task and date.
   */
  async deleteHabitCompletion(taskId: number, dateStr: string): Promise<void> {
    const store = this.ensureStore();
    const predicates = new relationalStore.RdbPredicates('habit_completions');
    predicates.equalTo('task_id', taskId)
      .and()
      .equalTo('complete_date', dateStr);
    await store.delete(predicates);
  }

  // ==================== focus_sessions ====================

  /**
   * Inserts a new focus session and returns the auto-generated session ID.
   */
  async insertFocusSession(session: FocusSessionModel): Promise<number> {
    const store = this.ensureStore();
    const valueBucket: relationalStore.ValuesBucket = {
      'user_id': session.userId,
      'start_time': session.startTime,
      'end_time': session.endTime,
      'duration_seconds': session.durationSeconds,
      'date_str': session.dateStr
    };
    return await store.insert('focus_sessions', valueBucket);
  }

  /**
   * Associates a task with a focus session (many-to-many relationship).
   */
  async insertSessionTask(sessionId: number, taskId: number): Promise<void> {
    const store = this.ensureStore();
    const valueBucket: relationalStore.ValuesBucket = {
      'session_id': sessionId,
      'task_id': taskId
    };
    await store.insert('session_tasks', valueBucket);
  }

  /**
   * Retrieves all focus sessions for a user on a specific date.
   */
  async getFocusSessionsByDate(userId: number, dateStr: string): Promise<FocusSessionModel[]> {
    const store = this.ensureStore();
    const predicates = new relationalStore.RdbPredicates('focus_sessions');
    predicates.equalTo('user_id', userId)
      .and()
      .equalTo('date_str', dateStr);
    const resultSet = await store.query(predicates);
    const sessions: FocusSessionModel[] = [];
    while (resultSet.goToNextRow()) {
      sessions.push(this.resultSetToFocusSessionModel(resultSet));
    }
    resultSet.close();
    return sessions;
  }

  /**
   * Retrieves all focus sessions for a user within a date range (inclusive).
   */
  async getFocusSessionsByDateRange(
    userId: number,
    startDate: string,
    endDate: string
  ): Promise<FocusSessionModel[]> {
    const store = this.ensureStore();
    const predicates = new relationalStore.RdbPredicates('focus_sessions');
    predicates.equalTo('user_id', userId)
      .and()
      .greaterThanOrEqualTo('date_str', startDate)
      .and()
      .lessThanOrEqualTo('date_str', endDate);
    const resultSet = await store.query(predicates);
    const sessions: FocusSessionModel[] = [];
    while (resultSet.goToNextRow()) {
      sessions.push(this.resultSetToFocusSessionModel(resultSet));
    }
    resultSet.close();
    return sessions;
  }

  /**
   * Retrieves all task IDs associated with a focus session.
   */
  async getSessionTaskIds(sessionId: number): Promise<number[]> {
    const store = this.ensureStore();
    const predicates = new relationalStore.RdbPredicates('session_tasks');
    predicates.equalTo('session_id', sessionId);
    const resultSet = await store.query(predicates);
    const taskIds: number[] = [];
    while (resultSet.goToNextRow()) {
      taskIds.push(resultSet.getLong(resultSet.getColumnIndex('task_id')));
    }
    resultSet.close();
    return taskIds;
  }

  // ==================== Private Helpers ====================

  private resultSetToUserModel(rs: relationalStore.ResultSet): UserModel {
    return {
      id: rs.getLong(rs.getColumnIndex('id')),
      username: rs.getString(rs.getColumnIndex('username')),
      passwordMd5: rs.getString(rs.getColumnIndex('password_md5')),
      createdAt: rs.getLong(rs.getColumnIndex('created_at'))
    };
  }

  private resultSetToCollectionModel(rs: relationalStore.ResultSet): CollectionModel {
    return {
      id: rs.getLong(rs.getColumnIndex('id')),
      userId: rs.getLong(rs.getColumnIndex('user_id')),
      name: rs.getString(rs.getColumnIndex('name')),
      description: rs.getString(rs.getColumnIndex('description')),
      color: rs.getString(rs.getColumnIndex('color')),
      icon: rs.getString(rs.getColumnIndex('icon')),
      createdAt: rs.getLong(rs.getColumnIndex('created_at')),
      updatedAt: rs.getLong(rs.getColumnIndex('updated_at'))
    };
  }

  private resultSetToTaskModel(rs: relationalStore.ResultSet): TaskModel {
    const startDateIdx = rs.getColumnIndex('start_date');
    const endDateIdx = rs.getColumnIndex('end_date');

    return {
      id: rs.getLong(rs.getColumnIndex('id')),
      collectionId: rs.getLong(rs.getColumnIndex('collection_id')),
      userId: rs.getLong(rs.getColumnIndex('user_id')),
      title: rs.getString(rs.getColumnIndex('title')),
      taskType: rs.getString(rs.getColumnIndex('task_type')),
      priority: rs.getLong(rs.getColumnIndex('priority')),
      startDate: rs.isColumnNull(startDateIdx) ? undefined : rs.getLong(startDateIdx),
      endDate: rs.isColumnNull(endDateIdx) ? undefined : rs.getLong(endDateIdx),
      isCompleted: rs.getLong(rs.getColumnIndex('is_completed')),
      isDeleted: rs.getLong(rs.getColumnIndex('is_deleted')),
      createdAt: rs.getLong(rs.getColumnIndex('created_at')),
      updatedAt: rs.getLong(rs.getColumnIndex('updated_at'))
    };
  }

  private resultSetToFocusSessionModel(rs: relationalStore.ResultSet): FocusSessionModel {
    return {
      id: rs.getLong(rs.getColumnIndex('id')),
      userId: rs.getLong(rs.getColumnIndex('user_id')),
      startTime: rs.getLong(rs.getColumnIndex('start_time')),
      endTime: rs.getLong(rs.getColumnIndex('end_time')),
      durationSeconds: rs.getLong(rs.getColumnIndex('duration_seconds')),
      dateStr: rs.getString(rs.getColumnIndex('date_str'))
    };
  }
}
