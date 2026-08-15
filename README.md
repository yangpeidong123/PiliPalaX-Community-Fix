<div align="center">
  <img width="160" height="160" src="assets/images/logo/logo_android.png" alt="PiliPalaX logo">
  <h1>PiliPalaX Community Fix</h1>
  <p>基于 PiliPalaX 的第三方 Bilibili 客户端 · 社区优化版</p>
  <p>
    <img src="https://img.shields.io/badge/Flutter-3.29.0-blue" alt="Flutter">
    <img src="https://img.shields.io/badge/Android-5.0%2B-green" alt="Android">
    <img src="https://img.shields.io/badge/license-GPLv3-blue" alt="GPLv3">
  </p>
</div>

---

## 这是什么

PiliPalaX Community Fix 是一个**第三方 Bilibili（B站）客户端**，基于 Flutter 构建，支持视频播放、弹幕、直播、动态、搜索、收藏等 B站核心功能。

本仓库在 [shenshiaba/PiliPalaX-Community-Fix](https://github.com/shenshiaba/PiliPalaX-Community-Fix) 的基础上，针对低端 Android 设备（如 vivo Y71A / Android 8.0 / 2GB RAM）进行了兼容性修复和性能优化。

## 上游项目

本项目的代码来源链如下，在此向所有上游作者和贡献者致以诚挚感谢：

| 层级 | 项目 | 作者 | 说明 |
|------|------|------|------|
| 原始项目 | [pilipala](https://github.com/guozhigq/pilipala) | [@guozhigq](https://github.com/guozhigq) | 原始 PiliPala 项目 |
| 直接上游 | [PiliPalaX](https://github.com/orz12/PiliPalaX) | [@orz12](https://github.com/orz12) | PiliPala 的分支，增强功能 |
| 社区修复 | [PiliPalaX-Community-Fix](https://github.com/shenshiaba/PiliPalaX-Community-Fix) | [@shenshiaba](https://github.com/shenshiaba) | 一次性兼容修复（动态页/直播页） |
| **本仓库** | **PiliPalaX-Community-Fix** | [@yangpeidong123](https://github.com/yangpeidong123) | 在社区修复基础上持续优化 |

本项目继续遵循 [GNU General Public License v3.0](LICENSE)。

## 创作历程

### 第一阶段：社区修复（by @shenshiaba）

原 PiliPalaX 作者 @orz12 停止维护后，社区出现了影响使用的问题：

- **动态页无法加载**：B站接口返回的布尔字段偶发 `0/1` 或字符串，导致类型转换异常（`type 'int' is not a subtype of type 'bool?'`）
- **直播首页 `-352` 错误**：直播分区、推荐直播无法正常加载

@shenshiaba 制作了一次性补丁修复这些问题，并声明不会持续维护。

### 第二阶段：兼容性与性能优化（by @yangpeidong123）

在社区修复版本基础上，针对 vivo Y71A（Android 8.0 / armeabi-v7a / 2GB RAM）进行了系统性优化：

#### 🔴 P0 高优先级修复

| 修复项 | 问题 | 方案 |
|--------|------|------|
| 首页图片不显示 | B站 CDN 防盗链拦截 + API 限流导致无数据 | 添加 Referer/UA 请求头 + 图片加载失败自动回退原图 |
| API 限流无重试 | 429 限流后首页空白 | 指数退避自动重试（1s→2s→4s，最多3次）|
| API 限流无缓存 | 限流后用户看到空白页 | 本地缓存 API 数据，限流时恢复显示 |
| 全屏沉浸式异常 | 导航栏黑条、下拉状态栏不消失、退出后导航栏不恢复 | 改用 `immersiveSticky` 模式 |
| 首次启动闪退 | Flutter 3.29 Impeller 渲染引擎不兼容老 GPU | 禁用 Impeller，使用 Skia 渲染 |
| 图片缓存过大 | 200MB 缓存导致低端机 OOM | 根据设备内存动态调整（低端机 50MB） |
| Controller 内存泄漏 | 30+ Controller 无 onClose，页面退出后不释放 | 批量添加 onClose 释放 ScrollController/TabController |

#### 🟡 P1 中优先级优化

| 优化项 | 详情 |
|--------|------|
| print → debugPrint | 162 处 `print()` 替换为 `debugPrint()`，Release 模式自动抑制 |
| 空 catch 修复 | 29 处 `catch (_) {}` 改为输出错误日志 |
| SDK 版本声明 | 显式 `minSdkVersion 21` / `targetSdkVersion 35` |
| ABI 过滤 | 仅打包 `armeabi-v7a` + `arm64-v8a`，APK 从 58.7MB → 34.9MB |

#### 🟢 P2 低优先级优化

| 优化项 | 详情 |
|--------|------|
| 列表滚动优化 | 27 个列表页显式声明 `addRepaintBoundaries` + `addAutomaticKeepAlives` |
| 硬件解码 | `auto-copy` 模式避免部分设备绿屏 |
| 自适应缓冲 | WiFi 8MB / 移动数据 4MB / 离线 2MB |
| 连接池 | `keep-alive` + `maxConnectionsPerHost=6` |

## 下载与安装

### 方式一：GitHub Actions Artifacts（推荐）

1. 打开本仓库 → 点击 **Actions** 标签
2. 找到最新成功的构建
3. 拉到页面底部 **Artifacts** 区域
4. 下载 **PiliPalaX-android-universal**

### 方式二：GitHub Releases

前往 [Releases 页面](https://github.com/yangpeidong123/PiliPalaX-Community-Fix/releases) 下载 APK。

### 安装注意

- 本版本使用社区维护者签名，与原 PiliPalaX 正式版签名不同
- 如已安装原版，需先卸载（建议备份数据）
- Android 需允许「安装未知来源应用」

## 构建环境

```
Flutter 3.29.0
Dart 3.x
Java 21 (Zulu)
Android SDK 35 / NDK 27.0.12077973
```

```bash
flutter pub get
flutter build apk --release
```

Release 构建需要配置以下 GitHub Secrets：
- `KEYSTORE_BASE64`：签名密钥库的 base64 编码
- `KEYSTORE_PASSWORD`：密钥库密码
- `KEY_ALIAS`：密钥别名
- `KEY_PASSWORD`：密钥密码

## 致谢

感谢以下所有作者和贡献者：

- [@guozhigq](https://github.com/guozhigq) — 原始 PiliPala 项目
- [@orz12](https://github.com/orz12) — PiliPalaX 分支
- [@shenshiaba](https://github.com/shenshiaba) — 社区兼容修复
- [所有贡献者](https://github.com/orz12/PiliPalaX/graphs/contributors)

感谢 B站提供平台与服务。本项目不收集、上传或留存任何用户数据。

## 免责声明

1. 本项目为个人学习、研究和兼容性测试用途的非官方社区版本，与哔哩哔哩（Bilibili）、PiliPala、PiliPalaX 原作者及其贡献者不存在隶属、代理、合作或背书关系。
2. 本项目不破解、绕过或干预平台的访问控制、付费机制及安全措施。
3. 本项目不提供、存储或分发任何 B站受版权保护的内容，相关内容与服务均由其权利人或平台提供。
4. 使用者应遵守当地法律法规和 B站用户协议。不得将本项目用于违法违规或侵权活动。
5. 本项目按 GPLv3 及"现状"提供，不作任何明示或默示担保。使用风险由使用者自行承担。
6. 如权利人认为本仓库内容侵犯其合法权益，请通过 GitHub Issue 联系。

## 许可证

[GNU General Public License v3.0](LICENSE) — 分发修改版本或 APK 时，应同时提供源代码、保留许可证与作者署名，并标注修改内容。
