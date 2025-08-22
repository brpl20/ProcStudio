import { writable } from 'svelte/store';
import type { Task, Column, DragState } from '$lib/types/board.types';

function createDragStore() {
  const initialState: DragState = {
    isDragging: false,
    draggedTask: null,
    draggedColumn: null,
    sourceColumnId: null,
    targetColumnId: null,
    dropPosition: null
  };

  const { subscribe, set, update } = writable<DragState>(initialState);

  return {
    subscribe,

    // Start dragging a task
    startTaskDrag(task: Task, sourceColumnId: string) {
      update((state) => ({
        ...state,
        isDragging: true,
        draggedTask: task,
        sourceColumnId,
        draggedColumn: null
      }));
    },

    // Start dragging a column
    startColumnDrag(column: Column) {
      update((state) => ({
        ...state,
        isDragging: true,
        draggedColumn: column,
        draggedTask: null,
        sourceColumnId: null
      }));
    },

    // Update target column during drag over
    setTargetColumn(columnId: string | null) {
      update((state) => ({
        ...state,
        targetColumnId: columnId
      }));
    },

    // Update drop position during drag over
    setDropPosition(position: number | null) {
      update((state) => ({
        ...state,
        dropPosition: position
      }));
    },

    // End drag operation
    endDrag() {
      set(initialState);
    },

    // Reset drag state
    reset() {
      set(initialState);
    }
  };
}

export const dragStore = createDragStore();

// Helper function to create drag data
export function createDragData(type: 'task' | 'column', data: Task | Column): string {
  return JSON.stringify({ type, data });
}

// Helper function to parse drag data
export function parseDragData(
  dataTransfer: DataTransfer
): { type: 'task' | 'column'; data: any } | null {
  try {
    const data = dataTransfer.getData('application/json');
    if (!data) {
      return null;
    }
    return JSON.parse(data);
  } catch {
    return null;
  }
}

// Visual feedback classes for drag operations
export const dragClasses = {
  dragging: 'opacity-50 cursor-move',
  dragOver: 'bg-base-200 border-2 border-dashed border-primary',
  dropTarget: 'ring-2 ring-primary ring-offset-2',
  placeholder: 'bg-gradient-to-r from-transparent via-base-200 to-transparent'
};
