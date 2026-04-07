#!/bin/bash

set -ueo pipefail

# WhisperX STT 主脚本
# 用法：whisperx-stt.sh <音频文件> [说话人数量]
#      whisperx-stt.sh --wecom [说话人数量]  # 企业微信最新文件

audio="${1:-}"
num_speakers="${2:-}"

# 企业微信文件目录
WECOM_INBOUND="$HOME/.openclaw/media/inbound"

# 显示帮助
show_help() {
    cat << EOF
🎙️ WhisperX STT - 语音转文字 + 说话人区分

用法：$0 <音频文件> [说话人数量]
      $0 --wecom [说话人数量]  # 企业微信最新文件

参数:
  音频文件        要转写的音频文件路径 (m4a/mp3/wav/flac)
  说话人数量      可选，指定说话人数量以提高准确度
  --wecom         从企业微信获取最新音频文件

示例:
  $0 ~/Downloads/recording.m4a          # 自动检测说话人
  $0 ~/Downloads/meeting.wav 2          # 指定 2 个说话人
  $0 /Volumes/share/audio.m4a           # 网络共享文件
  $0 --wecom                            # 企业微信最新文件
  $0 --wecom 2                          # 企业微信文件，指定 2 个说话人

输出:
  - 带说话人标签的文本 ([SPEAKER_00], [SPEAKER_01]...)
  - 时间戳信息
  - JSON 详细结果（可选）
EOF
    exit 0
}

# 检查参数
if [[ -z "$audio" ]] || [[ "$audio" == "-h" ]] || [[ "$audio" == "--help" ]]; then
    show_help
fi

# 企业微信模式：自动检测最新音频文件
if [[ "$audio" == "--wecom" ]]; then
    echo "📎 检测企业微信最新音频文件..."
    if [[ ! -d "$WECOM_INBOUND" ]]; then
        echo "❌ 错误：企业微信文件目录不存在：$WECOM_INBOUND"
        exit 1
    fi
    
    # 查找最新的音频文件
    audio="$(find "$WECOM_INBOUND" -type f \( -name "*.m4a" -o -name "*.mp3" -o -name "*.wav" -o -name "*.flac" -o -name "*.amr" \) -printf '%T@ %p\n' 2>/dev/null | sort -rn | head -1 | cut -d' ' -f2-)"
    
    if [[ -z "$audio" ]]; then
        echo "❌ 错误：企业微信目录没有找到音频文件"
        echo "请先在企业微信中发送音频文件"
        exit 1
    fi
    
    # 提取说话人数量（如果提供了）
    if [[ -n "${1:-}" ]] && [[ "${1:-}" =~ ^[0-9]+$ ]]; then
        num_speakers="$1"
    fi
    
    echo "✅ 找到文件：$audio"
fi

# 检查文件存在
if [[ ! -f "$audio" ]]; then
    echo "❌ 错误：文件不存在：$audio"
    exit 1
fi

# 加载环境变量
if [[ -f ~/.openclaw-rescue3/.env ]]; then
    export $(grep -v '^#' ~/.openclaw-rescue3/.env | xargs) 2>/dev/null || true
fi

# 检查 HF_TOKEN
if [[ -z "${HF_TOKEN:-}" ]]; then
    echo "❌ 错误：未设置 HF_TOKEN 环境变量"
    echo ""
    echo "请配置 Hugging Face Token:"
    echo "1. 访问 https://huggingface.co/settings/tokens"
    echo "2. 创建新 Token (Read 权限)"
    echo "3. 运行：echo 'HF_TOKEN=hf_xxx' >> ~/.openclaw-rescue3/.env"
    exit 1
fi

# 设置镜像站（中国大陆）
export HF_ENDPOINT="${HF_ENDPOINT:-https://hf-mirror.com}"

# 添加 whisperx 到 PATH
export PATH="$HOME/Library/Python/3.9/bin:$PATH"

# 检查 whisperx
if ! command -v whisperx &> /dev/null; then
    echo "❌ whisperx 未安装"
    echo "请运行：bash skills/whisperx-stt/install.sh"
    exit 1
fi

# 创建临时目录
tmpdir="$(mktemp -d)"
trap "rm -rf $tmpdir" EXIT

# 转换为 wav（whisperx 要求）
audio_wav="${tmpdir}/audio.wav"
echo "🔄 转换音频格式..."
ffmpeg -y -loglevel error -i "$audio" -ar 16000 -ac 1 -c:a pcm_s16le "$audio_wav"

# 构建 whisperx 命令
echo "🎙️ 开始转写（带说话人区分）..."
echo "音频：$audio"
echo "说话人：${num_speakers:-自动检测}"
echo ""

whisperx_cmd="whisperx \"$audio_wav\" \
    --model medium \
    --diarize \
    --output_dir \"$tmpdir\" \
    --output_format txt \
    --compute_type int8 \
    --device cpu \
    --hf_token \"${HF_TOKEN}\""

if [[ -n "$num_speakers" ]]; then
    whisperx_cmd="$whisperx_cmd --min_speakers $num_speakers --max_speakers $num_speakers"
fi

# 执行转写
eval $whisperx_cmd

# 输出结果
echo ""
echo "=== 转录结果 ==="
txt_file="${tmpdir}/audio.wav.txt"
if [[ -f "$txt_file" ]]; then
    cat "$txt_file"
else
    # 尝试其他可能的输出文件名
    for f in "${tmpdir}"/*.txt; do
        if [[ -f "$f" ]]; then
            cat "$f"
            break
        fi
    done
fi

# 保存结果到原文件目录
output_dir="$(dirname "$audio")"
output_name="$(basename "$audio" | sed 's/\.[^.]*$//')"
output_txt="${output_dir}/${output_name}_transcript.txt"

if [[ -f "$txt_file" ]]; then
    cp "$txt_file" "$output_txt"
    echo ""
    echo "✅ 结果已保存：$output_txt"
fi

# JSON 详细结果（如有）
json_file="${tmpdir}/audio.wav.json"
if [[ -f "$json_file" ]]; then
    output_json="${output_dir}/${output_name}_transcript.json"
    cp "$json_file" "$output_json"
    echo "✅ 详细结果已保存：$output_json"
fi
