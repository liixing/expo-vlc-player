// Reexport the native module. On web, it will be resolved to ExpoVlcPlayerModule.web.ts
// and on native platforms to ExpoVlcPlayerModule.ts
export { default } from './ExpoVlcPlayerModule';
export { default as ExpoVlcPlayerView } from './ExpoVlcPlayerView';
export * from  './ExpoVlcPlayer.types';
