import { app, ipcMain, IpcMainEvent } from 'electron'

import { createNewWindow } from './WindowManager'
import {IPC} from "../renderer/data/const";

// Define functions
function onRequestCreateNewWindow(ev: IpcMainEvent) {
  createNewWindow();
}

function onRequestClearCache() {
  require('electron').session.defaultSession.clearCache();
}


// Initialize and release listeners
let initialized = false;
export function initializeIpcEvents() {
  if (initialized) {
    return;
  }

  initialized = true;
  ipcMain.on(IPC.newWindow, onRequestCreateNewWindow);
  ipcMain.on(IPC.clearCache, onRequestClearCache);
}

export function releaseIpcEvents() {
  if (initialized) {
    ipcMain.removeAllListeners(IPC.newWindow);
    ipcMain.removeAllListeners(IPC.clearCache);
  }

  initialized = false;
}
