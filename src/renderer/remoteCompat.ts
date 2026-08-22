// Compatibility facade for the legacy `remote.*` object used throughout the
// renderer. @electron/remote exposes these APIs as named functions instead.
// Use a relative package path so the renderer webpack alias below does not
// recursively resolve this facade.
const api: any = require('../../node_modules/@electron/remote/renderer');

export const remote = {
  getCurrentWindow: api.getCurrentWindow,
  app: api.getBuiltin('app'),
  dialog: api.getBuiltin('dialog') as Electron.Dialog,
  shell: api.getBuiltin('shell') as Electron.Shell,
  powerSaveBlocker: api.getBuiltin('powerSaveBlocker'),
};
export const getCurrentWindow = api.getCurrentWindow;
export const app = remote.app;
export const dialog = remote.dialog;
export const shell = remote.shell;
export const powerSaveBlocker = remote.powerSaveBlocker;
export const Menu = api.getBuiltin('Menu');
export const MenuItem = api.getBuiltin('MenuItem');

// Preserve the old object-shaped API for existing imports while retaining
// the @electron/remote package as the implementation.

export default remote;
