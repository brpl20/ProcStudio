import { writable, derived } from 'svelte/store';
import type {
  Board,
  Column,
  Task,
  CreateTaskDto,
  UpdateTaskDto,
  MoveTaskDto
} from '$lib/components/board/board.types';

interface BoardState {
  boards: Board[];
  currentBoard: Board | null;
  isLoading: boolean;
  error: string | null;
  selectedTaskId: string | null;
}

function createBoardStore() {
  const { subscribe, update } = writable<BoardState>({
    boards: [],
    currentBoard: null,
    isLoading: false,
    error: null,
    selectedTaskId: null
  });

  // Mock data for development - replace with API calls
  const mockBoard: Board = {
    id: '1',
    title: 'Projeto Principal',
    description: 'Quadro de tarefas do projeto',
    createdAt: new Date(),
    updatedAt: new Date(),
    columns: [
      {
        id: 'col1',
        boardId: '1',
        title: 'A Fazer',
        color: '#ef4444',
        position: 0,
        tasks: [],
        wipLimit: 5
      },
      {
        id: 'col2',
        boardId: '1',
        title: 'Em Progresso',
        color: '#f59e0b',
        position: 1,
        tasks: [],
        wipLimit: 3
      },
      {
        id: 'col3',
        boardId: '1',
        title: 'Em Revisão',
        color: '#3b82f6',
        position: 2,
        tasks: [],
        wipLimit: 3
      },
      {
        id: 'col4',
        boardId: '1',
        title: 'Concluído',
        color: '#10b981',
        position: 3,
        tasks: []
      }
    ]
  };

  return {
    subscribe,

    // Initialize board with mock data or fetch from API
    async initBoard(_boardId?: string) {
      update((state) => ({ ...state, isLoading: true, error: null }));

      try {
        // TODO: Replace with actual API call
        // const response = await boardService.getBoard(boardId);

        // For now, use mock data
        setTimeout(() => {
          update((state) => ({
            ...state,
            currentBoard: mockBoard,
            isLoading: false
          }));
        }, 500);
      } catch (error) {
        update((state) => ({
          ...state,
          error: error instanceof Error ? error.message : 'Erro ao carregar quadro',
          isLoading: false
        }));
      }
    },

    // Add a new task to a column
    addTask(columnId: string, task: CreateTaskDto) {
      update((state) => {
        if (!state.currentBoard) {
          return state;
        }

        const newTask: Task = {
          id: `task-${Date.now()}`,
          columnId,
          title: task.title,
          description: task.description,
          status: task.status || 'pending',
          priority: task.priority || 'medium',
          position: 0,
          assignedTo: task.assignedTo,
          dueDate: task.dueDate,
          createdAt: new Date(),
          updatedAt: new Date(),
          createdBy: 'current-user'
        };

        const updatedColumns = state.currentBoard.columns.map((col) => {
          if (col.id === columnId) {
            return {
              ...col,
              tasks: [newTask, ...col.tasks.map((t) => ({ ...t, position: t.position + 1 }))]
            };
          }
          return col;
        });

        return {
          ...state,
          currentBoard: {
            ...state.currentBoard,
            columns: updatedColumns
          }
        };
      });
    },

    // Update an existing task
    updateTask(taskId: string, updates: UpdateTaskDto) {
      update((state) => {
        if (!state.currentBoard) {
          return state;
        }

        const updatedColumns = state.currentBoard.columns.map((col) => ({
          ...col,
          tasks: col.tasks.map((task) =>
            task.id === taskId ? { ...task, ...updates, updatedAt: new Date() } : task
          )
        }));

        return {
          ...state,
          currentBoard: {
            ...state.currentBoard,
            columns: updatedColumns
          }
        };
      });
    },

    // Move task between columns or within same column
    moveTask(move: MoveTaskDto) {
      update((state) => {
        if (!state.currentBoard) {
          return state;
        }

        let taskToMove: Task | undefined;

        // Remove task from source column
        const columnsAfterRemove = state.currentBoard.columns.map((col) => {
          if (col.id === move.sourceColumnId) {
            const tasks = [...col.tasks];
            const taskIndex = tasks.findIndex((t) => t.id === move.taskId);
            if (taskIndex !== -1) {
              taskToMove = tasks[taskIndex];
              tasks.splice(taskIndex, 1);
            }
            return { ...col, tasks };
          }
          return col;
        });

        if (!taskToMove) {
          return state;
        }

        // Add task to target column at specified position
        const updatedColumns = columnsAfterRemove.map((col) => {
          if (col.id === move.targetColumnId) {
            const tasks = [...col.tasks];
            taskToMove!.columnId = move.targetColumnId;
            tasks.splice(move.position, 0, taskToMove!);

            // Update positions
            return {
              ...col,
              tasks: tasks.map((t, index) => ({ ...t, position: index }))
            };
          }
          return col;
        });

        return {
          ...state,
          currentBoard: {
            ...state.currentBoard,
            columns: updatedColumns
          }
        };
      });
    },

    // Delete a task
    deleteTask(taskId: string) {
      update((state) => {
        if (!state.currentBoard) {
          return state;
        }

        const updatedColumns = state.currentBoard.columns.map((col) => ({
          ...col,
          tasks: col.tasks.filter((task) => task.id !== taskId)
        }));

        return {
          ...state,
          currentBoard: {
            ...state.currentBoard,
            columns: updatedColumns
          }
        };
      });
    },

    // Add a new column
    addColumn(title: string, color: string = '#6b7280') {
      update((state) => {
        if (!state.currentBoard) {
          return state;
        }

        const newColumn: Column = {
          id: `col-${Date.now()}`,
          boardId: state.currentBoard.id,
          title,
          color,
          position: state.currentBoard.columns.length,
          tasks: []
        };

        return {
          ...state,
          currentBoard: {
            ...state.currentBoard,
            columns: [...state.currentBoard.columns, newColumn]
          }
        };
      });
    },

    // Update column
    updateColumn(columnId: string, updates: Partial<Column>) {
      update((state) => {
        if (!state.currentBoard) {
          return state;
        }

        const updatedColumns = state.currentBoard.columns.map((col) =>
          col.id === columnId ? { ...col, ...updates } : col
        );

        return {
          ...state,
          currentBoard: {
            ...state.currentBoard,
            columns: updatedColumns
          }
        };
      });
    },

    // Delete column
    deleteColumn(columnId: string) {
      update((state) => {
        if (!state.currentBoard) {
          return state;
        }

        const updatedColumns = state.currentBoard.columns
          .filter((col) => col.id !== columnId)
          .map((col, index) => ({ ...col, position: index }));

        return {
          ...state,
          currentBoard: {
            ...state.currentBoard,
            columns: updatedColumns
          }
        };
      });
    },

    // Reorder columns
    reorderColumns(sourceIndex: number, destinationIndex: number) {
      update((state) => {
        if (!state.currentBoard) {
          return state;
        }

        const columns = [...state.currentBoard.columns];
        const [removed] = columns.splice(sourceIndex, 1);
        columns.splice(destinationIndex, 0, removed);

        // Update positions
        const updatedColumns = columns.map((col, index) => ({
          ...col,
          position: index
        }));

        return {
          ...state,
          currentBoard: {
            ...state.currentBoard,
            columns: updatedColumns
          }
        };
      });
    },

    // Select/deselect task
    selectTask(taskId: string | null) {
      update((state) => ({ ...state, selectedTaskId: taskId }));
    },

    // Clear error
    clearError() {
      update((state) => ({ ...state, error: null }));
    }
  };
}

export const boardStore = createBoardStore();

// Derived stores for computed values
export const columns = derived(
  boardStore,
  ($boardStore) => $boardStore.currentBoard?.columns || []
);

export const totalTasks = derived(
  boardStore,
  ($boardStore) =>
    $boardStore.currentBoard?.columns.reduce((acc, col) => acc + col.tasks.length, 0) || 0
);

export const selectedTask = derived(boardStore, ($boardStore) => {
  if (!$boardStore.selectedTaskId || !$boardStore.currentBoard) {
    return null;
  }

  for (const column of $boardStore.currentBoard.columns) {
    const task = column.tasks.find((t) => t.id === $boardStore.selectedTaskId);
    if (task) {
      return task;
    }
  }
  return null;
});
