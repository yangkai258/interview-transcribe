# WhisperX STT 技能

语音转文字 + 说话人区分技能。

## 文件结构

```
whisperx-stt/
├── SKILL.md           # 技能说明文档
├── install.sh         # 安装脚本
├── whisperx-stt.sh    # 主执行脚本
└── README.md          # 本文件
```

## 快速开始

### 1. 安装

```bash
bash skills/whisperx-stt/install.sh
```

### 2. 配置 Token

```bash
# 方法 1：添加到 OpenClaw 环境文件
echo 'HF_TOKEN=hf_xxxxxxxxxx' >> ~/.openclaw-rescue3/.env

# 方法 2：添加到 shell 配置
echo 'export HF_TOKEN="hf_xxxxxxxxxx"' >> ~/.zshrc
source ~/.zshrc
```

### 3. 接受模型协议

访问以下链接并点击「Agree」：
- https://huggingface.co/pyannote/speaker-diarization-3.1
- https://huggingface.co/pyannote/segmentation-3.0

### 4. 使用

```bash
# 基础用法
bash skills/whisperx-stt/whisperx-stt.sh ~/Downloads/recording.m4a

# 指定说话人数量
bash skills/whisperx-stt/whisperx-stt.sh ~/Downloads/meeting.wav 2

# 通过 OpenClaw 触发
/whisperx ~/Downloads/recording.m4a

# 企业微信文件（自动检测最新音频）
bash skills/whisperx-stt/whisperx-stt.sh --wecom
bash skills/whisperx-stt/whisperx-stt.sh --wecom 2
```

### 企业微信使用流程

1. **发送文件** — 在企业微信中发送音频文件给 OpenClaw
2. **触发转写** — 说以下任意一句：
   - 「转写这个录音」
   - 「语音转文字」
   - 「说话人区分」
   - 「whisperx」
3. **自动获取** — 技能自动从企业微信目录获取最新音频
4. **查看结果** — 返回带说话人标签的文字稿

## 输出示例

```
[SPEAKER_00]: 你好，我是面试官...
[SPEAKER_01]: 你好，我是候选人...
[SPEAKER_00]: 请介绍一下你的工作经历...
```

## 故障排除

详见 `SKILL.md` 中的「故障排除」章节。
