// Board and Column type definitions for the table system

export interface Board {
  id: string;
  title: string;
  description?: string;
  columns: Column[];
  createdAt: Date;
  updatedAt: Date;
}

export interface Column {
  id: string;
  boardId: string;
  title: string;
  color: string;
  position: number;
  tasks: Task[];
  wipLimit?: number;
}

export interface Task {
  id: string;
  columnId: string;
  title: string;
  description?: string;
  status: TaskStatus;
  priority: TaskPriority;
  position: number;
  assignedTo?: string[];
  dueDate?: Date;
  labels?: Label[];
  attachments?: Attachment[];
  comments?: Comment[];
  createdAt: Date;
  updatedAt: Date;
  createdBy: string;
}

export type TaskStatus = 'pending' | 'in_progress' | 'completed' | 'cancelled';
export type TaskPriority = 'low' | 'medium' | 'high' | 'urgent';

export interface Label {
  id: string;
  name: string;
  color: string;
}

export interface Attachment {
  id: string;
  filename: string;
  url: string;
  size: number;
  uploadedAt: Date;
}

export interface Comment {
  id: string;
  taskId: string;
  text: string;
  authorId: string;
  authorName: string;
  createdAt: Date;
}

export interface DragState {
  isDragging: boolean;
  draggedTask: Task | null;
  draggedColumn: Column | null;
  sourceColumnId: string | null;
  targetColumnId: string | null;
  dropPosition: number | null;
}

export interface CreateTaskDto {
  title: string;
  description?: string;
  status?: TaskStatus;
  priority?: TaskPriority;
  columnId: string;
  assignedTo?: string[];
  dueDate?: Date;
}

export interface UpdateTaskDto extends Partial<CreateTaskDto> {
  position?: number;
}

export interface CreateColumnDto {
  title: string;
  boardId: string;
  color?: string;
  wipLimit?: number;
}

export interface UpdateColumnDto extends Partial<CreateColumnDto> {
  position?: number;
}

export interface MoveTaskDto {
  taskId: string;
  sourceColumnId: string;
  targetColumnId: string;
  position: number;
}

export interface ReorderColumnDto {
  columnId: string;
  newPosition: number;
}
