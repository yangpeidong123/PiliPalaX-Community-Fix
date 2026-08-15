# PROJECT_FIX — PiliPalaX 全面优化
## P0 高优先级
- [x] #4 图片缓存根据设备内存动态调整（低端机 100张/50MB）
- [x] #5 为 30+ Controller 添加 dispose/onClose
- [x] #1 为列表 item 添加 RepaintBoundary（27 个列表页显式声明 addRepaintBoundaries + VideoCardH/V 已有）

## P1 中优先级
- [x] #8 替换 162 处 print 为 debugPrint
- [x] #7 修复空 catch 吞错误（15 文件 29 处）
- [x] #12 显式声明 minSdkVersion 21 / targetSdkVersion 35
- [x] #13 添加 ABI 过滤 armeabi-v7a + arm64-v8a

## P2 低优先级
- [x] #3 Sliver 列表添加 keepAlive（27 文件）
- [ ] #2 高频组件添加 const
