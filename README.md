# img2text

一个基于 [`robertknight/ocrs`](https://github.com/robertknight/ocrs) 的跨平台图片转文字项目。

## 项目结构

- `vendor/ocrs/`：上游 `ocrs` 源码（项目核心）
- `scripts/setup-windows.bat`：Windows 环境准备脚本
- `scripts/build-windows.bat`：Windows 编译与打包脚本
- `scripts/run-windows.bat`：Windows 运行脚本
- `scripts/fetch-models-windows.bat`：Windows 离线模型准备脚本
- `scripts/setup-ubuntu.sh`：Ubuntu 环境准备脚本
- `scripts/build-ubuntu.sh`：Ubuntu 编译与打包脚本
- `scripts/run-ubuntu.sh`：Ubuntu 运行脚本
- `scripts/fetch-models-ubuntu.sh`：Ubuntu 离线模型准备脚本
- `models/`：模型说明与可选强模型目录
- `dist/`：可移植产物目录（程序 + 模型）

## 环境准备

Windows：

```bat
scripts\setup-windows.bat
```

Ubuntu：

```bash
bash scripts/setup-ubuntu.sh
```

## 编译打包

Windows：

```bat
scripts\build-windows.bat
```

Ubuntu：

```bash
bash scripts/build-ubuntu.sh
```

构建后可执行文件位置：

- Windows：`dist\img2text.exe`
- Ubuntu：`dist/img2text`

并且模型会被放入：

- `dist/models/text-detection.rten`
- `dist/models/text-recognition.rten`

## 运行

Windows：

```bat
scripts\run-windows.bat your-image.png
```

Ubuntu：

```bash
bash scripts/run-ubuntu.sh your-image.png
```

输出到文本文件：

```bat
scripts\run-windows.bat your-image.png -o result.txt
```

输出 JSON：

```bat
scripts\run-windows.bat your-image.png --json -o result.json
```

输出标注 PNG：

```bat
scripts\run-windows.bat your-image.png --png -o annotated.png
```

## 离线移植

将整个 `dist/` 目录拷贝到另一台机器即可离线运行。

- Windows 目标机：运行 `img2text.exe`
- Ubuntu 目标机：运行 `./img2text`

也可以直接生成可分发压缩包（Windows）：

```bat
scripts\package-windows.bat
```

生成文件：`release\img2text-portable-windows-x64.zip`

解压后直接运行：

```bat
img2text.exe your-image.png
```

> 已在代码中实现：当可执行文件旁边存在 `models/` 时优先加载本地模型，不再依赖联网下载。

## 稍强模型（可选）

当前默认模型已集成并可离线运行。若你有更强的兼容 RTEN 模型，可放入：

- `models/strong/text-detection.rten`
- `models/strong/text-recognition.rten`

然后重新执行 build，脚本会复制到 `dist/models/strong/`。

运行时切换到 `strong`：

```bat
set IMG2TEXT_MODEL_PROFILE=strong
scripts\run-windows.bat your-image.png
```

```bash
export IMG2TEXT_MODEL_PROFILE=strong
bash scripts/run-ubuntu.sh your-image.png
```

若强模型不存在，会自动回退到默认模型。

## 说明

- `ocrs` 当前主要适用于 Latin 字母体系（英文等）。
- 为获得可接受性能，请使用 `release` 构建。
