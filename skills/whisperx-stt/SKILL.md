---
name: whisperx-stt
description: WhisperX 语音转文字 + 说话人区分（本地运行，支持中文）
version: 1.0.0
author: OpenClaw Community
metadata: {"openclaw":{"emoji":"🎙️","os":["darwin"],"requires":{"bins":["whisperx","ffmpeg"],"env":["HF_TOKEN"]}}}
triggers:
- "/whisperx <audio>"
- "whisperx ..."
- "语音转文字 ..."
- "说话人区分 ..."
- "多人对话转写 ..."
- "STT ..."
- "转写这个录音 ..."
- "把这个录音转成文字 ..."
- "企业微信文件转写 ..."
---

# WhisperX STT - 语音转文字 + 说话人区分

基于 WhisperX 的本地语音识别技能，支持说话人分离（diarization）。

## ✨ 功能特点

- ✅ **本地运行** - 无需上传音频到云端
- ✅ **说话人区分** - 自动识别不同说话人（SPEAKER_00, SPEAKER_01...）
- ✅ **中文优化** - 对中文语音识别准确率高
- ✅ **时间戳** - 词级精度时间戳
- ✅ **多格式支持** - m4a, mp3, wav, flac 等

## 📋 前提条件

### 1. Hugging Face 账号

1. 注册账号：https://huggingface.co/join
2. 生成 Token：Settings → Access Tokens → Create (选 Read 权限)
3. 接受以下模型协议（点击「Agree」）：
   - https://huggingface.co/pyannote/speaker-diarization-3.1
   - https://huggingface.co/pyannote/segmentation-3.0

### 2. 配置 Token

将 Token 保存到环境变量：

```bash
# 方法 1：添加到 .zshrc
echo 'export HF_TOKEN="hf_xxxxxxxxxx"' >> ~/.zshrc
source ~/.zshrc

# 方法 2：添加到 OpenClaw 环境文件
echo 'HF_TOKEN=hf_xxxxxxxxxx' >> ~/.openclaw-rescue3/.env
```

### 3. 安装依赖

运行安装脚本（首次使用）：

```bash
bash ${baseDir}/install.sh
```

## 🚀 使用方法

### 基础用法

```bash
bash ${baseDir}/whisperx-stt.sh <音频文件路径>
```

### 指定说话人数量（更准确）

```bash
bash ${baseDir}/whisperx-stt.sh <音频文件路径> 2
# 第二个参数是说话人数量（可选）
```

### 示例

```bash
# 自动检测说话人数量
bash skills/whisperx-stt/whisperx-stt.sh ~/Downloads/recording.m4a

# 指定 2 个说话人
bash skills/whisperx-stt/whisperx-stt.sh ~/Downloads/meeting.wav 2

# 处理网络共享文件
bash skills/whisperx-stt/whisperx-stt.sh /Volumes/share/audio.m4a

# 企业微信文件（自动检测最新音频）
bash skills/whisperx-stt/whisperx-stt.sh --wecom
```

## 📎 企业微信文件支持

### 自动检测企业微信文件

当用户通过企业微信发送音频文件时，技能会自动检测并转写：

1. **发送文件** — 在企业微信中发送音频文件（m4a/mp3/wav）
2. **触发转写** — 说「转写这个录音」或「语音转文字」
3. **自动获取** — 技能从 `~/.openclaw/media/inbound/` 获取最新音频文件
4. **输出结果** — 返回带说话人标签的文字稿

### 支持的文件类型

- ✅ m4a（iPhone 录音）
- ✅ mp3（通用格式）
- ✅ wav（无损格式）
- ✅ flac（高保真）
- ✅ amr（微信语音）

### 企业微信使用流程

#### 步骤 1：发送文件

在企业微信聊天窗口中：
- 点击「文件」图标
- 选择音频文件（或直接发送语音消息）
- 发送给 OpenClaw

#### 步骤 2：触发转写

