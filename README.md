# 🎙️ Interview Transcribe

**面试录音转写工具** — 基于 WhisperX 的语音转文字 + 说话人区分技能

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Python 3.9+](https://img.shields.io/badge/python-3.9+-blue.svg)](https://www.python.org/downloads/)
[![OpenClaw Skill](https://img.shields.io/badge/OpenClaw-Skill-green.svg)](https://openclaw.ai)

---

## ✨ 功能特点

- 🎯 **语音转文字** — 高精度中文语音识别（Whisper Medium 模型）
- 🗣️ **说话人区分** — 自动识别不同说话人（SPEAKER_00, SPEAKER_01...）
- 🕒 **时间戳** — 词级精度时间戳标注
- 📁 **多格式支持** — m4a, mp3, wav, flac, amr
- 💻 **本地运行** — 无需上传音频到云端，保护隐私
- 🤖 **OpenClaw 集成** — 支持企业微信文件自动检测

---

## 🚀 快速开始

### 1. 克隆仓库

```bash
git clone https://github.com/yangkai258/interview-transcribe.git
cd interview-transcribe
```

### 2. 安装依赖

```bash
bash skills/whisperx-stt/install.sh
```

### 3. 配置 Hugging Face Token

**步骤：**

1. 访问 https://huggingface.co/join 注册账号
2. 创建 Token：Settings → Access Tokens → Create (Read 权限)
3. 接受模型协议（点击「Agree」）：
   - https://huggingface.co/pyannote/speaker-diarization-3.1
   - https://huggingface.co/pyannote/segmentation-3.0
4. 配置 Token：
   ```bash
   echo 'HF_TOKEN=hf_xxxxxxxxxx' >> ~/.openclaw-rescue3/.env
   ```

### 4. 开始转写

```bash
# 方式 1：指定文件路径
bash skills/whisperx-stt/whisperx-stt.sh ~/Downloads/recording.m4a

# 方式 2：指定说话人数量（更准确）
bash skills/whisperx-stt/whisperx-stt.sh ~/Downloads/meeting.wav 2

# 方式 3：企业微信文件（自动检测最新音频）
bash skills/whisperx-stt/whisperx-stt.sh --wecom
```

---

## 📋 使用场景

### 面试录音转写

```bash
# 转写面试录音，自动区分面试官和候选人
bash skills/whisperx-stt/whisperx-stt.sh interview_20260407.m4a 2
```

**输出示例：**
```
[SPEAKER_00]: 你好，请介绍一下你的工作经历...
[SPEAKER_01]: 我是 2020 年毕业的，有 3 段工作经历...
[SPEAKER_00]: 为什么从上一家公司离职？
[SPEAKER_01]: 项目黄了，老板不做了...
```

### 会议记录

```bash
# 转写会议录音
bash skills/whisperx-stt/whisperx-stt.sh meeting_20260407.wav 3
```

### 播客/访谈节目

```bash
# 转写播客节目
bash skills/whisperx-stt/whisperx-stt.sh podcast_episode.m4a 2
```

---

## 📤 输出格式

### 文本文件（.txt）

```txt
[SPEAKER_00]: 你好，我是面试官...
[SPEAKER_01]: 你好，我是候选人...
[SPEAKER_00]: 请介绍一下你的工作经历...
```

### JSON 详细文件（.json）

包含词级时间戳、置信度等详细信息：

```json
{
  "segments": [
    {
      "speaker": "SPEAKER_00",
      "start": 0.031,
      "end": 17.176,
      "text": "我们是专业的软件工程师..."
    }
  ]
}
```

---

## ⚙️ 配置选项

| 参数 | 说明 | 默认值 |
|------|------|--------|
| `--model` | Whisper 模型 (tiny/small/medium/large) | medium |
| `--language` | 语言代码 (zh/en/ja...) | 自动检测 |
| `--min_speakers` | 最小说话人数 | 自动 |
| `--max_speakers` | 最大说话人数 | 自动 |
| `--compute_type` | 计算类型 (int8/float16) | int8 |
| `--device` | 运行设备 (cpu/cuda) | cpu |

---

## 🔧 故障排除

### 问题 1：模型下载超时

**解决：** 使用国内镜像

```bash
export HF_ENDPOINT="https://hf-mirror.com"
```

### 问题 2：PyTorch 兼容性错误

**解决：** 安装脚本已自动修复 PyTorch 2.6+ 兼容性问题

### 问题 3：说话人区分失败

**解决：** 
1. 确认已接受所有模型协议
2. 确认已配置 HF_TOKEN
3. 尝试指定说话人数量：`--wecom 2`

### 问题 4：内存不足

**解决：** 使用更小模型

```bash
whisperx audio.wav --model tiny --diarize
```

---

## 📁 文件结构

```
interview-transcribe/
├── skills/whisperx-stt/
│   ├── SKILL.md           # 技能说明文档
│   ├── install.sh         # 安装脚本
│   ├── whisperx-stt.sh    # 主执行脚本
│   └── README.md          # 技能快速入门
├── README.md              # 本文件
└── .gitignore
```

---

## 🤝 贡献

欢迎提交 Issue 和 Pull Request！

### 开发环境设置

```bash
# 克隆仓库
git clone https://github.com/yangkai258/interview-transcribe.git

# 安装依赖
pip install whisperx --user

# 运行测试
bash skills/whisperx-stt/whisperx-stt.sh tests/sample.m4a
```

---

## 📄 许可证

MIT License - 详见 [LICENSE](LICENSE) 文件

---

## 🙏 致谢

- [WhisperX](https://github.com/m-bain/whisperX) - 语音识别核心
- [Pyannote](https://github.com/pyannote/pyannote-audio) - 说话人区分
- [OpenClaw](https://openclaw.ai) - Agent 技能框架
- [Hugging Face](https://huggingface.co) - 模型托管

---

## 📞 联系方式

- **GitHub:** https://github.com/yangkai258/interview-transcribe
- **Issues:** https://github.com/yangkai258/interview-transcribe/issues

---

**Made with ❤️ for interviewers and HR professionals**
