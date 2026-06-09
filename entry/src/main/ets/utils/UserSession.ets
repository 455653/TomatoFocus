/**
 * Global user session singleton.
 * Tracks login state, user ID, and username across the app.
 */
export class UserSession {
  private static instance: UserSession | null = null;

  userId: number = -1;
  username: string = '';
  isLoggedIn: boolean = false;

  private constructor() {
  }

  static getInstance(): UserSession {
    if (UserSession.instance === null) {
      UserSession.instance = new UserSession();
    }
    return UserSession.instance;
  }

  /**
   * Sets the login state with user info.
   */
  login(userId: number, username: string): void {
    this.userId = userId;
    this.username = username;
    this.isLoggedIn = true;
  }

  /**
   * Clears login state.
   */
  logout(): void {
    this.userId = -1;
    this.username = '';
    this.isLoggedIn = false;
  }
}
