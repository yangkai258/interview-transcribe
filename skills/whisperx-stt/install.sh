#!/bin/bash

set -ueo pipefail

echo "🎙️ WhisperX STT 安装脚本"
echo "========================="

# 检查 Python
if ! command -v python3 &> /dev/null; then
    echo "❌ 错误：需要 Python 3"
    exit 1
fi

echo "✅ Python: $(python3 --version)"

# 检查 ffmpeg
if ! command -v ffmpeg &> /dev/null; then
    echo "📦 安装 ffmpeg..."
    if command -v brew &> /dev/null; then
        brew install ffmpeg
    else
        echo "❌ 请安装 ffmpeg: brew install ffmpeg"
        exit 1
    fi
fi
echo "✅ ffmpeg: $(ffmpeg -version | head -1)"

# 安装 whisperx
echo "📦 安装 whisperx..."
python3 -m pip install whisperx --user --upgrade

# 验证安装
if command -v whisperx &> /dev/null; then
    echo "✅ whisperx 已安装"
else
    # 添加到 PATH
    echo "📝 添加 whisperx 到 PATH..."
    whisperx_path="$HOME/Library/Python/3.9/bin"
    if [[ -d "$whisperx_path" ]] && [[ ":$PATH:" != *":$whisperx_path:"* ]]; then
        echo "export PATH=\"$whisperx_path:\$PATH\"" >> ~/.zshrc
        echo "⚠️  请运行：source ~/.zshrc 或重启终端"
    fi
fi

# 修复 PyTorch 兼容性问题
echo "🔧 修复 PyTorch 2.6+ 兼容性问题..."

# 修复 torch.serialization
torch_serial="/Users/zhuobao/Library/Python/3.9/lib/python/site-packages/torch/serialization.py"
if [[ -f "$torch_serial" ]]; then
    if grep -q "weights_only: Optional\[bool\] = None" "$torch_serial" 2>/dev/null; then
        sed -i '' 's/weights_only: Optional\[bool\] = None/weights_only: Optional[bool] = False/g' "$torch_serial"
        echo "✅ 已修复 torch.serialization"
    fi
fi

# 修复 lightning_fabric
lightning_io="/Users/zhuobao/Library/Python/3.9/lib/python/site-packages/lightning_fabric/utilities/cloud_io.py"
if [[ -f "$lightning_io" ]]; then
    if grep -q "weights_only=weights_only" "$lightning_io" 2>/dev/null; then
        sed -i '' 's/weights_only=weights_only/weights_only=False/g' "$lightning_io"
        echo "✅ 已修复 lightning_fabric"
    fi
fi

# 检查 Hugging Face Token
echo ""
echo "🔐 Hugging Face Token 检查"
echo "=========================="

hf_token="${HF_TOKEN:-}"
if [[ -f ~/.openclaw-rescue3/.env ]]; then
    source ~/.openclaw-rescue3/.env 2>/dev/null || true
    hf_token="${HF_TOKEN:-$hf_token}"
fi

if [[ -z "$hf_token" ]]; then
    echo "⚠️  未检测到 HF_TOKEN 环境变量"
    echo ""
    echo "请配置 Hugging Face Token:"
    echo "1. 访问 https://huggingface.co/settings/tokens"
    echo "2. 创建新 Token (Read 权限)"
    echo "3. 运行：echo 'export HF_TOKEN=\"hf_xxx\"' >> ~/.zshrc"
    echo "4. 运行：source ~/.zshrc"
else
    echo "✅ HF_TOKEN 已配置"
fi

# 模型协议检查
echo ""
echo "📋 模型协议检查"
echo "==============="
echo "请确认已接受以下模型协议（点击「Agree」）:"
echo "  1. https://huggingface.co/pyannote/speaker-diarization-3.1"
echo "  2. https://huggingface.co/pyannote/segmentation-3.0"
echo ""

# 完成
echo "✅ 安装完成！"
echo ""
echo "🚀 使用方法:"
echo "   bash skills/whisperx-stt/whisperx-stt.sh <音频文件>"
echo ""
echo "📝 示例:"
echo "   bash skills/whisperx-stt/whisperx-stt.sh ~/Downloads/recording.m4a"
echo "   bash skills/whisperx-stt/whisperx-stt.sh ~/Downloads/meeting.wav 2"