发送以下任意消息：
- 「转写这个录音」
- 「语音转文字」
- 「说话人区分」
- 「whisperx」
- 「STT」

#### 步骤 3：等待结果

技能自动：
1. 检测 `~/.openclaw/media/inbound/` 目录中的最新音频文件
2. 运行 WhisperX 转写（带说话人区分）
3. 返回带说话人标签的文字稿

### 触发词列表

以下消息会自动激活本技能：

```
/whisperx <audio>
whisperx ...
语音转文字 ...
说话人区分 ...
多人对话转写 ...
STT ...
转写这个录音 ...
把这个录音转成文字 ...
企业微信文件转写 ...
```

### 输出示例

```
[SPEAKER_00]: 你好，我是面试官...
[SPEAKER_01]: 你好，我是候选人...
[SPEAKER_00]: 请介绍一下你的工作经历...
```

### 输出文件

转写结果会保存到：
- **文本文件：** 原文件目录 + `_transcript.txt`
- **JSON 详情：** 原文件目录 + `_transcript.json`（含词级时间戳）

### 常见问题

**Q: 发送文件后没有反应？**

A: 检查以下几点：
1. 确认文件是音频格式（m4a/mp3/wav/flac/amr）
2. 确认企业微信通道已配置
3. 检查 `~/.openclaw/media/inbound/` 目录是否有文件

**Q: 转写速度慢？**

A: CPU 运行约 0.5-1x 实时速度，19 分钟录音约需 10-20 分钟。使用 GPU 可加速 70x。

**Q: 说话人区分不准确？**

A: 尝试指定说话人数量：
```bash
bash skills/whisperx-stt/whisperx-stt.sh --wecom 2
```

**Q: 文件在哪里？**

A: 企业微信文件保存在：
```bash
ls -lt ~/.openclaw/media/inbound/ | head -10
```

## 📤 输出格式

### 文本输出（带说话人标签）

```
[SPEAKER_00]: 你好，我是面试官...
[SPEAKER_01]: 你好，我是候选人...
[SPEAKER_00]: 请介绍一下你的工作经历...
```

### JSON 详细输出（可选）

包含词级时间戳、置信度等详细信息。

## ⚙️ 配置选项

| 参数 | 说明 | 默认值 |
|------|------|--------|
| `--model` | Whisper 模型 (tiny/small/medium/large) | medium |
| `--language` | 语言代码 (zh/en/ja...) | 自动检测 |
| `--min_speakers` | 最小说话人数 | 自动 |
| `--max_speakers` | 最大说话人数 | 自动 |
| `--compute_type` | 计算类型 (int8/float16) | int8 |
| `--device` | 运行设备 (cpu/cuda) | cpu |

## 📝 注意事项

1. **首次运行** - 会下载模型（约 1-2GB），需要良好网络
2. **网络环境** - 中国大陆建议使用代理或镜像站
3. **运行时间** - CPU 运行约 0.5-1x 实时，GPU 可加速 70x
4. **内存需求** - 建议 8GB+ 内存

## 🔧 故障排除

### 问题 1：模型下载超时

**解决：** 使用国内镜像

```bash
export HF_ENDPOINT="https://hf-mirror.com"
```

### 问题 2：PyTorch 兼容性错误

**解决：** 技能已自动修复 PyTorch 2.6+ 兼容性问题

### 问题 3：说话人区分失败

**解决：** 确认已接受所有模型协议并配置 HF_TOKEN

### 问题 4：内存不足

**解决：** 使用更小模型

```bash
whisperx audio.wav --model tiny --diarize
```

## 📚 相关技能

- `openai-whisper` - 基础 Whisper（无说话人区分）
- `mlx-stt` - Apple Silicon 本地 STT
- `elevenlabs-stt-openclaw` - ElevenLabs 云端 STT

## 📄 许可证

基于 WhisperX 开源项目，遵循 MIT 许可证。
